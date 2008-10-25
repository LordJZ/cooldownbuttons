--[[
Name: CooldownButtons
Project Revision: @project-revision@
File Revision: @file-revision@ 
Author(s): Netrox (netrox@sourceway.eu)
Website: http://www.wowace.com/projects/cooldownbuttons/
SVN: svn://svn.wowace.com/wow/cooldownbuttons/mainline/trunk
License: All rights reserved.
]]

local _G = _G
local CooldownButtons = _G.CooldownButtons
local BarManager = CooldownButtons:NewModule("Bar Manager", "AceTimer-3.0")
local L = CooldownButtons.L
local CooldownManager = CooldownButtons:GetModule("Cooldown Manager")
local ButtonManager = CooldownButtons:GetModule("Button Manager")
local LS2 = LibStub("LibSink-2.0")

------
local newList, newDict, del, deepDel, deepCopy = CooldownButtons.GetRecyclingFunctions()
------

function BarManager:OnInitialize()
    self.bars = {"Spells", "Items", "Expiring", "Saved"}
end

function BarManager:OnEnable()
    self.db = {["G"] = CooldownButtons.db.profile,}
    for k, v in ipairs(self.bars) do
        self.db[v] = CooldownButtons:GetBarSettings(v)
    end
    self.anchorDB = {}
    
    self:ScheduleRepeatingTimer("OnUpdate",0.25)
end

function BarManager:FireSinkMessage(cooldownName, texture)
    if LS2 then
        local message = CooldownButtons:gsub(CooldownButtons.db.profile.LibSinkAnnouncmentMessage, "$cooldown", cooldownName)
        message = CooldownButtons:gsub(message, "$icon", "|T"..texture.."::|t")
        local tex = ((CooldownButtons.db.profile.LibSinkAnnouncmentShowTexture and texture) or nil)
        local c = CooldownButtons.db.profile.LibSinkAnnouncmentColor
        LS2.Pour(CooldownButtons, message, c.Red, c.Green, c.Blue, nil, nil, nil, nil, nil, tex)
    end
end

function BarManager:OnUpdate()
    for k, v in CooldownManager:IterateCooldowns() do
        if (CooldownButtons.db.profile.moveItemsToSpells and (v.bar == "Items") 
        or not CooldownButtons.db.profile.moveItemsToSpells and ((v.bar ~= "Items") and v.kind == "Item")) then
            CooldownManager:sortCooldowns()
        end
        local start, duration = _G["Get"..v.kind.."Cooldown"](v.id, BOOKTYPE_SPELL)
        local time = start + duration - GetTime()
        local _bar_ = (((v.kind == "Item") and "Items") or (((v.kind == "Spell") or (v.kind == "PetAction")) and "Spells"))
        if self.db[v.bar or _bar_].enableDurationLimit then
            if self.db[_bar_] and self.db[_bar_].showAfterLimit then
                if (v.hide and (time < self.db[_bar_].durationTime))
                or ((not v.hide) and (time > self.db[_bar_].durationTime)) then
                    CooldownManager:sortCooldowns()
                end
            else
                if ((not v.hide) and (time > self.db[_bar_].durationTime)) then
                    CooldownManager:sortCooldowns()
                end
            end
        end
        local button = ButtonManager:GetButton(v.button)
        if start+duration ~= v.endtime then
            button.cooldown:SetCooldown(start, duration)
        end
        if ((not start) or (start == 0)) or (start+duration < GetTime() ) then--hideFrame
            if not v.hide then
                if self.db[v.bar].showPulse then
                    if not button.pulseActive then
                        self:FireSinkMessage(v.name, v.tex)
                        button.pulse.cIdx = v.idx
                        button.pulse:SetScript("OnUpdate", button.pulse.pulseHandler)
                    end
                else
                    self:FireSinkMessage(v.name, v.tex)
                    CooldownManager:Remove(v.idx)
                end
            else -- Silently Remove if hidden.
                CooldownManager:Remove(v.idx)
            end
        else
            if not v.hide then
                local expiring = CooldownManager:CheckExpiring(v)
                local saved = CooldownManager:CheckSaved(v)
                if ((saved) and v.bar ~= "Saved") or ((not saved) and (v.bar == "Saved")) then
                    CooldownManager:TriggerSaved(k)
                end
                if ((expiring) and v.bar ~= "Expiring") or ((not expiring) and (v.bar == "Expiring")) then
                    CooldownManager:TriggerExpired(k)
                end
                ButtonManager:DrawButton(v, self.db[v.bar])
            elseif v.hide and ButtonManager:GetButton(v.button):IsShown() then
                ButtonManager:GetButton(v.button):Hide()
                ButtonManager:GetButton(v.button).text:Hide()
            end
        end
        if self.db[v.bar or _bar_].disableBar then
            CooldownManager:Remove(v.idx)
        end
    end
    for k, v in pairs(self.anchorDB) do
        if not ButtonManager:GetButton(self.anchorDB[k].button).movin then
            ButtonManager:DrawAnchor(self.anchorDB[k], self.db[k] or self.db[v.bar])
        end
    end
end

function BarManager:ShowAnchor(module, kind)
    local anchor, id = ButtonManager:GetButton()
    self.anchorDB[module] = newDict(
        "button", id,
        "kind", kind,
        "name", kind and module,
        "id"  , kind and module,
        "bar" , kind and "Saved"
    )
    anchor.texture:SetTexture("Interface\\Icons\\Spell_Nature_WispSplode")
    anchor:SetMovable(true)
    anchor:EnableMouse(true)
    anchor.used = true
    anchor.anchorIdx = module
    anchor:SetFrameStrata("HIGH")
    anchor.cooldown:SetCooldown(0, 0)
    anchor.text:Hide()
    ButtonManager:DrawAnchor(self.anchorDB[module], self.db[module] or self.db[self.anchorDB[module].bar])
end

function BarManager:HideAnchor(module)
    local anchor, id = ButtonManager:GetButton(self.anchorDB[module].button)
    self.anchorDB[module] = deepDel(self.anchorDB[module])
    anchor:SetMovable(false)
    anchor:EnableMouse(false)
    anchor.used = false
    anchor:SetFrameStrata("MEDIUM")
    anchor:Hide()
end
