--[[
Name: CooldownButtons
Revision: $Rev$
Author(s): Dodge (Netrox @ Sen'Jin-EU / kujanssen@gmail.com)
Website: - none -
Documentation: http://wiki.wowace.com/CooldownButtons
SVN: http://svn.wowace.com/wowace/trunk/CooldownButtons
Description: Shows simple Buttons for your Cooldowns :)
Dependencies: LibStub, Ace3, LibSink-2.0. SharedMedia-3.0, LibPeriodicTable-3.1
License: GPL v2 or later.
]]

--[[
Copyright (C) 2008 Dodge

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]

local CooldownButtons = _G.CooldownButtons
CooldownButtons:CheckVersion("$Revision$")
local CooldownButtonsConfig = CooldownButtons:GetModule("Config")
local L = CooldownButtons.L

local newList, newDict, del, deepDel, deepCopy = CooldownButtons.GetRecyclingFunctions()
local getOrder, createHeader, createDescription, createInput, createRange, createSelect, createToggle, creteExecute, createColor = CooldownButtonsConfig:GetWidgetAPI()

function CooldownButtonsConfig:SavedCooldownsConfig()
    self.SavedCooldownsConfigIsSet = true
    
    local options = self.options
    options.args.cooldownSettings.args.saved = {
        type = "group",
        name = L["Save Cooldowns"],
        order = getOrder(),
        args = {
            spells = {
                type = "group",
                name = L["Spells"],
---                childGroups = "tab", -- looks buggy :(
                order = getOrder(),
                args = {
                },
            },
            items = {
hidden = true,
                type = "group",
                name = L["Items"],
                order = getOrder(),
                args = {
                },
            },
        },
    }
    local SpellsModule = CooldownButtons:GetModule("Spells")
    local spellArgs = options.args.cooldownSettings.args.saved.args.spells.args
    for k, v in SpellsModule:IterateSpellTable() do
        if v.spellknownCD then
            local cooldownName = k
            local db = CooldownButtons.savedDB.profile.Spells[cooldownName]
            spellArgs[v.spellID] = {
                type = "group",
                name = cooldownName,
                order = getOrder(),
                set = function( k, v )
                        if k.arg == "posx" then
                            if not (tonumber(v) == nil) then
                                db.pos.x = tonumber(v);
                            end
                        elseif k.arg == "posy" then
                            if not (tonumber(v) == nil) then
                                db.pos.y = tonumber(v);
                            end
                        else
                            db[k.arg] = v
                        end
                      end,
                get = function( k )
                        if k.arg == "posx" then
                            return tostring(db.pos.x)
                        elseif k.arg == "posy" then
                            return tostring(db.pos.y)
                        else
                            return db[k.arg]
                        end
                      end,
                args = {
                    header_00 = createHeader(cooldownName),
                    desc = createDescription(L["Here you can Setup at what position the Cooldown Button for the selected Spell should be drawn to."]),
                    radioSave = createToggle(L["Save Button Position"], "", "save", true),
                    pos_x = createInput(L["X - Axis"], L["Set the Position on X-Axis."], "posx"),
                    pos_y = createInput(L["Y - Axis"], L["Set the Position on Y-Axis."], "posy"),
                    
                    showAnchor = createExecute(L["Show Movable Button"], "", cooldownName, function(k)
                        local module = CooldownButtons:GetModule("Saved")
                        if not module.anchorVisible then
                            k.option.name = L["Hide Movable Button"]
                            module:ShowSavedAnchor(db, "Spell", cooldownName)
                        else
                            k.option.name = L["Show Movable Button"]
                            module:HideSavedAnchor(db)
                        end
                        LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
                    end),
                },
            }
        end
    end
end

















