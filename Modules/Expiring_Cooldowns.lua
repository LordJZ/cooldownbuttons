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

local _G = _G
local CooldownButtons = _G.CooldownButtons
local CooldownButtonsExpiring = CooldownButtons:NewModule("Expiring","AceEvent-3.0")
CooldownButtonsExpiring.rev = tonumber(("$Revision$"):match("%d+")) or 0
local L = CooldownButtons.L

------
local newList, newDict, del, deepDel, deepCopy = CooldownButtons.GetRecyclingFunctions()
local string_find = string.find
------

function CooldownButtonsExpiring:OnInitialize()
    self.db = CooldownButtons.db.profile.barSettings[self:GetName()]
    CooldownButtons:GetModule("Config"):AddBarSettings(L["Expiring"], "Expiring", self.db, 30, nil)
end

function CooldownButtonsExpiring:OnEnable()
    self:InitBarEngine()
    self:InitButtonEngine()
    self:InitCooldownEngine()
    -- Fix nil Index error... (maybe-.-)
    self.itemGroups  = CooldownButtons:GetModule("Items").itemGroups
    self.spellGroups = CooldownButtons:GetModule("Spells").spellGroups
end
