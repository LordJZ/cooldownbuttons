local L = LibStub("AceLocale-3.0"):NewLocale("CoolDown Buttons","enUS",true)


-- core.lua
L["Click to Move"] = true
L["RemainingCoolDown"] = "Cooldown on $spell active for $time."

L["Spellgroup: Shocks"] = true
L["Earth Shock"] = true
L["Flame Shock"] = true
L["Frost Shock"] = true
L["Spellgroup: Traps"] = true
L["Freezing Trap"] = true
L["Frost Trap"] = true
L["Immolation Trap"] = true
L["Snake Trap"] = true
L["Explosive Trap"] = true


-- config.lua
L["Display Settings"] = true
L["Direction"] = true
L["Direction from Anchor"] = true


L["Split Cooldowns"] = true
L["Toggle showing Items and Spells as own Cooldown rows or not."] = true
L["Spell Cooldowns"] = true
L["Item Cooldowns"] = true
L["Seperated Cooldowns"] = true

L["Show Anchor"] = true
L["Toggle showing Anchor."] = true
L["Max Buttons"] = true
L["Maximal number of Buttons to display."] = true
L["Button Scale"] = true
L["Button scaling, this lets you enlarge or shrink your Buttons."] = true
L["Button Alpha"] = true
L["Icon alpha value, this lets you change the transparency of the Button."] = true

L["Posting Settings"] = true
L["Post to:"] = true
L["Enable Chatpost"] = true
L["Toggle posting to Chat."] = true
L["Set the Text to post."] = true

L["Message Settings"] = true
L["Use default Message"] = true
L["Toggle posting the default Message."] = true
L["Set the Text to post."] = true
L["The default message is: |cFFFFFFFF$RemainingCoolDown|r"] = true
L["Use |cFFFFFFFF$spell|r for spell name and |cFFFFFFFF$time|r for cooldowntime."] = true
L["If \'|cFFFFFFFF$defaultmsg|r\' is disabled use the following Text"] = true

L["Up"]    = true
L["Down"]  = true
L["Left"]  = true
L["Right"] = true

L["Above"] = true 
L["Below"] = true
L["Font"] = true

L["Use Text Settings"] = true
L["Toggle using extra Text Settings."] = true
L["Text Side"] = true
L["Text Side from Button"] = true
L["Text Scale"] = true
L["Text scaling, this lets you enlarge or shrink your Text."] = true
L["Text Alpha"] = true
L["Text alpha value, this lets you change the transparency of the Text."] = true
L["Button Padding"] = true
L["Space Between Buttons."] = true
L["Text Distance"] = true
L["Distance of Text to Button."] = true

L["Default Chatframe"] = true
L["Say"]     = true
L["Party"]   = true
L["Raid"]    = true
L["Guild"]   = true
L["Officer"] = true
L["Emote"] = true
L["Raidwarning"] = true
L["Battleground"] = true
L["Yell"] = true
L["Custom Channel"] = true
L["Note: Click on a Cooldown Button to post the remaining time to the above selectet Chats."] = true

L["Default"] = true
L["Char:"] = true
L["Realm:"] = true
L["Class:"] = true
L["Profiles"] = true
L["Manage Profiles"] = true
L["You can change the active profile of CoolDown Buttons, so you can have different settings for every character"] = true
L["Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over."] = true
L["Reset Profile"] = true
L["Reset the current profile to the default"] = true
L["You can create a new profile by entering a new name in the editbox, or choosing one of the already exisiting profiles."] = true
L["New"] = true
L["Create a new empty profile."] = true
L["Current"] = true
L["Select one of your currently available profiles."] = true
L["Delete existing and unused profiles from the database"] = true
L["Delete a Profile"] = true
L["Deletes a profile from the database."] = true
L["Are you sure you want to delete the selected profile?"] = true

L["Cooldown Settings"] = true
L["Max Spell Duration"] = true
L["Maximal Duration to show a Spell."] = true
L["Max Item Duration"] = true
L["Maximal Duration to show a Item."] = true
L["Show Spells later"] = true
L["Toggle Spells to display after remaining duration is below max duration."] = true
L["Show Items later"] = true
L["Toggle Item to display after remaining duration is below max duration."] = true
L["Spell Positions"] = true
L["Hide Spells"] = true
L["Item Positions"] = true
L["Hide Items"] = true
L["|cFFFFFFFFNote: The X and Y Axis are relative to your bottomleft screen cornor.|r"] = true
L["Save |cFFFFFFFF$obj|r to a consistent Position"] = true
L["Toggle saving of |cFFFFFFFF$obj|r."] = true
L["X - Axis"] = true
L["Set the Position on X-Axis."] = true
L["Y - Axis"] = true
L["Set the Position on Y-Axis."] = true
L["Move"] = true 
L["Stop"] = true
L["Show |cFFFFFFFF$obj|r"] = true
L["Toggle to display |cFFFFFFFF$obj|r's CoolDown."] = true

-- itemgroups.lua
L["Healing Potions"] = true
L["Mana Potions"] = true
L["Other Potions"] = true
L["Drums (Leatherworking)"] = true
L["Healthstone"] = true
