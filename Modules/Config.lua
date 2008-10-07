--[[
Name: CooldownButtons
Project Revision: @project-revision@
File Revision: @file-revision@ 
Author(s): Netrox (netrox@sourceway.eu)
Website: http://www.wowace.com/projects/cooldownbuttons/
SVN: svn://svn.wowace.com/wow/cooldownbuttons/mainline/trunk
License: All rights reserved.
]]

local CooldownButtons = _G.CooldownButtons
local CooldownButtonsConfig = CooldownButtons:NewModule("Config","AceConsole-3.0","AceEvent-3.0")
local L = CooldownButtons.L
local LS2 = LibStub("LibSink-2.0")

CooldownButtonsConfig.options = {}
local options = CooldownButtonsConfig.options
local db
-- Functions
local createBarSettings

options.type = "group"
options.childGroups = "tab"
--options.name = "Cooldown Buttons r"..CooldownButtons.rev
function CooldownButtonsConfig:OnEnable()
    self.options.name = "Cooldown Buttons r"..CooldownButtons.rev
end
options.get = function( k ) return db[k.arg] end
options.set = function( k, v ) db[k.arg] = v end
options.args = {}
options.plugins = {}

options.args.barSettings = { 
    type = "group",
    name = L["Bar Settings"],
    order = 0,
    args = {},
}

options.args.cooldownSettings = {
    type = "group",
    name = L["Cooldown Settings"],
    order = 1,
    args = {},
}

if LS2 then
    options.args.announcements = {
        type = "group",
        name = L["Announcement Settings"],
        order = 2,
        args = {
        },
    }
end

options.args.faq = {
    type = "group",
    name = "FAQ/Info",
    order = 5,
    args = {},
}

local openConfigUI
function CooldownButtonsConfig:OnInitialize()
    db = CooldownButtons.db.profile

    -- Profiles Configtab
    options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(CooldownButtons.db)
    options.args.profiles.order = 4
    
    -- LibSink ConfigTab
    if LS2 then
        self:LibSinkConfig()
    end
    
    local createHeader = select(2, self:GetWidgetAPI())
    local createInput  = select(4, self:GetWidgetAPI())
    local createToggle = select(7, self:GetWidgetAPI())
    options.args.barSettings.args["general__Bar_Settings_Stuff"] = {
        type = "group",
        name = L["General Settings"],
        order = 0,
        set = function(k,v)
                if k.arg == "moveToExpTime" then
                    if not (tonumber(v) == nil) then
                        db[k.arg] = tonumber(v);
                    end
                else
                    db[k.arg] = v 
                    db.barSettings.Items.disableBar = v
                end
              end,
        get = function(k)
                if k.arg == "moveToExpTime" then
                    return tostring(db[k.arg])
                else
                    return db[k.arg]
                end
              end,
        args = {
            header_00 = createHeader(L["Item to Spells"]),
            toggleMoving = createToggle(L["Move Items to Spells Cooldown Bar"], "", "moveItemsToSpells", true, nil, nil),

            header_10 = createHeader(L["Expiring Cooldowns"]),
            expiringTime = createInput(L["Expiring Time"], L["Time when the Cooldown should be moved to Expiring Buttonbar (in seconds; 0 = never)."], "moveToExpTime"),

            header_20 = createHeader(L["Hide Pet Spells"]),
            toggleHidePet = createToggle(L["Hide Pet Spells"], "", "hidePetSpells", true, nil, nil),
        },
    }

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Cooldown Buttons", options)

    LibStub("AceConfigDialog-3.0"):SetDefaultSize("Cooldown Buttons", 700, 560)
    self:RegisterChatCommand("cdb", openConfigUI)
    self:RegisterChatCommand("CooldownButtons", openConfigUI)
end

do
    local lastPet = ""
    function openConfigUI()
        -- Setup Saved Cooldown Settings
        if not CooldownButtonsConfig.SavedCooldownsConfigIsSet then
            CooldownButtonsConfig:SavedCooldownsConfig()
        end
        -- Setup Item Cooldown Grouping Settings
        if not CooldownButtonsConfig.ItemCooldownGroupingConfigIsSet then
            CooldownButtonsConfig:ItemCooldownGroupingConfig()
        end
        -- Setup Item Cooldown Grouping Settings
        if not CooldownButtonsConfig.ChatPostAnnouncements then
            CooldownButtonsConfig:ClickAnnouncementSettings()
        end

        -- Setip Pet Cooldown Settings
        if UnitExists("playerpet") and (lastPet ~= UnitName("playerpet")) then
            lastPet = UnitName("playerpet")
            CooldownButtonsConfig.options.args.cooldownSettings.args.saved.args.petspells = nil
            CooldownButtonsConfig:SavedPetCooldownsConfig()
        elseif not UnitExists("playerpet") then
            CooldownButtonsConfig.options.args.cooldownSettings.args.saved.args.petspells = nil
            LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
        end
        
        --LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
        LibStub("AceConfigDialog-3.0"):Open("Cooldown Buttons")
    end
end
