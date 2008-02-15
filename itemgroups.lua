local CoolDownButtons = LibStub("AceAddon-3.0"):GetAddon("CoolDown Buttons")
local L = LibStub("AceLocale-3.0"):GetLocale("CoolDown Buttons", false)

CoolDownButtons.itemgroups = {}

CoolDownButtons.itemgroups[L["Healing Potions"]] = {
    texture = "Interface\\Icons\\INV_Potion_131",
    ids = { 32947, 33934, 4596,  1710,  929,  858, 17348,
            13446, 118,   22829, 17349, 3928, 28100, 32905, },
}

CoolDownButtons.itemgroups[L["Mana Potions"]] = {
    texture = "Interface\\Icons\\INV_Potion_137",
    ids = { 32948, 33935, 31677, 6149,  3385,  17351, 13444,
            3827,  2455,  22832, 17352, 13443, 28101, 32902, },
}

CoolDownButtons.itemgroups[L["Other Potions"]] = {
    texture = "Interface\\Icons\\INV_Potion_47",
    ids = { 18253, 2456, 9144, 22850, 34440, 5633,
            13442, 5631, 12190, 20002, 22836, 6048,
            6052, 22846, 22844, 22844, 22847, 22842,
            22841, 22845, 6051, 13459, 13458, 13456,
            13457, 13461, 6050, 6049, },
}

CoolDownButtons.itemgroups[L["Drums (Leatherworking)"]] = {
    texture = "Interface\\Icons\\INV_Misc_Drum_02",
    ids = { 29529, 29532, 29531, 29530, 29528, },
}

CoolDownButtons.itemgroups[L["Healthstone"]] = {
    texture = "Interface\\Icons\\INV_Stone_04",
    ids = { 5510, 19010, 19011, 5509,  19008, 19009,
            5511, 19006, 19007, 9421,  19012, 19013,
            5512, 22103, 22104, 22105, 19004, 19005, },
}
