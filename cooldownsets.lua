--[[
Name: CooldownButtons
Project Revision: @project-revision@
File Revision: @file-revision@ 
Author(s): Netrox (netrox@sourceway.eu)
Website: http://www.wowace.com/projects/cooldownbuttons/
SVN: svn://svn.wowace.com/wow/cooldownbuttons/mainline/trunk
License: All rights reserved.
]]

local CDB = CDB

local function CreateTableEntrys(...)
    local count = select('#', ...)
    local entrys = {}
    for i = 1, count, 1 do
        entrys[tostring(select(i, ...))] = true
    end
    return entrys
end

function CDB:InitDefaultCooldownSets()
    local class = select(2, UnitClass("player"))
    local sets = {
        ["**"] = {
            ["icon"] = "Interface\\Icons\\INV_Misc_QuestionMark",
            ["type"] = "Spell",
            ["ids"] = {
                ["**"] = false,
            },
        }
    }
  --[[  
    if class == "HUNTER" then 
        sets["Fire Traps"] = {
            ["icon"] = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            ["ids"] = {
                -- Immolation
                ["13795"] = true,
                ["14302"] = true,
                ["14303"] = true,
                ["14304"] = true,
                ["14305"] = true,
                ["27023"] = true,
                ["49055"] = true,
                ["49056"] = true,
                -- Explosive
                ["13813"] = true,
                ["14316"] = true,
                ["14317"] = true,
                ["27025"] = true,
                ["49066"] = true,
                ["49067"] = true,
                -- Black Arrow
                ["3674"]  = true, -- is that rly first rank?
                ["63668"] = true,
                ["63669"] = true,
                ["63670"] = true,
                ["63671"] = true,
                ["63672"] = true,
            },
        }
        sets["Frost Traps"] = {
            ["icon"] = "Interface\\Icons\\Spell_Frost_FreezingBreath",
            ["ids"] = {
                -- Freezing Trap
                ["1499"] = true,
                ["14310"] = true,
                ["14311"] = true,
                -- Frost Trap
                ["13809"] = true,
            },
        }
        sets["Shoots"] = {
            ["icon"] = "Interface\\Icons\\Ability_Hunter_Assassinate2",
            ["ids"] = {
                -- Explosive Shot
                ["53301"] = true,
                ["60051"] = true,
                ["60052"] = true,
                ["60053"] = true,
                -- Arcane Shot
                ["3044"] = true,
                ["14281"] = true,
                ["14282"] = true,
                ["14283"] = true,
                ["14284"] = true,
                ["14285"] = true,
                ["14286"] = true,
                ["14287"] = true,
                ["27019"] = true,
                ["49044"] = true,
                ["49045"] = true,
                -- Kill Shot
                ["53351"] = true,
                ["61005"] = true,
                ["61006"] = true,
            },
        }
    elseif class == "SHAMAN" then 
        sets["Shocks"] = {
            ["icon"] = "Interface\\AddOns\\CooldownButtons\\Icons\\shocks.tga",
            ["ids"] = {
                -- Earth Shock
                ["8042"] = true,
                ["8044"] = true,
                ["8045"] = true,
                ["8046"] = true,
                ["10412"] = true,
                ["10413"] = true,
                ["10414"] = true,
                ["25454"] = true,
                ["49230"] = true,
                ["49231"] = true,
                -- Flame Shock
                ["8050"] = true,
                ["8052"] = true,
                ["8053"] = true,
                ["10447"] = true,
                ["10448"] = true,
                ["29228"] = true,
                ["25457"] = true,
                ["49232"] = true,
                ["49233"] = true,
                -- Frost Shock
                ["8056"] = true,
                ["8058"] = true,
                ["10472"] = true,
                ["10473"] = true,
                ["25464"] = true,
                ["49235"] = true,
                ["49236"] = true,
            },
        }
    elseif class == "PALADIN" then 
        sets["Judgements"] = {
            ["icon"] = "Interface\\Icons\\Spell_Holy_RighteousFury",
            ["ids"] = {
                -- Judgement of Justice
                ["53407"] = true,
                -- Judgement of Light
                ["20271"] = true,
                -- Judgement of Wisdom
                ["53408"] = true,
            },
        }
    elseif class == "WARRIOR" then 
        sets["Overpower/Revenge"] = {
            ["icon"] = "Interface\\AddOns\\CooldownButtons\\Icons\\warrior_2spells.tga",
            ["ids"] = {
                -- Overpower
                ["7384"] = true,
                -- Revenge
                ["6572"] = true,
                ["6574"] = true,
                ["7379"] = true,
                ["11600"] = true,
                ["11601"] = true,
                ["25288"] = true,
                ["25269"] = true,
                ["30357"] = true,
                ["57823"] = true,
            },
        }
    end
    ]]
    sets["Potions"] = {
        ["icon"] = "Interface\\AddOns\\CooldownButtons\\Icons\\healmana.tga",
        ["type"] = "Item",
        -- Got IDs from wowhead.com ( Filter: http://www.wowhead.com/?items=0&filter=ty=1#0+1 ) 
        ["ids"] = CreateTableEntrys(43569,43570,43531,43530,32947,32948,32783,32909,32902,32905,32904,32903,18839,18841,5632,40077,33934,33935,22839,4596,12190,31677,31676,6049,5634,6050,5633,13461,20002,13457,13456,1710,13460,6149,13458,13459,13455,22838,929,23822,33092,22837,6051,40067,40093,22828,9172,22849,45276,45277,2633,858,3823,3385,4623,5816,3387,20008,34440,9036,22845,32840,31838,31839,31852,31853,31840,31841,31854,31855,22836,22841,32846,22842,32847,17348,13446,22847,17351,13444,22844,32844,18253,22846,32845,3827,23823,33093,40213,40214,40215,40216,13442,40217,118,3384,2455,2456,3087,38351,6052,39327,3386,40081,13506,40211,40212,40087,13462,5631,32784,32910,9030,39671,32762,32763,41166,33447,42545,33448,6048,22871,22826,22829,22832,22850,17349,3928,17352,13443,2459,6372,28101,28100,9144,36770),
    }
    sets["Healthstone"] = {
        ["icon"] = "Interface\\Icons\\INV_Stone_04",
        ["type"] = "Item",
        -- Got IDs from wowhead.com
        ["ids"] = CreateTableEntrys(36891,36890,36889,36892,36893,36894,19010,19011,5510,19008,5509,19009,5511,19006,19007,19012,9421,19013,22104,22103,22105,5512,19005,19004),
    }
    return sets
end
