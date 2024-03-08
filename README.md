# Asgard Scripts
- discord : https://discord.gg/wDCeJqp6ea
- tebex : https://asgardrp.tebex.io/
- github: https://github.com/ArlenBalesA

# Asgard Money Orders by ArlenBales
Simple billing system using oxLib with included automatic checks and triggers to only show what each person is supposed to see, payment requests are limited to players with approved jobs which you can set within the config, customers will only see option to pay an unpaid money order. Payments are made via cheque to remain lore friendly. System can be called with commands, target system, textUI, 3D Text and my free dialogs system. Automatically implements function for cash registers in saloons to support my Asgard Saloon player job and play run businesses and other future jobs that I have planned.

# Previews
- https://i.imgur.com/FRcV398.png
- https://i.imgur.com/tI3LuSX.png

# Dependancies
- rsg-core
- oxLib

# Installation
- Drag and drop into your resources, make sure it starts after oxLib and rsg-core

# Features and Info
- Automatically checks a players job and automatically triggers one of two events: if the player is employed at an approved business, they will receive the full payment menu where they can check unpaid society orders and request new payments from nearby players. If the player is not employed at an approved job they will receive only their unpaid orders to pay it.
- Checks if the players bank has enough money to complete the money order and pay via cheque.
- Automatically finds nearby players, you don't have to enter ID's or mess around trying to target the player to bring up the menu.
- Menu can easily be triggered with prompt's, textUI's, target systems and even my free Dialogs script.
- Small config file that simply allows you to add more whitelisted/approved jobs for the payment request menu.
- Examples for usage
- Built to work with my saloon script that automatically applies target to cash registers in saloons that bring up the request payment (for workers) and complete payment (for customers) and this example can be used with any businesses in your server.
- Uses oxLib similarly to my other scripts for seamless and intuitive experience with no loss of immersion or dozes of different menu types/looks/feels.
- Uses oxLib notifications to alert a player when they receive a money order request, and when a money order payment is completed via cheque.

# Usage Examples
This is pretty simple to use, the two main menu's can be brought up with the commands provided: /moneyorders and /companyorders - /moneyorders brings up the default menu with all options, automatically checks if employee or customer, if employee shows all options, if customer it shows only the option to pay. /companyorders alternatively ONLY bring up payment related info, as an employee you only have the option to check current order status and initiate a new request, customer can only pay.

To trigger these menu's from another function or resource is simple with the following:
- ExecuteCommand('moneyorders')
- ExecuteCommand('companyorders')

Or if you want to assign this to an event, the resource comes with two event handlers that are:
- as-moneyorders:getMenu
- as-moneyorders:getcompanyMenu

And these can be triggered with the following calls:
- TriggerEvent('as-moneyorders:getMenu') (this is from a client sided script)
- TriggerClientEvent('as-moneyorders:getcompanyMenu') (this is from a server sided event)