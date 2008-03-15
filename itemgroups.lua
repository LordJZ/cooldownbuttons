local CoolDownButtons = LibStub("AceAddon-3.0"):GetAddon("CoolDown Buttons")
local L = LibStub("AceLocale-3.0"):GetLocale("CoolDown Buttons", false)

CoolDownButtons.itemgroups = {}

--Consumable.Potion.Recovery.Healing.
CoolDownButtons.itemgroups[L["Healing Potions"]] = {
    texture = "Interface\\Icons\\INV_Potion_131",
    ids = {
        "Consumable.Cooldown.Potion.Health.Basic",
        "Consumable.Cooldown.Potion.Health.Blades Edge",
        "Consumable.Cooldown.Potion.Health.Coilfang",
        "Consumable.Cooldown.Potion.Health.Tempest Keep",
        "Consumable.Cooldown.Potion.Health.PvP",
        "Consumable.Potion.Recovery.Healing.Basic",
        "Consumable.Potion.Recovery.Healing.Blades Edge",
        "Consumable.Potion.Recovery.Healing.Coilfang",
        "Consumable.Potion.Recovery.Healing.Tempest Keep",
        "Consumable.Potion.Recovery.Healing.PvP", },
}
--Consumable.Potion.Recovery.Mana.Pvp
--14:30:15 1200, Consumable.Cooldown.Potion.Mana
CoolDownButtons.itemgroups[L["Mana Potions"]] = {
    texture = "Interface\\Icons\\INV_Potion_137",
    ids = {
        "Consumable.Cooldown.Potion.Mana.Basic",
        "Consumable.Cooldown.Potion.Mana.Blades Edge",
        "Consumable.Cooldown.Potion.Mana.Coilfang",
        "Consumable.Cooldown.Potion.Mana.Pvp",
        "Consumable.Cooldown.Potion.Mana.Tempest Keep",
        "Consumable.Potion.Recovery.Mana.Basic",
        "Consumable.Potion.Recovery.Mana.Blades Edge",
        "Consumable.Potion.Recovery.Mana.Coilfang",
        "Consumable.Potion.Recovery.Mana.Pvp",
        "Consumable.Potion.Recovery.Mana.Tempest Keep", },
}
	
CoolDownButtons.itemgroups[L["Other Potions"]] = {
    texture = "Interface\\Icons\\INV_Potion_47",
    ids = { 
        "Consumable.Buff.Absorb.Self.Arcane",
        "Consumable.Buff.Absorb.Self.Damage",
        "Consumable.Buff.Absorb.Self.Fire",
        "Consumable.Buff.Absorb.Self.Frost",
        "Consumable.Buff.Absorb.Self.Holy",
        "Consumable.Buff.Absorb.Self.Nature",
        "Consumable.Buff.Absorb.Self.Shadow",
        "Consumable.Buff.Rage.Self", },
}

CoolDownButtons.itemgroups[L["Healthstone"]] = {
    texture = "Interface\\Icons\\INV_Stone_04",
    ids = { "Consumable.Warlock.Healthstone", },
}
