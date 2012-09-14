--[[
Name: CooldownButtons
Project Revision: @project-revision@
File Revision: @file-revision@ 
Author(s): Netrox (netrox@sourceway.eu)
Website: http://www.wowace.com/projects/cooldownbuttons/
SVN: svn://svn.wowace.com/wow/cooldownbuttons/mainline/trunk
License: All rights reserved.
]]

CDB_Options = CreateFrame('frame')
local CDB_Options = CDB_Options
local API = CDB_OptionsApi

CDB_Options:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

local options = {
    type = "group",
    childGroups = "tab",
    get = function( k )
                return ""
          end,
    set = function( k, v ) end,
    args = { },
}

function CDB_Options:Load()
    self.loaded = true
    self.options = options
    options.name = "Cooldown Buttons "..CDB.rev
    
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Cooldown Buttons", options)
    
    self:LoadBarSettings()
    self:LoadCooldownSettings()
    self:LoadAnnouncenentSettings()
    options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(CDB.db)
    
    -- Set correct order
    options.args.bars.order = 1
    options.args.cooldowns.order = 2
    options.args.notifications.order = 3
    options.args.profiles.order = 4


--  LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
end

function CDB_Options:Open()
    if not self.loaded then self:Load() end
    LibStub("AceConfigDialog-3.0"):SetDefaultSize("Cooldown Buttons", 635, 490)
    LibStub("AceConfigDialog-3.0"):Open("Cooldown Buttons")
end

