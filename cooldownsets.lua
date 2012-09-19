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
    if class == "WARLOCK" then 
        sets["Summon Infernal/Doomguard"] = {
            ["icon"] = "Interface\\Icons\\warlock_summon_doomguard",
            ["ids"] = {
                ["1122"]  = true, -- Infernal
                ["18540"] = true, -- Doomguard
            },
        }
    elseif class == "DRUID" then 
        sets["Incarnation"] = {
            ["icon"] = "Interface\\Icons\\spell_druid_incarnation",
            ["ids"] = {
                ["106731"] = true, -- Talent
                ["102558"] = true, -- Guardian
                ["102560"] = true, -- Moonkin
                ["102543"] = true, -- Feral
            },
        }
    elseif class == "WARRIOR" then 
        sets["Shouts"] = {
            ["icon"] = "Interface\\Icons\\ability_warrior_battleshout",
            ["ids"] = {
                ["6673"] = true, -- Battle Shout
                ["469"]  = true, -- Commanding Shout
            },
        }
    end
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
    end
    ]]
    sets["Potions"] = {
        ["icon"] = "Interface\\AddOns\\CooldownButtons\\Icons\\healmana.tga",
        ["type"] = "Item",
        -- Got IDs from wowhead.com ( Filter: http://www.wowhead.com/?items=0&filter=ty=1#0+1 ) 
        ["ids"] = CreateTableEntrys(929,43569,43570,80040,88416,76094,43531,43530,32947,32948,63144,63145,32783,32909,32902,32905,32904,32903,18839,18841,40077,33934,33935,76096,58142,22839,4596,67415,12190,58090,31677,31676,6049,67944,5634,6050,77589,58146,5633,13461,20002,13457,13456,1710,13460,6149,13458,13459,13455,22838,33092,23822,64994,64993,22837,6051,737,40067,40093,22828,9172,22849,88382,858,3823,3385,4623,89640,5816,3387,20008,34440,22845,32840,31852,31853,31839,31838,31840,31841,31855,31854,22836,32846,22841,22842,32847,17348,13446,22847,17351,13444,22844,32844,18253,32845,22846,3827,23823,33093,76097,76098,40213,40214,40215,40216,13442,57193,40217,118,2455,2456,54213,3087,38351,57099,57191,57192,6052,39327,57194,58487,76092,76095,40081,13506,40211,76093,76090,58145,58488,40212,40087,13462,5631,32784,32910,9030,39671,63300,32762,32763,41166,33447,42545,33448,6048,22871,22826,22829,22832,22850,17349,3928,17352,13443,2459,6372,28101,76089,28100,58091,89641,9144),
    }
    return sets
end
