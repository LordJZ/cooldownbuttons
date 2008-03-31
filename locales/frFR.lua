local L = LibStub("AceLocale-3.0"):NewLocale("CoolDown Buttons","frFR")
if not L then return end

-- core.lua
L["Click to Move"] = "Cliquer pour déplacer"
L["RemainingCoolDown"] = "$spell en recharge pour $time."

L["Spellgroup: Divine Shields"] = "Groupe de sorts : boucliers divins"
L["Spellgroup: Shocks"] = "Groupe de sorts : horions"
L["Spellgroup: Traps"] = "Groupe de sorts : pièges"

L["Click to Post Cooldown"] = "Cliquez pour annoncer le temps de recharge"

L["Cooldown on $obj ready!"] = "$obj prêt !"

-- config.lua
L["Display Settings"] = "Réglages d'affichage"
L["Direction"] = "Direction"
L["Direction from Anchor"] = "Direction depuis l'ancre"

L["Font Color"] = "Couleur de la police"
L["Color of the CoolDown Timer Font."] = "Couleur du texte de temps restant."
L["Font size"] = "Taille de la police"
L["Set the Font size."] = "Définit la taille de la police."
L["Center from Anchor"] = "Centrer"
L["Toggle Anchor to be the Center of the bar."] = "Active l'utilisation de l'ancre comme centre de la barre"
L["Show CoolDown Spiral"] = "Spirale de rechargement"
L["Toggle showing CoolDown Spiral on the Buttons."] = "Active l'affichage de la spirale sur les boutons."
L["Use Pulse effect"] = "Effet 'pulsation'"
L["Toggle Pulse effect."] = "Active l'animation à la fin du rechargement."
L["Enable OmniCC Settings"] = "Réglages d'OmniCC"
L["Toggle use OmniCC settings instead of own. (Pulse effect/Timer/Cooldown Spiral)"] = "Utilise les réglages d'OmniCC plutôt que ceux de CoolDownButtons."
L["Timertext Style"] = "Style du temps restant"
L["Use timed colors"] = "Coloration selon temps"
L["Font Color below 20 seconds"] = "Moins de 20 secondes"
L["Color of the CoolDown Timer Font for Cooldowns below 20 seconds."] = "Couleur du temps restant lorsqu'il inférieur à 20 secondes"
L["Font Color below 5 seconds"] = "Moins de 5 secondes"
L["Color of the CoolDown Timer Font for Cooldowns below 5 seconds."] = "Couleur du temps restant lorsqu'il inférieur à 5 secondes"

L["Split Item Cooldowns"] = "Séparer les objets"
L["Toggle showing Item and Spell Cooldowns as own rows or not."] = "Active l'affichage séparé des objets et des sorts."
L["Split expiring Cooldown"] = "Séparer les rechargements"
L["Toggle showing Item and Spell Cooldowns in an additional row if they are expiring soon."] = "Active l'affichage séparé des rechargements qui se terminent."
L["Spell Cooldowns"] = "Rechargement des sorts"
L["Item Cooldowns"] = "Rechargement des objets"
L["Seperated Cooldowns"] = "Rechargement séparés"
L["Announcements"] = "Annonces"

L["Show Anchor"] = "Affiche l'ancre"
L["Toggle showing Anchor."] = "Active l'affichage de l'ancre"
L["Max Buttons"] = "Nombre maximal"
L["Maximal number of Buttons to display."] = "Nombre maximal de boutons à afficher."
L["Button Scale"] = "Echelle"
L["Button scaling, this lets you enlarge or shrink your Buttons."] = "Echelle d'affichage des boutons"
L["Button Alpha"] = "Transparence"
L["Icon alpha value, this lets you change the transparency of the Button."] = "Valeur alpha des boutons, permet de changer la transparence."


L["Test Mode"] = "Mode de test"
L["Cancel Test"] = "Annuler le test"
L["Time to show Buttons"] = "Durée des boutons"
L["Test All"] = "Tester tout"
L["Test Spells"] = "Tester les sorts"
L["Test Items"] = "Tester les objets"
L["Test expiring Soon"] = "Tester les rechargements expirés"
L["Test Single"] = "Tester un seul"

L["Posting Settings"] = "Réglages de discussion"
L["Post to:"] = "Poster sur :"
L["Enable Chatpost"] = "Annoncer sur le chat"
L["Toggle posting to Chat."] = "Active les annonces sur les canaux de discussions."

L["Message Settings"] = "Réglages du message"
L["Use default Message"] = "Message par défaut"
L["Toggle posting the default Message."] = "Active l'utilisation du message par défaut"
L["Custom Message"] = "Message personnalisé"
L["Set the Text to post."] = "Définit le texte à poster."
L["The default message is: |cFFFFFFFF$RemainingCoolDown|r"] = "Le message par défaut est : |cFFFFFFFF$RemainingCoolDown|r"
L["Use |cFFFFFFFF$spell|r for spell name and |cFFFFFFFF$time|r for cooldowntime."] = "Utiliser |cFFFFFFFF$spell|r pour le nom du sort et |cFFFFFFFF$time|r le temps restant."
L["If \'|cFFFFFFFF$defaultmsg|r\' is disabled use the following Text"] = "Si \'|cFFFFFFFF$defaultmsg|r\' est désactive, utiliser le texte suivant"

L["Up"]    = "Haut"
L["Down"]  = "Bas"
L["Left"]  = "Gauche"
L["Right"] = "Droite"

L["Above"] = "Au-dessus"
L["Below"] = "En-dessous"
L["Font"] = "Police"

L["Use Text Settings"] = "Réglages du texte"
L["Show Time"] = "Afficher le temps"
L["Toggle showing Cooldown Time at the Buttons."] = "Active l'affichage du temps restant sur les boutons"
L["Toggle using extra Text Settings."] = "Active l'utilisation des réglages spécifiques pour les textes."
L["Text Side"] = "Position"
L["Text Side from Button"] = "Position du texte par rapport au bouton"
L["Text Scale"] = "Echelle"
L["Text scaling, this lets you enlarge or shrink your Text."] = "Définit l'échelle d'affichage du texte, pour l'agrandir ou le rétrecir."
L["Text Alpha"] = "Transparence"
L["Text alpha value, this lets you change the transparency of the Text."] = "Définit l'alpha du texte, pour le rendre transparent."
L["Button Spaceing"] = "Espacement des boutons"
L["Space Between Buttons."] = "Définit l'espacement entre les boutons."
L["Text Distance"] = "Distance du texte"
L["Distance of Text to Button."] = "Définit l'espacement entre le texte et son bouton."
L["Show X seconds before ready"] = "Afficher X secondes"
L["Sets the time in seconds when the Cooldown should switch to this bar."] = "Temps maximum d'un rechargement pour être affiché sur cette barre."
L["Expiring Cooldowns"] = "Rechargement"

L["Default Chatframe"] = "Fenêtre de discussion par défaut"
L["Say"]     = "Dire"
L["Party"]   = "Groupe"
L["Raid"]    = "Raid"
L["Guild"]   = "Guilde"
L["Officer"] = "Officier"
L["Emote"] = "Emote"
L["Raidwarning"] = "Alerte de raid"
L["Battleground"] = "Champ de bataille"
L["Yell"] = "Crier"
L["Custom Channels:"] = "Canaux personnalisés :"
L["Note: Click on a Cooldown Button to post the remaining time to the above selectet Chats."] = "Note : cliquez sur un bouton pour annoncer le temps restant sur les canaux sélectionnés."

L["Default"] = "Défaut"
L["Char:"] = "Personnage :"
L["Realm:"] = "Royaume :"
L["Class:"] = "Classe :"
L["Profiles"] = "Profils"
L["Manage Profiles"] = "Gère les profils"
--L["You can change the active profile of CoolDown Buttons, so you can have different settings for every character"] = true
--L["Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over."] = true
--L["Reset Profile"] = true
--L["Reset the current profile to the default"] = true
--L["You can create a new profile by entering a new name in the editbox, or choosing one of the already exisiting profiles."] = true
--L["New"] = true
--L["Create a new empty profile."] = true
--L["Current"] = true
--L["Select one of your currently available profiles."] = true
--L["Delete existing and unused profiles from the database"] = true
--L["Delete a Profile"] = true
--L["Deletes a profile from the database."] = true
--L["Are you sure you want to delete the selected profile?"] = true

--L["Cooldown Settings"] = true
--L["Max Spell Duration"] = true
--L["Maximal Duration to show a Spell."] = true
--L["Max Item Duration"] = true
--L["Maximal Duration to show a Item."] = true
--L["Show Spells later"] = true
--L["Toggle Spells to display after remaining duration is below max duration."] = true
--L["Show Items later"] = true
--L["Toggle Item to display after remaining duration is below max duration."] = true
--L["Spell Positions"] = true
--L["Hide Spells"] = true
--L["Item Positions"] = true
--L["Hide Items"] = true
--L["|cFFFFFFFFNote: The X and Y Axis are relative to your bottomleft screen cornor.|r"] = true
--L["Save |cFFFFFFFF$obj|r to a consistent Position"] = true
--L["Toggle saving of |cFFFFFFFF$obj|r."] = true
--L["X - Axis"] = true
--L["Set the Position on X-Axis."] = true
--L["Y - Axis"] = true
--L["Set the Position on Y-Axis."] = true
--L["Move"] = true 
--L["Stop"] = true
--L["Show |cFFFFFFFF$obj|r"] = true
--L["Toggle to display |cFFFFFFFF$obj|r's CoolDown."] = true

-- itemgroups.lua
--L["Healing Potions"] = true
--L["Mana Potions"] = true
--L["Other Potions"] = true
--L["Drums (Leatherworking)"] = true
--L["Healthstone"] = true
