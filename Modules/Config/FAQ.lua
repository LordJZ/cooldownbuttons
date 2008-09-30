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
            name = "|cFFA2D96FWelcome to|r |cFFCCCC00Cooldown Buttons v2.1|r\n\n\n\n"
                 .."|cFFBFBFBFFAQ:|r\n"
                 .."Q: Can you make the addon showing Bars?\n"
   .."|cFFA2D96F".."A: Nope Sorry, the addon is called Cooldown|cFFCCCC00BUTTONS|r|cFFA2D96F so it will only have buttons. :P|r"
                 .."\n\n\n\n"
                 .."|cFFBFBFBFBugreports/Suggestions:|r\n"
   .."|cFFA2D96F".."For Bugreports and/or Suggestions you can contact "
                 .."me in IRC (#wowace on irc.freenode.net)\n"
                 .."or post a comment on the Project Page at http://www.wowace.com/projects/cooldownbuttons/\n\n"

           .."|r".."\n\n|cFFBFBFBFLast FAQ/Info Update:|r 30. Sep. 08",
            order = 0,
}