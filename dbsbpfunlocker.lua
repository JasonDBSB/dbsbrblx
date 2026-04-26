--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local ok, cooked = pcall(function()
    return getdeletedactors()
end)

if ok then 
    warn('boom your good it supports')
else
    game.Players.LocalPlayer:Kick("your executer doesnt support this shit.")
end

for i,v in next, getdeletedactors() do -- bro w function
    run_on_actor(v, [[
        local r = getrenv().shared.require

        -- modules
        local data = r('PlayerDataUtils')
    
        -- unlock all weapons
        local weaponFunc = data.ownsWeapon
        if not isfunctionhooked(weaponFunc) then
            hookfunction(weaponFunc, newcclosure(function() return true end))
        end

        -- unlock other shit, fuck the module im using getgc XD
        for i,v in next, getgc(true) do
            if typeof(v) == 'table' and rawget(v, 'ownsBlueprint') then
                local ownsBlueprint = v.ownsBlueprint
                if not isfunctionhooked(ownsBlueprint) then
                    hookfunction(ownsBlueprint, newcclosure(function() return true end))
                end
            end
        end

        -- fuckass attachments
        local ownsAttachment = data.ownsAttachment
        if not isfunctionhooked(ownsAttachment) then
            hookfunction(ownsAttachment, newcclosure(function() return true end))
        end

        -- skins / woah did hitler make this?
        local camodatabase = require(game:GetService("ReplicatedStorage"):WaitForChild("Content"):WaitForChild("ProductionContent"):WaitForChild("CamoDatabase")) -- dood u gotta wait for child or it wont be there because the child is a infant
        --if not camodatabase then return hitler end
        if not isfunctionhooked(data.getInventoryData) then
            local oldinventory
            oldinventory = hookfunction(data.getInventoryData, newcclosure(function(pd)
                local inv = oldinventory(pd)
                for skinname, skindata in next, camodatabase do
                    local casename = skindata.Case
                    if casename then
                        if not inv[casename] then
                            inv[casename] = { Cases = { Count = 0, Assigned = {} }, Keys = 0, Skins = {} }
                        end
                        if not inv[casename].Skins[skinname] then
                            inv[casename].Skins[skinname] = {}
                        end
                        inv[casename].Skins[skinname].ALL = true
                    end
                end
                return inv
            end))
        end

        -- updatehitler
        for i,v in next, getgc() do
            if typeof(v) == 'function' and islclosure(v) and debug.info(v, 'n'):find("updateWeaponList") then
                --print(debug.info(v, 's'))
                v()
            end
        end
    ]])
end
