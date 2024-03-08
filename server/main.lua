RSGCore = exports["rsg-core"]:GetCoreObject()

local jsonPath = "orders.json"
local ResourceName = GetCurrentResourceName()

RemoveMoney = function(source, type, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    Player.Functions.RemoveMoney(type, amount)
end

AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        local src = source
        Citizen.CreateThread(function()
            local jsonData = LoadResourceFile(ResourceName, jsonPath)
                GetJson()
        end)
    end
end)

lib.callback.register("as-moneyorders:getPlayers", function(_, cb)
    local src = source
    local players = {}
        for _, v in pairs(RSGCore.Functions.GetPlayers()) do
            local ped = RSGCore.Functions.GetPlayer(v)
            local targetped = GetPlayerPed(v)
            local tCoords = GetEntityCoords(targetped)
            local dist = #(GetEntityCoords(GetPlayerPed(src)) - tCoords)
            players[#players + 1] = {
                id = v,
                coords = tCoords,
                name = ped.PlayerData.charinfo.firstname .. " " .. ped.PlayerData.charinfo.lastname,
                citizenid = ped.PlayerData.citizenid,
                sourceplayer = ped.PlayerData.source,
                bank = ped.PlayerData.money["bank"],
                job = ped.PlayerData.job.name,
                dist = dist,
            }
        end
    return players
end)

lib.callback.register("as-check:getinfo", function(_, cb)
    local data = json.decode(LoadResourceFile(ResourceName, jsonPath))
    return data
end)

RegisterNetEvent("as-moneyorders:finishOrder", function(data)
    local file = LoadResourceFile(GetCurrentResourceName(), "orders.json")

    if file then
        local src = source
        local jsonData = json.decode(file)
        local nameFromData = data
        local ped = RSGCore.Functions.GetPlayer(src)
        local bank = tonumber(ped.PlayerData.money["bank"])
        local billAmount = tonumber(data.amount)
            if bank > billAmount then
                RemoveMoney(src, "bank", billAmount)
                exports["rsg-management"]:AddMoney(data.job, billAmount)
                for i, fieldData in ipairs(jsonData) do
                    if fieldData.id == nameFromData.id then
                        fieldData.status = "paid"
                        break
                    end
                end

                local updatedJsonData = json.encode(jsonData)
                SaveResourceFile(GetCurrentResourceName(), "orders.json", updatedJsonData, -1)

                TriggerClientEvent("as-check:receivejson", -1)
                GetJson()

                notif = {
                    id = "billid",
                    title = "BILL NOTIFY",
                    description = "You Paid : $ " .. data.amount,
                    position = "top-right",
                    style = {
                        backgroundColor = "green",
                        color = "white",
                        [".description"] = {
                            color = "white"
                        }
                    },
                    icon = "check",
                    iconColor = "white"
                }
                TriggerClientEvent("ox_lib:notify", src, notif)
            end
    end
end)

RegisterNetEvent("as-moneyorders:cancelRequest", function(data)
    local file = LoadResourceFile(GetCurrentResourceName(), "orders.json")

    if file then
        local src = source
        local jsonData = json.decode(file)
        local nameFromData = data.data

        for i, fieldData in ipairs(jsonData) do
            if fieldData.id == nameFromData.id then
                table.remove(jsonData, i)
                break
            end
        end

        local updatedJsonData = json.encode(jsonData)
        SaveResourceFile(GetCurrentResourceName(), "orders.json", updatedJsonData, -1)
        TriggerClientEvent("as-check:receivejson", -1)
        GetJson()

        notif = {
            id = "billid",
            title = "BILL NOTIFY",
            description = "You successfully deleted bill. Bill ID: " .. nameFromData.id,
            position = "top-right",
            style = {
                backgroundColor = "red",
                color = "white",
                [".description"] = {
                    color = "white"
                }
            },
            icon = "xmark",
            iconColor = "white"
        }
        TriggerClientEvent("ox_lib:notify", src, notif)
    end
end)

local lastID = 0

RegisterNetEvent("addBill")
AddEventHandler("addBill", function(amount, reason, data, job, author, pid, status)
    local Amount = tonumber(amount)
    local Reason = tostring(reason)
    local currentDateTime = os.date("%Y-%m-%d %H:%M:%S")

    local jsonData = LoadResourceFile(ResourceName, jsonPath)
    local fields = json.decode(jsonData)

    for _, field in ipairs(fields) do
        if field.id and field.id > lastID then
            lastID = field.id
        end
    end

    local newField = {
        id = lastID + 1,
        amount = Amount,
        reason = Reason,
        name = data.name,
        citizenid = data.citizenid,
        date = currentDateTime,
        job = job,
        author = author,
        status = status
    }
    table.insert(fields, newField)

    local encodedData = json.encode(fields)
    SaveResourceFile(ResourceName, jsonPath, encodedData, -1)
    TriggerClientEvent("as-check:receivejson", -1)
    GetJson()

    notif = {
        id = "billid",
        title = "BILL NOTIFY",
        description = "Price: $" .. amount .. " | Reason: " .. reason,
        position = "top-right",
        style = {
            backgroundColor = "green",
            color = "white",
            [".description"] = {
                color = "white"
            }
        },
        icon = "ban",
        iconColor = "white"
    }

    TriggerClientEvent("ox_lib:notify", pid, notif)
end)

RegisterNetEvent("as-moneyorders:js")
AddEventHandler("as-moneyorders:js", function()
    local info = json.decode(LoadResourceFile(ResourceName, jsonPath))
    TriggerClientEvent("as-check:receivejson", -1, info)
end)

function GetJson()
    local info = json.decode(LoadResourceFile(ResourceName, jsonPath))
    TriggerClientEvent("as-check:receivejson", -1, info)
end
