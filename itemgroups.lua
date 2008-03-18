local LibStub = LibStub
local CoolDownButtons = LibStub("AceAddon-3.0"):GetAddon("CoolDown Buttons")
local L = LibStub("AceLocale-3.0"):GetLocale("CoolDown Buttons", false)
if not LibStub("LibPeriodicTable-3.1", true) then error("LibPeriodicTable-3.1 must be loaded before data") end

CoolDownButtons.itemgroups = {}

CoolDownButtons.itemgroups[L["Healing Potions"]] = {
    texture = "Interface\\Icons\\INV_Potion_131",
    ids = { "CDB_Itemgroup.Health", },
}

CoolDownButtons.itemgroups[L["Mana Potions"]] = {
    texture = "Interface\\Icons\\INV_Potion_137",
    ids = { "CDB_Itemgroup.Mana", },
}
	
CoolDownButtons.itemgroups[L["Other Potions"]] = {
    texture = "Interface\\Icons\\INV_Potion_47",
    ids = { 
        "CDB_Itemgroup.Resistance",
        "CDB_Itemgroup.Rage", },
}

CoolDownButtons.itemgroups[L["Healthstone"]] = {
    texture = "Interface\\Icons\\INV_Stone_04",
    ids = { "CDB_Itemgroup.Healthstone", },
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

LibStub("LibPeriodicTable-3.1"):AddData("CDB_Spellgroup", "$Rev$", {
    -- Hunter Traps
	["CDB_Spellgroup.Traps.Immolation_Trap"] = "13795:"..GetSpellInfo(13795)..",14302:"..GetSpellInfo(14302)..",14303:"..GetSpellInfo(14303)..",14304:"..GetSpellInfo(14304)..",14305:"..GetSpellInfo(14305)..",27023:"..GetSpellInfo(27023),
	["CDB_Spellgroup.Traps.Explosive_Trap"]  = "13813:"..GetSpellInfo(13813)..",14316:"..GetSpellInfo(14316)..",14317:"..GetSpellInfo(14317)..",27025:"..GetSpellInfo(27025),
	["CDB_Spellgroup.Traps.Freezing_Trap"]   = "1499:" ..GetSpellInfo(1499) ..",14310:"..GetSpellInfo(14310)..",14311:"..GetSpellInfo(14311),
	["CDB_Spellgroup.Traps.Frost_Trap"]      = "13809:"..GetSpellInfo(13809),
	["CDB_Spellgroup.Traps.Snake_Trap"]      = "34600:"..GetSpellInfo(34600),
    -- Shaman Shocks
	["CDB_Spellgroup.Shocks.Frost_Shock"]    = "8056:" ..GetSpellInfo(8056) ..",8058:" ..GetSpellInfo(8058) ..",10472:"..GetSpellInfo(10472)..",10473:"..GetSpellInfo(10473)..",25464:"..GetSpellInfo(25464),
	["CDB_Spellgroup.Shocks.Flame_Shock"]    = "8050:" ..GetSpellInfo(8050) ..",8052:" ..GetSpellInfo(8052) ..",8053:" ..GetSpellInfo(8053) ..",10447:"..GetSpellInfo(10447)..",10448:"..GetSpellInfo(10448)..",29228:"..GetSpellInfo(29228)..",25457:"..GetSpellInfo(25457),
	["CDB_Spellgroup.Shocks.Earth_Shock"]    = "8042:" ..GetSpellInfo(8042) ..",8044:" ..GetSpellInfo(8044) ..",8045:" ..GetSpellInfo(8045) ..",8046:" ..GetSpellInfo(8046) ..",10412:"..GetSpellInfo(10412)..",10413:"..GetSpellInfo(10413)..",10414:"..GetSpellInfo(10414)..",25454:"..GetSpellInfo(25454),
})
--]]

LibStub("LibPeriodicTable-3.1"):AddData("CDB_Itemgroup", "$Rev$", {
    -- Healing potions
	["CDB_Itemgroup.Health"] = "118:80,858:160,4596:160,929:320,1710:520,11562:670,3928:800,18839:800,13446:1400,31838:1400,31839:1400,31852:1400,31853:1400,28100:1400,33092:2000,23822:2000,22829:2000,32947:2000,33934:2000,"
                             .."32784:1400,32910:1400,32904:2000,32905:2000,17349:640,17348:1120,118:80,858:160,4596:160,929:320,1710:520,11562:670,3928:800,18839:800,13446:1400,31838:1400,31839:1400,31852:1400,31853:1400,"
                             .."28100:1400,33092:2000,23822:2000,22829:2000,32947:2000,33934:2000,32784:1400,32910:1400,32904:2000,32905:2000,17349:640,17348:1120",
    
    -- Mana potions
	["CDB_Itemgroup.Mana"]   = "2455:160,3385:320,3827:520,6149:800,13443:1200,18841:1200,13444:1800,31840:1800,31841:1800,31854:1800,31855:1800,28101:1800,33093:2400,23823:2400,22832:2400,32948:2400,33935:2400,31677:3200,"
                             .."32909:2400,32783:2400,32903:2400,17351:1120,17352:640,32902:2400,2455:160,3385:320,3827:520,6149:800,13443:1200,18841:1200,13444:1800,31840:1800,31841:1800,31854:1800,31855:1800,28101:1800,"
                             .."33093:2400,23823:2400,22832:2400,32948:2400,33935:2400,31677:3200,32909:2400,32783:2400,32903:2400,17351:1120,17352:640,32902:2400",
	
    -- other potions
    ["CDB_Itemgroup.Resistance"] = "13461:2600,22845:3400,32063:20,22795:1000,6049:1300,13457:2600,22841:3400,6050:1800,13456:2600,22842:3400,6051:400,22847:3400,6052:1800,13458:2600,22844:3400,6048:900,13459:2600,22846:3400",
	["CDB_Itemgroup.Rage"]       = "5631:30,5633:45,13442:45",
    
    -- Healtstones
    ["CDB_Itemgroup.Healthstone"]="5509:500,5510:800,5511:250,5512:100,9421:1200,19004:110,19005:120,19006:275,19007:300,19008:550,19009:600,19010:880,19011:960,19012:1320,19013:1440,22103:2080,22104:2288,22105:2496",
    
})