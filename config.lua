local LibStub = LibStub
local CoolDownButtons = _G["CoolDownButtons"]
CoolDownButtonsConfig = CoolDownButtons:NewModule("Config","AceConsole-3.0","AceEvent-3.0")
local CoolDownButtonsConfig = CoolDownButtonsConfig
local L = LibStub("AceLocale-3.0"):GetLocale("CoolDown Buttons", false)
local LSM = LibStub("LibSharedMedia-2.0")

local CDBCHelper = {}
local options = {}
local db

local string_format = string.format
local tostring = tostring
local tonumber = tonumber


options.type = "group"
options.name = "CoolDown Buttons r"..CoolDownButtons.rev
options.get = function( k ) return db[k.arg] end
options.set = function( k, v ) db[k.arg] = v; CoolDownButtonsConfig:UpdateConfig(); end
options.args = {}
options.plugins = {}

local opt_directions = {
	["up"]    = L["Up"],
	["down"]  = L["Down"],
	["left"]  = L["Left"],
	["right"] = L["Right"],
}
local opt_text_directions = {
	["up"]    = L["Above"],
	["down"]  = L["Below"],
	["left"]  = L["Left"],
	["right"] = L["Right"],
}

options.args.display = {
 	type = "group",
    name = L["Display Settings"],
	order = 0,
	args = {
        splitCooldowns = {
            order = 0,
            name = L["Split Item Cooldowns"],
            desc = L["Toggle showing Item and Spell Cooldowns as own rows or not."],
            type = "toggle",
            arg = "splitRows",
        },
        splitSoon = {
            order = 10,
            name = L["Split expiring Cooldown"],
            desc = L["Toggle showing Item and Spell Cooldowns in an additional row if they are expiring soon."],
            type = "toggle",
            arg = "splitSoon",
        }, dummy_11 = { order = 11, type = "description", name = "", },
        fontColor = {
            order = 30,
            name = L["Font Color"],
            desc = L["Color of the CoolDown Timer Font."],
            type = "color",
            hasAlpha = true,
            arg = "fontColor",
            get = function(info)
                local t = db[info.arg]
                return t.Red, t.Green, t.Blue, t.Alpha
            end,
            set = function(info, r, g, b, a)
                local t = db[info.arg]
                t.Red = r
                t.Green = g
                t.Blue = b
                t.Alpha = a
                CoolDownButtonsConfig:UpdateConfig()
            end,
        },
        fontToUse = {
            order = 40,
            name = L["Font"],
            desc = "",
            type = "select",
            values = function() local fonts, newFonts = LSM:List("font"), {}; for k, v in pairs(fonts) do newFonts[v] = v; end return newFonts; end,
            get = function( k ) return db[k.arg] end,
            arg = "font",
        },
        fontSize = {
            order = 41,
            name = L["Font size"],
            desc = L["Set the Font size."],
            type = "input",
            arg = "fontSize",
            set = function( k, v ) if not (tonumber(v) == nil) then db[k.arg] = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
            get = function( k ) return tostring(db[k.arg]) end,
        },
        cooldownsSpells = {
            type = "group",
            name = L["Spell Cooldowns"],
            order = 50,
            set = function( k, v ) db.anchors.spells[k.arg] = v; CoolDownButtonsConfig:UpdateConfig(); end,
            get = function( k ) return db.anchors.spells[k.arg] end,
            args = {
                showAnchor = {
                    order = 0,
                    name = L["Show Anchor"],
                    desc = L["Toggle showing Anchor."],
                    type = "toggle",
                    arg = "show",
                },
                centerToAnchor = {
                    order = 1,
                    name = L["Center from Anchor"],
                    desc = L["Toggle Anchor to be the Center of the bar."],
                    type = "toggle",
                    arg = "center",
                }, dummy_0 = { order = 2, type = "description", name = "", },
                showOmniCC = {
                    order = 3,
                    disabled = function() return CoolDownButtons.noOmniCC end,
                    name = L["Enable OmniCC Settings"],
                    desc = L["Toggle use OmniCC settings instead of own. (Pulse effect/Timer/Cooldown Spiral)"],
                    type = "toggle",
                    arg = "showOmniCC",
                },
                showTime = {
                    order = 4,
                    name = L["Show Time"],
                    desc = L["Toggle showing Cooldown Time at the Buttons."],
                    type = "toggle",
                    arg = "showTime",
                }, dummy_5 = { order = 5, type = "description", name = "", },
                usePulse = {
                    order = 6,
                    name = L["Use Pulse effect"],
                    desc = L["Toggle Pulse effect."],
                    disabled = function() return db.anchors.spells.showOmniCC end,
                    type = "toggle",
                    arg = "usePulse",
                }, 
                showCoolDownSpiral = {
                    order = 7,
                    disabled = function() return db.anchors.spells.showOmniCC end,
                    name = L["Show CoolDown Spiral"],
                    desc = L["Toggle showing CoolDown Spiral on the Buttons."],
                    type = "toggle",
                    arg = "showCoolDownSpiral",
                },dummy_8 = { order = 8, type = "description", name = "", },
                xpos = {
                    order = 10,
                    name = L["X - Axis"],
                    desc = L["Set the Position on X-Axis."],
                    type = "input",
                    arg = "spells",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors[k.arg].pos.x = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors[k.arg].pos.x) end,
                },
                ypos = {
                    order = 20,
                    name = L["Y - Axis"],
                    desc = L["Set the Position on Y-Axis."],
                    type = "input",
                    arg = "spells",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors[k.arg].pos.y = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors[k.arg].pos.y) end,
                }, dummy = { order = 30, type = "description", name = "", },
                displayDirection = {
                    order = 40,
                    name = L["Direction"],
                    desc = L["Direction from Anchor"],
                    type = "select",
                    values = opt_directions,
                    arg = "direction"
                },
                maxButtons = {
                    order = 50,
                    name = L["Max Buttons"],
                    desc = L["Maximal number of Buttons to display."],
                    type = "input",
                    arg = "maxbuttons",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors.spells[k.arg] = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors.spells[k.arg]) end,
                },
                dummy_60 = { -- Need another line break :)
                    order = 60,
                    type = "description",
                    name = "",
                },
                buttonScale = {
                    order = 70,
                    name = L["Button Scale"],
                    desc = L["Button scaling, this lets you enlarge or shrink your Buttons."],
                    type = "range",
                    min = 0.5, max = 2.5, step = 0.05,
                    arg = "scale",
                },
                buttonAlpha = {
                    order = 80,
                    name = L["Button Alpha"],
                    desc = L["Icon alpha value, this lets you change the transparency of the Button."],
                    type = "range",
                    min = 0.1, max = 1, step = 0.05,
                    arg = "alpha",
                },
                dummy2 = { -- Need another line break :)
                    order = 90,
                    type = "description",
                    name = "",
                },
                buttonPadding = {
                    order = 100,
                    name = L["Button Padding"],
                    desc = L["Space Between Buttons."],
                    type = "input",
                    arg = "buttonPadding",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors.spells[k.arg] = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors.spells[k.arg]) end,
                },
                textPadding = {
                    order = 110,
                    name = L["Text Distance"],
                    desc = L["Distance of Text to Button."],
                    type = "input",
                    arg = "textPadding",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors.spells[k.arg] = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors.spells[k.arg]) end,
                },
                dummy1 = { -- Need another line break :)
                    order = 120,
                    type = "description",
                    name = "",
                },
                textSettings = {
                    order = 130,
                    name = L["Use Text Settings"],
                    desc = L["Toggle using extra Text Settings."],
                    type = "toggle",
                    arg = "textSettings",
                },
                textSide = {
                    disabled = function() return not db.anchors.spells.textSettings end,
                    order = 140,
                    name = L["Text Side"],
                    desc = L["Text Side from Button"],
                    type = "select",
                    values = opt_text_directions,
                    arg = "textSide"
                },
                dummy3 = { -- Need another line break :)
                    order = 150,
                    type = "description",
                    name = "",
                },
                textScale = {
                    disabled = function() return not db.anchors.spells.textSettings end,
                    order = 160,
                    name = L["Text Scale"],
                    desc = L["Text scaling, this lets you enlarge or shrink your Text."],
                    type = "range",
                    min = 0.5, max = 2.5, step = 0.05,
                    arg = "textScale",
                },
                textAlpha = {
                    disabled = function() return not db.anchors.spells.textSettings end,
                    order = 170,
                    name = L["Text Alpha"],
                    desc = L["Text alpha value, this lets you change the transparency of the Text."],
                    type = "range",
                    min = 0.1, max = 1, step = 0.05,
                    arg = "textAlpha",
                },
            },
        },
        cooldownsItems = {
            type = "group",
            name = L["Item Cooldowns"],
            order = 60,
            hidden = function() return not db.splitRows end,
            set = function( k, v ) db.anchors.items[k.arg] = v; CoolDownButtonsConfig:UpdateConfig(); end,
            get = function( k ) return db.anchors.items[k.arg] end,
            args = {
                showAnchor = {
                    order = 0,
                    name = L["Show Anchor"],
                    desc = L["Toggle showing Anchor."],
                    type = "toggle",
                    arg = "show",
                },
                centerToAnchor = {
                    order = 1,
                    name = L["Center from Anchor"],
                    desc = L["Toggle Anchor to be the Center of the bar."],
                    type = "toggle",
                    arg = "center",
                }, dummy_2 = { order = 2, type = "description", name = "", },
                showOmniCC = {
                    order = 3,
                    disabled = function() return CoolDownButtons.noOmniCC end,
                    name = L["Enable OmniCC Settings"],
                    desc = L["Toggle use OmniCC settings instead of own. (Pulse effect/Timer/Cooldown Spiral)"],
                    type = "toggle",
                    arg = "showOmniCC",
                },
                showTime = {
                    order = 4,
                    name = L["Show Time"],
                    desc = L["Toggle showing Cooldown Time at the Buttons."],
                    type = "toggle",
                    arg = "showTime",
                }, dummy_5 = { order = 5, type = "description", name = "", },
                usePulse = {
                    order = 6,
                    name = L["Use Pulse effect"],
                    desc = L["Toggle Pulse effect."],
                    disabled = function() return db.anchors.items.showOmniCC end,
                    type = "toggle",
                    arg = "usePulse",
                }, 
                showCoolDownSpiral = {
                    order = 7,
                    disabled = function() return db.anchors.items.showOmniCC end,
                    name = L["Show CoolDown Spiral"],
                    desc = L["Toggle showing CoolDown Spiral on the Buttons."],
                    type = "toggle",
                    arg = "showCoolDownSpiral",
                },dummy_8 = { order = 8, type = "description", name = "", },
                xpos = {
                    order = 10,
                    name = L["X - Axis"],
                    desc = L["Set the Position on X-Axis."],
                    type = "input",
                    arg = "items",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors[k.arg].pos.x = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors[k.arg].pos.x) end,
                },
                ypos = {
                    order = 20,
                    name = L["Y - Axis"],
                    desc = L["Set the Position on Y-Axis."],
                    type = "input",
                    arg = "items",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors[k.arg].pos.y = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors[k.arg].pos.y) end,
                }, dummy = { order = 30, type = "description", name = "", },
                displayDirection = {
                    order = 40,
                    name = L["Direction"],
                    desc = L["Direction from Anchor"],
                    type = "select",
                    values = opt_directions,
                    arg = "direction"
                },
                maxButtons = {
                    order = 50,
                    name = L["Max Buttons"],
                    desc = L["Maximal number of Buttons to display."],
                    type = "input",
                    arg = "maxbuttons",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors.items[k.arg] = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors.items[k.arg]) end,
                },
                dummy_60 = { -- Need another line break :)
                    order = 60,
                    type = "description",
                    name = "",
                },
                buttonScale = {
                    order = 70,
                    name = L["Button Scale"],
                    desc = L["Button scaling, this lets you enlarge or shrink your Buttons."],
                    type = "range",
                    min = 0.5, max = 2.5, step = 0.05,
                    arg = "scale",
                },
                buttonAlpha = {
                    order = 80,
                    name = L["Button Alpha"],
                    desc = L["Icon alpha value, this lets you change the transparency of the Button."],
                    type = "range",
                    min = 0.1, max = 1, step = 0.05,
                    arg = "alpha",
                },
                dummy2 = { -- Need another line break :)
                    order = 90,
                    type = "description",
                    name = "",
                },
                buttonPadding = {
                    order = 100,
                    name = L["Button Padding"],
                    desc = L["Space Between Buttons."],
                    type = "input",
                    arg = "buttonPadding",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors.items[k.arg] = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors.items[k.arg]) end,
                },
                textPadding = {
                    order = 110,
                    name = L["Text Distance"],
                    desc = L["Distance of Text to Button."],
                    type = "input",
                    arg = "textPadding",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors.items[k.arg] = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors.items[k.arg]) end,
                },
                dummy_120 = { -- Need another line break :)
                    order = 120,
                    type = "description",
                    name = "",
                },
                textSettings = {
                    order = 130,
                    name = L["Use Text Settings"],
                    desc = L["Toggle using extra Text Settings."],
                    type = "toggle",
                    arg = "textSettings",
                },
                textSide = {
                    disabled = function() return not db.anchors.items.textSettings end,
                    order = 140,
                    name = L["Text Side"],
                    desc = L["Text Side from Button"],
                    type = "select",
                    values = opt_text_directions,
                    arg = "textSide"
                },
                dummy3 = { -- Need another line break :)
                    order = 150,
                    type = "description",
                    name = "",
                },
                textScale = {
                    disabled = function() return not db.anchors.items.textSettings end,
                    order = 160,
                    name = L["Text Scale"],
                    desc = L["Text scaling, this lets you enlarge or shrink your Text."],
                    type = "range",
                    min = 0.5, max = 2.5, step = 0.05,
                    arg = "textScale",
                },
                textAlpha = {
                    disabled = function() return not db.anchors.items.textSettings end,
                    order = 170,
                    name = L["Text Alpha"],
                    desc = L["Text alpha value, this lets you change the transparency of the Text."],
                    type = "range",
                    min = 0.1, max = 1, step = 0.05,
                    arg = "textAlpha",
                },
            },
        },
        cooldownsSoon = {
            type = "group",
            name = L["Expiring Cooldowns"],
            order = 70,
            hidden = function() return not db.splitSoon end,
            set = function( k, v ) db.anchors.soon[k.arg] = v; CoolDownButtonsConfig:UpdateConfig(); end,
            get = function( k ) return db.anchors.soon[k.arg] end,
            args = {
                showAnchor = {
                    order = 0,
                    name = L["Show Anchor"],
                    desc = L["Toggle showing Anchor."],
                    type = "toggle",
                    arg = "show",
                },
                centerToAnchor = {
                    order = 1,
                    name = L["Center from Anchor"],
                    desc = L["Toggle Anchor to be the Center of the bar."],
                    type = "toggle",
                    arg = "center",
                }, dummy_1 = { order = 2, type = "description", name = "", },
                showOmniCC = {
                    order = 3,
                    disabled = function() return CoolDownButtons.noOmniCC end,
                    name = L["Enable OmniCC Settings"],
                    desc = L["Toggle use OmniCC settings instead of own. (Pulse effect/Timer/Cooldown Spiral)"],
                    type = "toggle",
                    arg = "showOmniCC",
                },
                showTime = {
                    order = 4,
                    name = L["Show Time"],
                    desc = L["Toggle showing Cooldown Time at the Buttons."],
                    type = "toggle",
                    arg = "showTime",
                }, dummy_5 = { order = 5, type = "description", name = "", },
                usePulse = {
                    order = 6,
                    name = L["Use Pulse effect"],
                    desc = L["Toggle Pulse effect."],
                    disabled = function() return db.anchors.soon.showOmniCC end,
                    type = "toggle",
                    arg = "usePulse",
                }, 
                showCoolDownSpiral = {
                    order = 7,
                    disabled = function() return db.anchors.soon.showOmniCC end,
                    name = L["Show CoolDown Spiral"],
                    desc = L["Toggle showing CoolDown Spiral on the Buttons."],
                    type = "toggle",
                    arg = "showCoolDownSpiral",
                },dummy_8 = { order = 8, type = "description", name = "", },
                timeToSplit = {
                    order = 10,
                    name = L["Show X seconds before ready"],
                    desc = L["Sets the time in seconds when the Cooldown should switch to this bar."],
                    type = "input",
                    arg = "timeToSplit",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors.soon[k.arg] = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors.soon[k.arg]) end,
                }, dummy_2 = { order = 11, type = "description", name = "", },
                xpos = {
                    order = 20,
                    name = L["X - Axis"],
                    desc = L["Set the Position on X-Axis."],
                    type = "input",
                    arg = "soon",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors[k.arg].pos.x = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors[k.arg].pos.x) end,
                },
                ypos = {
                    order = 30,
                    name = L["Y - Axis"],
                    desc = L["Set the Position on Y-Axis."],
                    type = "input",
                    arg = "soon",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors[k.arg].pos.y = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors[k.arg].pos.y) end,
                },
                dummy0 = { -- Need another line break :)
                    order = 50,
                    type = "description",
                    name = "",
                },
                displayDirection = {
                    order = 60,
                    name = L["Direction"],
                    desc = L["Direction from Anchor"],
                    type = "select",
                    values = opt_directions,
                    arg = "direction"
                },
                maxButtons = {
                    order = 70,
                    name = L["Max Buttons"],
                    desc = L["Maximal number of Buttons to display."],
                    type = "input",
                    arg = "maxbuttons",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors.soon[k.arg] = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors.soon[k.arg]) end,
                },
                dummy_80 = { -- Need another line break :)
                    order = 80,
                    type = "description",
                    name = "",
                },
                buttonScale = {
                    order = 90,
                    name = L["Button Scale"],
                    desc = L["Button scaling, this lets you enlarge or shrink your Buttons."],
                    type = "range",
                    min = 0.5, max = 2.5, step = 0.05,
                    arg = "scale",
                },
                buttonAlpha = {
                    order = 100,
                    name = L["Button Alpha"],
                    desc = L["Icon alpha value, this lets you change the transparency of the Button."],
                    type = "range",
                    min = 0.1, max = 1, step = 0.05,
                    arg = "alpha",
                },
                dummy2 = { -- Need another line break :)
                    order = 110,
                    type = "description",
                    name = "",
                },
                buttonPadding = {
                    order = 120,
                    name = L["Button Padding"],
                    desc = L["Space Between Buttons."],
                    type = "input",
                    arg = "buttonPadding",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors.soon[k.arg] = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors.soon[k.arg]) end,
                },
                textPadding = {
                    order = 130,
                    name = L["Text Distance"],
                    desc = L["Distance of Text to Button."],
                    type = "input",
                    arg = "textPadding",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors.soon[k.arg] = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors.soon[k.arg]) end,
                },
                dummy1 = { -- Need another line break :)
                    order = 140,
                    type = "description",
                    name = "",
                },
                textSettings = {
                    order = 150,
                    name = L["Use Text Settings"],
                    desc = L["Toggle using extra Text Settings."],
                    type = "toggle",
                    arg = "textSettings",
                },
                textSide = {
                    disabled = function() return not db.anchors.soon.textSettings end,
                    order = 160,
                    name = L["Text Side"],
                    desc = L["Text Side from Button"],
                    type = "select",
                    values = opt_text_directions,
                    arg = "textSide"
                },
                dummy3 = { -- Need another line break :)
                    order = 170,
                    type = "description",
                    name = "",
                },
                textScale = {
                    disabled = function() return not db.anchors.soon.textSettings end,
                    order = 180,
                    name = L["Text Scale"],
                    desc = L["Text scaling, this lets you enlarge or shrink your Text."],
                    type = "range",
                    min = 0.5, max = 2.5, step = 0.05,
                    arg = "textScale",
                },
                textAlpha = {
                    disabled = function() return not db.anchors.soon.textSettings end,
                    order = 190,
                    name = L["Text Alpha"],
                    desc = L["Text alpha value, this lets you change the transparency of the Text."],
                    type = "range",
                    min = 0.1, max = 1, step = 0.05,
                    arg = "textAlpha",
                },
            },
        },
        cooldownsSingle = {
            type = "group",
            name = L["Seperated Cooldowns"],
            order = 80,
            set = function( k, v ) db.anchors.single[k.arg] = v; CoolDownButtonsConfig:UpdateConfig(); end,
            get = function( k ) return db.anchors.single[k.arg] end,
            args = {
                showOmniCC = {
                    order = 3,
                    disabled = function() return CoolDownButtons.noOmniCC end,
                    name = L["Enable OmniCC Settings"],
                    desc = L["Toggle use OmniCC settings instead of own. (Pulse effect/Timer/Cooldown Spiral)"],
                    type = "toggle",
                    arg = "showOmniCC",
                },
                showTime = {
                    order = 4,
                    name = L["Show Time"],
                    desc = L["Toggle showing Cooldown Time at the Buttons."],
                    type = "toggle",
                    arg = "showTime",
                }, dummy_5 = { order = 5, type = "description", name = "", },
                usePulse = {
                    order = 6,
                    name = L["Use Pulse effect"],
                    desc = L["Toggle Pulse effect."],
                    disabled = function() return db.anchors.single.showOmniCC end,
                    type = "toggle",
                    arg = "usePulse",
                }, 
                showCoolDownSpiral = {
                    order = 7,
                    disabled = function() return db.anchors.single.showOmniCC end,
                    name = L["Show CoolDown Spiral"],
                    desc = L["Toggle showing CoolDown Spiral on the Buttons."],
                    type = "toggle",
                    arg = "showCoolDownSpiral",
                },dummy_8 = { order = 8, type = "description", name = "", },
                buttonScale = {
                    order = 40,
                    name = L["Button Scale"],
                    desc = L["Button scaling, this lets you enlarge or shrink your Buttons."],
                    type = "range",
                    min = 0.5, max = 2.5, step = 0.05,
                    arg = "scale",
                },
                buttonAlpha = {
                    order = 50,
                    name = L["Button Alpha"],
                    desc = L["Icon alpha value, this lets you change the transparency of the Button."],
                    type = "range",
                    min = 0.1, max = 1, step = 0.05,
                    arg = "alpha",
                },
                dummy2 = { -- Need another line break :)
                    order = 60,
                    type = "description",
                    name = "",
                },
                textPadding = {
                    order = 80,
                    name = L["Text Distance"],
                    desc = L["Distance of Text to Button."],
                    type = "input",
                    arg = "textPadding",
                    set = function( k, v ) if not (tonumber(v) == nil) then db.anchors.single[k.arg] = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                    get = function( k ) return tostring(db.anchors.single[k.arg]) end,
                },
                dummy1 = { -- Need another line break :)
                    order = 90,
                    type = "description",
                    name = "",
                },
                textSettings = {
                    order = 100,
                    name = L["Use Text Settings"],
                    desc = L["Toggle using extra Text Settings."],
                    type = "toggle",
                    arg = "textSettings",
                },
                textSide = {
                    disabled = function() return not db.anchors.single.textSettings end,
                    order = 110,
                    name = L["Text Side"],
                    desc = L["Text Side from Button"],
                    type = "select",
                    values = opt_text_directions,
                    arg = "textSide"
                },
                dummy3 = { -- Need another line break :)
                    order = 120,
                    type = "description",
                    name = "",
                },
                textScale = {
                    disabled = function() return not db.anchors.single.textSettings end,
                    order = 130,
                    name = L["Text Scale"],
                    desc = L["Text scaling, this lets you enlarge or shrink your Text."],
                    type = "range",
                    min = 0.5, max = 2.5, step = 0.05,
                    arg = "textScale",
                },
                textAlpha = {
                    disabled = function() return not db.anchors.single.textSettings end,
                    order = 140,
                    name = L["Text Alpha"],
                    desc = L["Text alpha value, this lets you change the transparency of the Text."],
                    type = "range",
                    min = 0.1, max = 1, step = 0.05,
                    arg = "textAlpha",
                },
            },
        },
    },
}


options.args.display.args.testMode = {
 	type = "group",
    name = L["Test Mode"],
    order = 0,
	args = {
        testModeTime = {
            order = 0,
            name = L["Time to show Buttons"],
            type = "input",
            arg = "testModeTime",
            set = function( k, v ) if not (tonumber(v) == nil) then CoolDownButtons.testModeTime = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
            get = function( k ) return tostring(CoolDownButtons.testModeTime) end,
        },
        testCancle = {
            order = 1,
            type = "execute",
            name = L["Cancel Test"],
            disabled = function() return not CoolDownButtons.testMode end,
            desc = "",
            func = function() CoolDownButtons:EndTestMode(true) end,
        },
        dummy1 = {
            order = 2,
            type = "description",
            name = "",
        },
        testAll = {
            order = 3,
            type = "execute",
            name = L["Test All"],
            disabled = function() return CoolDownButtons.testMode end,
            desc = "",
            func = function() CoolDownButtons:StartTestMode({"spells","items","soon","single"}) end,
        },
        testSpells = {
            order = 4,
            type = "execute",
            name = L["Test Spells"],
            disabled = function() return CoolDownButtons.testMode end,
            desc = "",
            func = function() CoolDownButtons:StartTestMode({"spells"}) end,
        },
        dummy2 = {
            order = 5,
            type = "description",
            name = "",
        },
        testItems = {
            order = 6,
            type = "execute",
            name = L["Test Items"],
            desc = "",
            disabled = function() return not db.splitRows or CoolDownButtons.testMode end,
            func = function() CoolDownButtons:StartTestMode({"items"}) end,
        },
        testSoon = {
            order = 7,
            type = "execute",
            name = L["Test expiring Soon"],
            desc = "",
            disabled = function() return not db.splitSoon or CoolDownButtons.testMode end,
            func = function() CoolDownButtons:StartTestMode({"soon"}) end,
        }, dummy_8 = { order = 8, type = "description", name = "", },
        testSeperated = {
            order = 9,
            type = "execute",
            name = L["Test Single"],
            desc = "",
            disabled = function() return CoolDownButtons.testMode end,
            func = function() CoolDownButtons:StartTestMode({"single"}) end,
        },
    },
}
options.args.posting = {
	type = "group",
	name = L["Posting Settings"],
	order = 1,
	args = {
        enablePosting = {
            order = 0,
            name = L["Enable Chatpost"],
            desc = L["Toggle posting to Chat."],
            type = "toggle",
            arg = "chatPost",
        },
        chatPostList = {}, -- Later :)
        desc1 = {
            order = 2,
            type = "description",
            name = L["Note: Click on a Cooldown Button to post the remaining time to the above selectet Chats."],
        },
    }
}

options.args.posting.args.chatPostList = {
    type = "group",
    name = L["Post to:"],
    guiInline = true,
    order = 1,
    set = function( k, state ) db.posttochats[k.arg] = state; CoolDownButtonsConfig:UpdateConfig(); end,
    get = function( k ) return db.posttochats[k.arg] end,
    args = {
    	enablePostingSay = { arg = "say", order = 0, type = "toggle",
			name = L["Say"],
			desc = L["Toggle posting to Chat."],
        },
    	enablePostingParty = { arg = "party", order = 1, type = "toggle",
			name = L["Party"],
			desc = L["Toggle posting to Chat."],
        }, dummy1 = { order = 2, type = "description", name = "", },
    	enablePostingRaid = { arg = "raid", order = 3, type = "toggle",
			name = L["Raid"],
			desc = L["Toggle posting to Chat."],
        },
    	enablePostingGuild = { arg = "guild", order = 4, type = "toggle",
			name = L["Guild"],
			desc = L["Toggle posting to Chat."],
        }, dummy2 = { order = 5, type = "description", name = "", },
    	enablePostingOfficer = { arg = "officer", order = 6, type = "toggle",
			name = L["Officer"],
			desc = L["Toggle posting to Chat."],
        },
    	enablePostingEmote = { arg = "emote", order = 7, type = "toggle",
			name = L["Emote"],
			desc = L["Toggle posting to Chat."],
        }, dummy3 = { order = 8, type = "description", name = "", },
    	enablePostingRaidWarn = { arg = "raidwarn", order = 9, type = "toggle",
			name = L["Raidwarning"],
			desc = L["Toggle posting to Chat."],
        },
    	enablePostingBG = { arg = "battleground", order = 10, type = "toggle",
			name = L["Battleground"],
			desc = L["Toggle posting to Chat."],
        }, dummy6 = { order = 11, type = "description", name = "", },
    	enablePostingYell = { arg = "yell", order = 12, type = "toggle",
			name = L["Yell"],
			desc = L["Toggle posting to Chat."],
        },
    	enablePostingChatFrame = { arg = "chatframe", order = 13, type = "toggle",
			name = L["Default Chatframe"],
			desc = L["Toggle posting to Chat."],
        },
        desc1 = {
            order = 14,
            type = "description",
            name = L["Custom Channels:"],
        },
    	enablePostingChannel5 = { arg = "channel5", order = 15, type = "toggle",
			name = "",
			desc = L["Toggle posting to Chat."],
        },
    	enablePostingChannel6 = { arg = "channel6", order = 16, type = "toggle",
			name = "",
			desc = L["Toggle posting to Chat."],
        }, dummy7 = { order = 17, type = "description", name = "", },
    	enablePostingChannel7 = { arg = "channel7", order = 18, type = "toggle",
			name = "",
			desc = L["Toggle posting to Chat."],
        },
    	enablePostingChannel8 = { arg = "channel8", order = 19, type = "toggle",
			name = "",
			desc = L["Toggle posting to Chat."],
        }, dummy8 = { order = 20, type = "description", name = "", },
    	enablePostingChannel9 = { arg = "channel9", order = 21, type = "toggle",
			name = "",
			desc = L["Toggle posting to Chat."],
        },
    	enablePostingChannel10 = { arg = "channel10", order = 22, type = "toggle",
			name = "",
			desc = L["Toggle posting to Chat."],
            disabled = true,
        },
    },
}

options.args.posting.args.messagesettings = {
    type = "group",
	name = L["Message Settings"],
	order = 0,
	args = {
        usedefault = {
            order = 0,
            name = L["Use default Message"],
            desc = L["Toggle posting the default Message."],
            type = "toggle",
            arg = "postdefaultmsg",
        },
        desc1 = {
            order = 1,
            type = "description",
            name = CoolDownButtons:gsub(L["The default message is: |cFFFFFFFF$RemainingCoolDown|r"],
                                          "$RemainingCoolDown", L["RemainingCoolDown"]).."\n\n",
        },
        desc2 = {
            order = 2,
            type = "description",
            name = CoolDownButtons:gsub(L["If \'|cFFFFFFFF$defaultmsg|r\' is disabled use the following Text"],
                                          "$defaultmsg", L["Use default Message"]),
        },
        custommessage = {
            order = 3,
            name = L["Custom Message"],
			desc = L["Set the Text to post."],
            type = "input",
            arg  = "postcustom",
            width= "double",
        },
        desc3 = {
            order = 4,
            type = "description",
            name = L["Use |cFFFFFFFF$spell|r for spell name and |cFFFFFFFF$time|r for cooldowntime."],
        },
    },
}


options.args.savetopos = {
 	type = "group",
    name = L["Cooldown Settings"],
	order = 2,
	args = {
        maxSpellDuration = {
            order = 0,
            name = L["Max Spell Duration"],
            desc = L["Maximal Duration to show a Spell."],
            type = "input",
            arg = "maxSpellDuration",
            set = function( k, v ) if not (tonumber(v) == nil) then db[k.arg] = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
            get = function( k ) return tostring(db[k.arg]) end,
        },
        maxItemDuration = {
            order = 1,
            name = L["Max Item Duration"],
            desc = L["Maximal Duration to show a Item."],
            type = "input",
            arg = "maxItemDuration",
            set = function( k, v ) if not (tonumber(v) == nil) then db[k.arg] = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
            get = function( k ) return tostring(db[k.arg]) end,
        },
        desc3 = {
            order = 2,
            type = "description",
            name = "",
        },
    	showSpellAfterMax = {
            order = 3,
            type = "toggle",
			name = L["Show Spells later"],
			desc = L["Toggle Spells to display after remaining duration is below max duration."],
            arg = "spellShowAfterMaxDurationPassed",
        },
    	showItemsAfterMax = {
            order = 4,
            type = "toggle",
			name = L["Show Items later"],
			desc = L["Toggle Item to display after remaining duration is below max duration."],
            arg = "itemShowAfterMaxDurationPassed",
        },
        spells = {
            type = "group",
            name = L["Spell Positions"],
            order = 0,
            args = {
                desc = {
                    order = 0,
                    type = "description",
                    name = L["|cFFFFFFFFNote: The X and Y Axis are relative to your bottomleft screen cornor.|r"],
                },
            },
        },
        hidespells = {
            type = "group",
            name = L["Hide Spells"],
            order = 1,
            args = {
            },
        },
        items = {
            type = "group",
            name = L["Item Positions"],
            order = 2,
            args = {
                desc = {
                    order = 0,
                    type = "description",
                    name = L["|cFFFFFFFFNote: The X and Y Axis are relative to your bottomleft screen cornor.|r"],
                },
            },
        },
        hideitems = {
            type = "group",
            name = L["Hide Items"],
            order = 3,
            args = {
            },
        },
    },
}



local getProfilesOptionsTable
do
	local defaultProfiles
	--[[ Utility functions ]]
	-- get exisiting profiles + some default entries
	local tmpprofiles = {}
	local function getProfileList(db, common, nocurrent)
		-- clear old profile table
		local profiles = {}
		
		-- copy existing profiles into the table
		local curr = db:GetCurrentProfile()
		for i,v in pairs(db:GetProfiles(tmpprofiles)) do if not (nocurrent and v == curr) then profiles[v] = v end end
		
		-- add our default profiles to choose from
		for k,v in pairs(defaultProfiles) do
			if (common or profiles[k]) and not (k == curr and nocurrent) then
				profiles[k] = v
			end
		end
		return profiles
	end
	
	function getProfilesOptionsTable(db)
		defaultProfiles = {
			["Default"] = L["Default"],
			[db.keys.char] = L["Char:"] .. " " .. db.keys.char,
			[db.keys.realm] = L["Realm:"] .. " " .. db.keys.realm,
			[db.keys.class] = L["Class:"] .. " " .. UnitClass("player")
		}
		
		local tbl = {
			profiles = {
				type = "group",
				name = L["Profiles"],
				desc = L["Manage Profiles"],
				order = 20,
				args = {
					desc = {
						order = 1,
						type = "description",
						name = L["You can change the active profile of CoolDown Buttons, so you can have different settings for every character"] .. "\n",
					},
					descreset = {
						order = 9,
						type = "description",
						name = L["Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over."],
					},
					reset = {
						order = 10,
						type = "execute",
						name = L["Reset Profile"],
						desc = L["Reset the current profile to the default"],
						func = function() db:ResetProfile() CoolDownButtonsConfig:UpdateConfig(); end,
					},
					choosedesc = {
						order = 21,
						type = "description",
						name = "\n" .. L["You can create a new profile by entering a new name in the editbox, or choosing one of the already exisiting profiles."],
					},
					new = {
						name = L["New"],
						desc = L["Create a new empty profile."],
						type = "input",
						order = 30,
						get = function() return false end,
						set = function(info, value) db:SetProfile(value) end,
					},
					choose = {
						name = L["Current"],
						desc = L["Select one of your currently available profiles."],
						type = "select",
						order = 40,
						get = function() return db:GetCurrentProfile() end,
						set = function(info, value) db:SetProfile(value) CoolDownButtonsConfig:UpdateConfig(); end,
						values = function() return getProfileList(db, true) end,
					},
					deldesc = {
						order = 70,
						type = "description",
						name = "\n" .. L["Delete existing and unused profiles from the database"],
					},
					delete = {
						order = 80,
						type = "select",
						name = L["Delete a Profile"],
						desc = L["Deletes a profile from the database."],
						get = function() return false end,
						set = function(info, value) db:DeleteProfile(value) end,
						values = function() return getProfileList(db, nil, true) end,
						confirm = true,
						confirmText = L["Are you sure you want to delete the selected profile?"],
					},
				},
			},
		}
		return tbl
	end
end

function CoolDownButtonsConfig:InitPositions(state)

    local spells_table     = options.args.savetopos.args.spells.args
    local hidespells_table = options.args.savetopos.args.hidespells.args
    local items_table      = options.args.savetopos.args.items.args
    local hideitems_table  = options.args.savetopos.args.hideitems.args
    for k in pairs(spells_table)     do spells_table[k]     = nil; end
    for k in pairs(hidespells_table) do hidespells_table[k] = nil; end
    for k in pairs(items_table)      do spells_table[k]     = nil; end
    for k in pairs(hideitems_table)  do spells_table[k]     = nil; end
    
    local idx = 1
    for name, data in sortedpairs(db.saveToPos) do
        if type(data) == "table" then
            local arg = {
                type = "group",
                name = name,
                guiInline = true,
                order = idx,
                args = {
                    savethis = {
                        name  = CoolDownButtons:gsub(L["Save |cFFFFFFFF$obj|r to a consistent Position"], "$obj", name),
                        desc  = CoolDownButtons:gsub(L["Toggle saving of |cFFFFFFFF$obj|r."], "$obj", name),
                        arg   = name,
                        order = 0,
                        width = "full",
                        type  = "toggle",
                        set = function( k, state ) db.saveToPos[k.arg].saved = state; CoolDownButtonsConfig:UpdateConfig(); end,
                        get = function( k ) return db.saveToPos[k.arg].saved end,
                    },
                    xpos = {
                        order = 1,
                        name = L["X - Axis"],
                        desc = L["Set the Position on X-Axis."],
                        type = "input",
                        arg = name,
                        set = function( k, v ) if not (tonumber(v) == nil) then db.saveToPos[k.arg].pos.x = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                        get = function( k ) return tostring(db.saveToPos[k.arg].pos.x) end,
                    },
                    ypos = {
                        order = 2,
                        name = L["Y - Axis"],
                        desc = L["Set the Position on Y-Axis."],
                        type = "input",
                        arg = name,
                        set = function( k, v ) if not (tonumber(v) == nil) then db.saveToPos[k.arg].pos.y = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end,
                        get = function( k ) return tostring(db.saveToPos[k.arg].pos.y) end,
                    }, dummy = { order = 3, type = "description", name = "", },
					move = {
						order = 4,
						type = "execute",
						name = L["Move"],
                        arg = name,
						func = function(k) CoolDownButtonsConfig:ShowFrameToMoveSavedCD(k.arg) end,
					},
					stopmove = {
						order = 5,
						type = "execute",
						name = L["Stop"],
						disabled = true,
                        arg = name,
						func = function(k) CoolDownButtonsConfig:HideFrameToMoveSavedCD(k.arg) CoolDownButtonsConfig:UpdateConfig(); end,
					},
                },
            }
            if data.cdtype == "spell" then
                options.args.savetopos.args.spells.args["obj"..idx] = arg
                options.args.savetopos.args.hidespells.args["obj"..idx] = {
                    order = idx,
                    type = "toggle",
                    name = CoolDownButtons:gsub(L["Show |cFFFFFFFF$obj|r"], "$obj", name),
                    desc = CoolDownButtons:gsub(L["Toggle to display |cFFFFFFFF$obj|r's CoolDown."], "$obj", name),
                    set = function( k, state ) db.saveToPos[k.arg].show = state; CoolDownButtonsConfig:UpdateConfig(); end,
                    get = function( k ) return db.saveToPos[k.arg].show end,
                    arg = name,
                }
            else
                options.args.savetopos.args.items.args["obj"..idx] = arg
                options.args.savetopos.args.hideitems.args["obj"..idx] = {
                    order = idx,
                    type = "toggle",
                    name = CoolDownButtons:gsub(L["Show |cFFFFFFFF$obj|r"], "$obj", name),
                    desc = CoolDownButtons:gsub(L["Toggle to display |cFFFFFFFF$obj|r's CoolDown."], "$obj", name),
                    set = function( k, state ) db.saveToPos[k.arg].show = state; CoolDownButtonsConfig:UpdateConfig(); end,
                    get = function( k ) return db.saveToPos[k.arg].show end,
                    arg = name,
                }
            end
            idx = idx + 1
        end
    end
    if state ~= "initial" then
        LibStub("AceConfigRegistry-3.0"):NotifyChange("CoolDown Buttons")
    end
end

function CoolDownButtonsConfig:OnInitialize()
	db = CoolDownButtons.db.profile

    self:InitPositions("initial")
    
    options.plugins["profiles"] = getProfilesOptionsTable(CoolDownButtons.db)
	self.options = options
    self:CHANNEL_UI_UPDATE() -- Force Update Channellist for the first time :)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("CoolDown Buttons", options)
	self:RegisterChatCommand("cdb", function() LibStub("AceConfigDialog-3.0"):Open("CoolDown Buttons") end)
	self:RegisterChatCommand("cooldownbuttons", function() LibStub("AceConfigDialog-3.0"):Open("CoolDown Buttons") end)
    self:RegisterMessage("CoolDownButtonsConfigChanged")
    self:RegisterMessage("CoolDownButtonsTestModeEnd")
    self:RegisterEvent("CHANNEL_UI_UPDATE")
    
    self.moveableframe = nil
end

function CoolDownButtonsConfig:UpdateConfig()
	self:SendMessage("CoolDownButtonsConfigChanged")
end
function CoolDownButtonsConfig:CoolDownButtonsTestModeEnd()
    LibStub("AceConfigRegistry-3.0"):NotifyChange("CoolDown Buttons")
end

function CoolDownButtonsConfig:ShowFrameToMoveSavedCD(name)
    if not self.moveableframe then
        self:createMovableFrame()
    end
	self.moveableframe:Show() 
	self.moveableframe.cooldown.textFrame.text:Show()
    self.moveableframe:ClearAllPoints() 
	self.moveableframe:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.saveToPos[name].pos.x, db.saveToPos[name].pos.y) 
    local items = options.args.savetopos.args.items.args
    for k, v in pairs(items) do
        if k ~= "desc" then
            items[k].args.move.disabled = true
            if items[k].args.stopmove.arg == name then
                items[k].args.stopmove.disabled = false
            else
                items[k].args.stopmove.disabled = true
            end
        end
    end
    local spells = options.args.savetopos.args.spells.args
    for k, v in pairs(spells) do
        if k ~= "desc" then
            spells[k].args.move.disabled = true
            if spells[k].args.stopmove.arg == name then
                spells[k].args.stopmove.disabled = false
            else
                spells[k].args.stopmove.disabled = true
            end
        end
    end
end
function CoolDownButtonsConfig:HideFrameToMoveSavedCD(name)
	self.moveableframe:Hide()
	self.moveableframe.cooldown.textFrame.text:Hide()
    
    db.saveToPos[name].pos.x = tonumber(string_format("%.3f", self.moveableframe:GetLeft()))
    db.saveToPos[name].pos.y = tonumber(string_format("%.3f", self.moveableframe:GetBottom()))
    
    local items = options.args.savetopos.args.items.args
    for k, v in pairs(items) do
        if k ~= "desc" then
            items[k].args.move.disabled     = false
            items[k].args.stopmove.disabled = true
        end
    end
    local spells = options.args.savetopos.args.spells.args
    for k, v in pairs(spells) do
        if k ~= "desc" then
            spells[k].args.move.disabled     = false
            spells[k].args.stopmove.disabled = true
        end
    end
end

function CoolDownButtonsConfig:CoolDownButtonsConfigChanged()
	db = CoolDownButtons.db.profile
end

function CoolDownButtonsConfig:CHANNEL_UI_UPDATE()
    local chanlist = self.options.args.posting.args.chatPostList.args
    for i = 5, 10 do
        local channame = tostring(select(2,GetChannelName(i)))
        if not (channame == "nil") then
            chanlist["enablePostingChannel"..i].name = CoolDownButtons:gsub("(/"..i..") |cFFFFFFFF$defaultmsg|r", "$defaultmsg", channame )
            chanlist["enablePostingChannel"..i].disabled = false
        else 
            chanlist["enablePostingChannel"..i].name = "(/"..i..") No Channel"
            chanlist["enablePostingChannel"..i].disabled = true
            db.posttochats["channel"..i] = false -- Channel does not exist, so dont post here :P
        end
    end
    LibStub("AceConfigRegistry-3.0"):NotifyChange("CoolDown Buttons")
end

function CoolDownButtonsConfig:createMovableFrame()
    self.moveableframe = CoolDownButtons:createButton(-1, justMove)
    self.moveableframe:SetMovable(true);
    self.moveableframe:RegisterForDrag("LeftButton", "RightButton")
    self.moveableframe:RegisterForClicks("AnyDown")
    self.moveableframe:SetScript("OnDragStart", function(self) self:StartMoving() end)
    self.moveableframe:SetScript("OnDragStop",  function(self) self:StopMovingOrSizing(); end)
    self.moveableframe:SetFrameStrata("HIGH")
    self.moveableframe:Hide()
end
