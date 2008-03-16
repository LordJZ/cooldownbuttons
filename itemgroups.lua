local CoolDownButtons = LibStub("AceAddon-3.0"):GetAddon("CoolDown Buttons")
local L = LibStub("AceLocale-3.0"):GetLocale("CoolDown Buttons", false)

CoolDownButtons.itemgroups = {}

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




--[[ for 2.4
CoolDownButtons.spellgroups = {}
CoolDownButtons.spellgroups[L["Spellgroup: Traps"] ] = {
    name = L["Spellgroup: Traps"],
    texture = "Interface\\Icons\\Spell_Frost_ChainsOfIce",
    ids = {
        "CDB_Spellgroup.Traps.Immolation_Trap",
        "CDB_Spellgroup.Traps.Explosive_Trap",
        "CDB_Spellgroup.Traps.Freezing_Trap",
        "CDB_Spellgroup.Traps.Frost_Trap",
        "CDB_Spellgroup.Traps.Snake_Trap", },
}

CoolDownButtons.spellgroups[L["Spellgroup: Shocks"] ] = {
    name = L["Spellgroup: Shocks"],
    texture = "Interface\\AddOns\\CoolDownButtons\\shocks.tga",
    ids = {
        "CDB_Spellgroup.Shocks.Frost_Shock",
        "CDB_Spellgroup.Shocks.Flame_Shock",
        "CDB_Spellgroup.Shocks.Earth_Shock", },
}

if not LibStub("LibPeriodicTable-3.1", true) then error("PT3 must be loaded before data") end
LibStub("LibPeriodicTable-3.1"):AddData("CDB_Spellgroup", "$Rev$", {
    -- Hunter Traps
	["CDB_Spellgroup.Traps.Immolation_Trap"] = "13795:"..GetSpellInfo(13795)..",14302:"..GetSpellInfo(14302)..",14303:"..GetSpellInfo(14303)..",14304:"..GetSpellInfo(14304)..",14305:"..GetSpellInfo(14305)..",27023:"..GetSpellInfo(27023),
	["CDB_Spellgroup.Traps.Explosive_Trap"]  = "13813:"..GetSpellInfo(13813)..",14316:"..GetSpellInfo(14316)..",14317:"..GetSpellInfo(14317)..",27025:"..GetSpellInfo(27025),
	["CDB_Spellgroup.Traps.Freezing_Trap"]   = "1499:" ..GetSpellInfo(1499) ..",14310:"..GetSpellInfo(14310)..",14311:"..GetSpellInfo(14311),
	["CDB_Spellgroup.Traps.Frost_Trap"]      = "13809:"..GetSpellInfo(13809),
	["CDB_Spellgroup.Traps.Snake_Trap"]      = "34600:"..GetSpellInfo(34600),
	["CDB_Spellgroup.Shocks.Frost_Shock"]    = "8056:" ..GetSpellInfo(8056) ..",8058:" ..GetSpellInfo(8058) ..",10472:"..GetSpellInfo(10472)..",10473:"..GetSpellInfo(10473)..",25464:"..GetSpellInfo(25464),
	["CDB_Spellgroup.Shocks.Flame_Shock"]    = "8050:" ..GetSpellInfo(8050) ..",8052:" ..GetSpellInfo(8052) ..",8053:" ..GetSpellInfo(8053) ..",10447:"..GetSpellInfo(10447)..",10448:"..GetSpellInfo(10448)..",29228:"..GetSpellInfo(29228)..",25457:"..GetSpellInfo(25457),
	["CDB_Spellgroup.Shocks.Earth_Shock"]    = "8042:" ..GetSpellInfo(8042) ..",8044:" ..GetSpellInfo(8044) ..",8045:" ..GetSpellInfo(8045) ..",8046:" ..GetSpellInfo(8046) ..",10412:"..GetSpellInfo(10412)..",10413:"..GetSpellInfo(10413)..",10414:"..GetSpellInfo(10414)..",25454:"..GetSpellInfo(25454),
})
--]]