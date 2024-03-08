local AsgardMoneyOrders = {}
RSGCore = exports["rsg-core"]:GetCoreObject()


RegisterNetEvent("as-moneyorders:getMenu")
AddEventHandler("as-moneyorders:getMenu", function(JobInfo)
    ExecuteCommand('moneyorders')
end)

RegisterNetEvent("as-moneyorders:getcompanyMenu")
AddEventHandler("as-moneyorders:getcompanyMenu", function(JobInfo)
    ExecuteCommand('companyorders')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(15000)
        TriggerServerEvent("as-moneyorders:js")
    end
end)

RegisterNetEvent("as-check:receivejson", function(data)
    AsgardMoneyOrders = data
end)

AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    TriggerServerEvent("as-moneyorders:js")
    exports['rsg-target']:AddTargetModel(-1043434543, {
        options = {
            {
                type = "client",
                event = "as-moneyorders:getcompanyMenu",
                icon = "fas fa-cash-register",
                style = "",
                label = "Cash Register",
            },
        },
        distance = 2.5
    })
end)

RegisterNetEvent("as-moneyorders:input", function(data)
    local input = lib.inputDialog("Money Orders", {
        { type = "number", label = "Amount", description = "Select a price", min = 1, required = true, icon = "dollar-sign" },
        { type = "input", label = "Reason", description = "Products purchased", required = true, icon = "arrow-right" }
    })

    if input ~= nil then
        local Amount = input[1]
        local Reason = input[2]
        TriggerServerEvent("addBill", Amount, Reason, data.data, data.job, data.author, data.pid, data.status)
    end
end)

RegisterNetEvent("as-moneyorders:company", function()
    local src = source
    local options = {}
        if AsgardMoneyOrders ~= nil then
            for k, v in pairs(AsgardMoneyOrders) do
                if PlayerJob.name == v.job then
                    table.insert(options, {
                        icon = "user",
                        title = v.name,
                        arrow = true,
                        event = "as-moneyorders:cancelRequest",
                        description = "Date : " .. v.date .. "\n Price :  $ " .. v.amount .. " \nProduct : " .. v.reason .. " \n Sender : " .. v.author .. " \n Status : " .. string.upper(v.status),
                        args = {data = v, job = PlayerJob.name}
                    })
                end
            end
        end

    lib.registerContext({
        id = "cu",
        title = "Money Orders",
        options = options
    })

    lib.showContext("cu")
end)

RegisterNetEvent("as-moneyorders:incOrders:unpaid", function()
    local src = source
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local options = {}
        if AsgardMoneyOrders ~= nil then
            for k, v in pairs(AsgardMoneyOrders) do
                if PlayerData.citizenid == v.citizenid and v.status == "unpaid" then
                    table.insert(options, {
                        icon = "user",
                        title = string.upper(v.job),
                        arrow = true,
                        event = "as-moneyorders:getOrder",
                        description = "Date: " .. v.date .. "\nPrice: $" .. v.amount .. "\nProduct: " .. v.reason .. " \n Sender : " .. v.author,
                        args = v
                    })
                end
            end
        end

    lib.registerContext({
        id = "cu",
        title = "Money Orders",
        options = options
    })

    lib.showContext("cu")
end)

RegisterNetEvent("as-moneyorders:sendOrder", function()
    local src = source
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local name = PlayerData.charinfo.lastname .. " " .. PlayerData.charinfo.lastname

    lib.callback("as-moneyorders:getPlayers", src, function(info)
        local options = {}

        for k, v in pairs(info) do
            if v.dist < 5 and v.job ~= PlayerJob then
                local isMatchingId = PlayerData.citizenid == v.citizenid
                if not isMatchingId then
                    table.insert(options, {
                        icon = "user",
                        title = "[ " .. v.id .. " ]  -  " .. v.name,
                        arrow = true,
                        event = "as-moneyorders:input",
                        description = string.upper(v.job),
                        args = {
                            data = v,
                            job = PlayerJob.name,
                            author = name,
                            pid = v.sourceplayer,
                            status = "unpaid"
                        }
                    })
                end
            end
        end

        lib.registerContext({
            id = "cu",
            title = "Money Orders",
            options = options
        })

        lib.showContext("cu")
    end)
end)

RegisterNetEvent("as-moneyorders:getOrder", function(data)
    lib.registerContext({
        id = "other_menu",
        title = "Money Orders",
        menu = "cu",
        options = {
            {
                icon = "check",
                title = "Pay via Cheque",
                serverEvent = "as-moneyorders:finishOrder",
                args = data
            },
            {
                icon = "xmark",
                title = "Cancel",
                onSelect = function()
                    lib.showContext("cu")
                end
            }
        }
    })

    lib.showContext("other_menu")
end)

RegisterNetEvent("as-moneyorders:cancelRequest", function(data)
    lib.registerContext({
        id = "other_menu",
        title = "Money Orders",
        menu = "cu",
        options = {
            {
                icon = "xmark",
                serverEvent = "as-moneyorders:cancelRequest",
                args = data,
                title = "Cancel Request"
            }
        }
    })

    lib.showContext("other_menu")
end)

RegisterCommand('moneyorders', function()
    local foundJob = false
    local PlayerData = RSGCore.Functions.GetPlayerData()

    for i, job in ipairs(Config.ApprovedBusinesses) do
        if job == PlayerData.job.name then
            lib.registerContext({
                id = "moneyOrders",
                title = "Money Orders",
                options = {
                    { title = "Money Orders", description = "Unpaid requests. Pay via cheque here", icon = "file-invoice-dollar", event = "as-moneyorders:incOrders:unpaid" },
                    { title = "Company Requests", description = "Check your company's money orders status", icon = "file-invoice-dollar", event = "as-moneyorders:company" },
                    { title = "Request Payment", description = "Request payment from another player", icon = "file-invoice-dollar", event = "as-moneyorders:sendOrder" }
                }
            })

            lib.showContext("moneyOrders")
            foundJob = true
            break
        end
    end

    if not foundJob then
        TriggerEvent('as-moneyorders:incOrders:unpaid')
    end
end)

RegisterCommand('companyorders', function()
    local foundJob = false
    local PlayerData = RSGCore.Functions.GetPlayerData()

    for i, job in ipairs(Config.ApprovedBusinesses) do
        if job == PlayerData.job.name then
            lib.registerContext({
                id = "moneyOrders",
                title = "Money Orders",
                options = {
                    { title = "Company Requests", description = "Check your company's money orders status", icon = "file-invoice-dollar", event = "as-moneyorders:company" },
                    { title = "Request Payment", description = "Request payment from another player", icon = "file-invoice-dollar", event = "as-moneyorders:sendOrder" }
                }
            })

            lib.showContext("moneyOrders")
            foundJob = true
            break
        end
    end

    if not foundJob then
        TriggerEvent('as-moneyorders:incOrders:unpaid')
    end
end)