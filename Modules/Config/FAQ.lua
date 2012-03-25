--[[
Name: CooldownButtons
Project Revision: 223
File Revision: 183 
Author(s): Netrox (netrox@sourceway.eu)
Website: http://www.wowace.com/projects/cooldownbuttons/
SVN: svn://svn.wowace.com/wow/cooldownbuttons/mainline/trunk
License: All rights reserved.
]]

local CooldownButtons = _G.CooldownButtons
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