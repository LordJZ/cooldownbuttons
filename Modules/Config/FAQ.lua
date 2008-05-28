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
local options = CooldownButtons:GetModule("Config").options
local L = CooldownButtons.L

options.args.faq.args.text = {
            type = "description",
            name = "|cFFA2D96FWelcome to|r |cFFCCCC00Cooldown Buttons v2.1|r\n\n"
                 .."|cFFBFBFBFRelease Notes:|r\n"
   .."|cFFA2D96F".."After some Performance issues in v2 i can proudly release v2.1\n"
                 .."the Core for handling Cooldowns and Buttons is totaly rewritten again. ;)\n\n"
           .."|r".."|cFFBFBFBFBugreports/Suggestions:|r\n"
   .."|cFFA2D96F".."For Bugreports and/or Suggestions you can contact "
                 .."me in IRC (#wowace on irc.freenode.net)\n"
                 .."or post in the official Forumthread (http://www.wowace.com/forums/index.php?topic="..GetAddOnMetadata("CooldownButtons", "X-AceForum")..")\n\n"

           .."|r".."\n\n\n\n|cFFBFBFBFLast FAQ/Info Update:|r 2008-05-28",
            order = 0,
}