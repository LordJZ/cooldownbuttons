--[[
Name: CooldownButtons
Project Revision: 223
File Revision: 214 
Author(s): Netrox (netrox@sourceway.eu)
Website: http://www.wowace.com/projects/cooldownbuttons/
SVN: svn://svn.wowace.com/wow/cooldownbuttons/mainline/trunk
License: All rights reserved.
]]

local _G = _G
local CooldownButtons = _G.CooldownButtons
local ButtonManager = CooldownButtons:NewModule("Button Manager", "AceConsole-3.0")
local L = CooldownButtons.L
local LSM = LibStub("LibSharedMedia-3.0")
local LayoutManager = CooldownButtons:GetModule("Layout Manager")

------
local newList, newDict, del, deepDel, deepCopy = CooldownButtons.GetRecyclingFunctions()
local math_floor = math.floor
local math_ceil = math.ceil
------

local CooldownManager, BarManager
function ButtonManager:OnInitialize()
    self.db = newList()
end

function ButtonManager:OnEnable()
    -- Get Cooldown Manager Module
    CooldownManager = CooldownButtons:GetModule("Cooldown Manager")
    BarManager = CooldownButtons:GetModule("Bar Manager")
end

function ButtonManager:GetButton(id)
    if not id then
        for k, v in ipairs(self.db) do
            if v.used == false then
                return self:GetButton(k)
            end
        end
        return self:CreateButton()
    else
        if self.db[id] then
            return self.db[id], id
        end
    end
end

local pulseHandler, OnClickHandler
function ButtonManager:CreateButton()
    local i = 1 + #self.db
    self.db[i]   = CreateFrame("Button", "CooldownButton_"..i, UIParent, "ActionButtonTemplate")

    local button = self.db[i]
    button:SetClampedToScreen(true)
    button:EnableMouse(false)
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnClick", function(self) OnClickHandler(self) end)
    button:SetScript("OnDragStart", function(self) if self:IsMovable() then self.movin = true; self:StartMoving(); end end)
    button:SetScript("OnDragStop",  function(self) if self:IsMovable() then self:StopMovingOrSizing(); self:SaveAnchorPos() end end )
    button:SetScript("OnLeave",     function() GameTooltip:Hide()                         end)
    button:SetScript("OnEnter",     function(self)
                                        if not self.anchorIdx then
                                            GameTooltip:SetOwner(this, "ANCHOR_CURSOR");
                                            GameTooltip:SetText(CooldownManager.db[self.cdIdx].name)
                                        end
                                    end)
    button.SaveAnchorPos = function(self)
        local data = BarManager.anchorDB[self.anchorIdx]
        local settings = BarManager.db[self.anchorIdx] or BarManager.db[data.bar]
        if data.bar then
            CooldownManager:SetSavedPos(data, nil, nil,
                self:GetLeft()   * settings.buttonScale,  -- X
                self:GetBottom() * settings.buttonScale   -- Y
            )
        else
            settings.pos.x = self:GetLeft()   * settings.buttonScale
            settings.pos.y = self:GetBottom() * settings.buttonScale
        end
        LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
        self.movin = false
    end

    button.texture  = _G[("%sIcon"):format(button:GetName())]
    button.cooldown = _G[("%sCooldown"):format(button:GetName())]


    LayoutManager:AddElement("Cooldown Buttons", button:GetName())
    
    button.used = false
    button.cooldown.noCooldownCount = 1

    button.textFrame = CreateFrame("Frame", "CooldownButton"..i.."CooldownText", UIParent)
    button.textFrame:SetAllPoints(button)
    button.textFrame:SetFrameLevel(button.cooldown:GetFrameLevel() + 1)
    button.text = button.textFrame:CreateFontString(nil, "OVERLAY")
    button.text:SetFontObject(SystemFont)

    button.pulse = CreateFrame('Frame', nil, button)
    button.pulse:SetAllPoints(button)
    button.pulse:SetToplevel(true)
    button.pulse.icon = button:CreateTexture(nil, 'OVERLAY')
    button.pulse.icon:SetPoint('CENTER')
    button.pulse.icon:SetBlendMode('ADD')
    button.pulse.icon:SetHeight(button:GetHeight())
    button.pulse.icon:SetWidth(button:GetWidth())
    button.pulse.icon:Hide()
    button.pulse.pulseHandler = pulseHandler
    button.pulseActive = false

    return button, i
end

function pulseHandler(self, elapsed)
    local frame = self:GetParent()
    if not frame.pulseActive then
        local icon = frame.texture
        if icon and frame:IsVisible() then
            self.scale = 1
            self.icon:SetTexture(icon:GetTexture())
            local r, g, b = icon:GetVertexColor()
            self.icon:SetVertexColor(r, g, b, 0.7)
            frame.pulseActive = true
        end
    else
        if self.scale >= 2 then
            self.dec = 1
        end
        self.scale = max(min(self.scale + (self.dec and -1 or 1) * self.scale * (elapsed/0.5), 2), 1)
        if self.scale <= 1 then
            self.icon:Hide()
            self.dec = nil
            frame.pulseActive = false
            CooldownManager:Remove(self.cIdx)
            self:SetScript("OnUpdate", nil)
        else
            self.icon:Show()
            self.icon:SetHeight(self:GetHeight() * self.scale)
            self.icon:SetWidth(self:GetWidth() * self.scale)
        end
    end
end

function ButtonManager:DrawButton(data, db)
    local button = self.db[data.button]
    button:Show()
    button:ClearAllPoints()
    
    if not CooldownButtons.noOmniCC then
        if ((button.cooldown.noCooldownCount == nil and db.showOmniCC == false) or (button.cooldown.noCooldownCount == 1 and db.showOmniCC == true)) then
            if not db.showOmniCC then
                button.cooldown.noCooldownCount = 1
            else
                button.cooldown.noCooldownCount = nil
            end
            button.cooldown:SetCooldown(_G["Get"..data.kind.."Cooldown"](data.id, BOOKTYPE_SPELL))
        end
    end
    if not db.showSpiral then
        button.cooldown:SetAlpha(0)
    else
        button.cooldown:SetAlpha(1)
    end
    
    local chatPostConf = CooldownButtons.db.profile.chatPost
    if ((button.chatPostSwtich == true and chatPostConf.enableChatPost == false) or (button.chatPostSwtich == false and chatPostConf.enableChatPost == true)) or button.chatPostSwtich == nil then
        if not chatPostConf.enableChatPost then
            button.chatPostSwtich = false
            button:EnableMouse(false)
        else
            button.chatPostSwtich = true
            button:EnableMouse(true)
        end
    end

    local pos
    if CooldownManager:CheckSaved(data) then
        pos = deepCopy(CooldownManager:GetSavedPos(data))
        pos.x = pos.x / db.buttonScale
        pos.y = pos.y / db.buttonScale
    else
        -- if not showCenter then [order] else [calcuclate] end
        local centerOffset = ((not db.showCenter and data.order) or (data.order + 0.5 - (CooldownManager:GetNumPerBar(data.bar) / 2)))
        pos = self:GetPosition(data.order, centerOffset, db, CooldownManager:GetNumPerBar(data.bar))
    end
    button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", pos.x , pos.y)
    pos = del(pos)

    button:SetScale(db.buttonScale)
    button:SetAlpha(db.buttonAlpha or 1)
    self:ButtonUpdateTimer(data, db)
end

function ButtonManager:DrawAnchor(data, db)
    local button = self.db[data.button]
    button:Show()
    button:ClearAllPoints()
    local pos
    if data.bar then
        pos = deepCopy(CooldownManager:GetSavedPos(data))
        pos.x = pos.x / db.buttonScale
        pos.y = pos.y / db.buttonScale
    else
        pos = self:GetPosition(1, 1, db)
    end
    button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", pos.x , pos.y)
    pos = del(pos)
    button:SetScale(db.buttonScale)
    button:SetAlpha(1)
end

function ButtonManager:GetPosition(order, centerOffset, db, numOnBar)
    local pos = newDict("x", 0, "y", 0)
    if db.buttonMultiRow then
        if order <= db.buttonCountPerRow then
            pos.x = db.buttonSpacing * (order - 1)
            pos.y = 0
        else
            local row = math_ceil(order / db.buttonCountPerRow) -1
            pos.x = db.buttonSpacing * (order - 1 - (db.buttonCountPerRow * row))
            pos.y = db.buttonRowSpacing * row
        end
        if db.buttonMRDirection == "right-down" then
            --pos.x = pos.x
            pos.y = pos.y * (-1)
        --elseif db.buttonMRDirection == "right-up" then
            --pos.x = pos.x
            --pos.y = pos.y
        elseif db.buttonMRDirection == "left-down" then
            pos.x = pos.x * (-1)
            pos.y = pos.y * (-1)
        elseif db.buttonMRDirection == "left-up" then 
            pos.x = pos.x * (-1)
            --pos.y = pos.y
        end
        if centerOffset ~= order then
            if numOnBar <= db.buttonCountPerRow then
                pos.x = db.buttonSpacing * (centerOffset - 1)
            else
                pos.x = pos.x - db.buttonSpacing * ((db.buttonCountPerRow-1)/2)
            end
        end
    else
        pos.x = db.buttonSpacing * (centerOffset - 1)
        --pos.y = 0
        if db.buttonDirection == "left" then
            pos.x = pos.x * (-1)
            --pos.y = pos.y
        --elseif db.buttonDirection == "right" then
            --pos.x = pos.x
            --pos.y = pos.y
        elseif db.buttonDirection == "up" then
            pos.y = pos.x
            pos.x = 0
        elseif db.buttonDirection == "down" then 
            pos.y = pos.x * (-1)
            pos.x = 0
        end
    end
    pos.x = pos.x + (db.pos.x / db.buttonScale)
    pos.y = pos.y + (db.pos.y / db.buttonScale)
    return pos
end

local formatTime
function ButtonManager:ButtonUpdateTimer(data, db)
    local button = self.db[data.button]
    if db.showTime and not db.showOmniCC then
        local start, duration = _G["Get"..data.kind.."Cooldown"](data.id, BOOKTYPE_SPELL)
        local time = start + duration - GetTime()
        button.text:Show()
        local c = db.fontColorBase
        if db.triggerColorFlash and (time <= db.colorFlashStartTime) then
            if (math_floor(time) % 2) == 0 then
                c = db.fontColorFlash1
            else
                c = db.fontColorFlash2
            end
        end

        button.text:ClearAllPoints()
        if db.textDirection == "left" then
            button.text:SetPoint("RIGHT", button, "CENTER", -(db.textDistance), 0)
            button.text:SetJustifyH("RIGHT") 
        elseif db.textDirection == "right" then
            button.text:SetPoint("LEFT", button, "CENTER",   db.textDistance, 0)
            button.text:SetJustifyH("LEFT") 
        elseif db.textDirection == "up" then
            button.text:SetPoint("CENTER", button, "CENTER", 1, db.textDistance)
            button.text:SetJustifyH("CENTER") 
        elseif db.textDirection == "down" then 
            button.text:SetPoint("CENTER", button, "CENTER", 1, -(db.textDistance))
            button.text:SetJustifyH("CENTER") 
        end
        button.text:SetFont(LSM:Fetch("font", db.fontFace), db.fontSize, db.fontOutline ~= "none" and db.fontOutline or nil)
        button.text:SetTextColor(c.Red, c.Green,  c.Blue)
        button.text:SetText(formatTime(time, db.textStyle))
        button.text:SetAlpha(db.textAlpha)
    else
        button.text:Hide()
    end
end

local _formatString_
function formatTime(time, mode)
    if mode == "00:00m" or mode == "00:00M" then
        if time < 3600 then
            _formatString_ = date("%M:%S", 82800 + time)
            if string.sub(_formatString_, 1, 1) == "0" then
                _formatString_ = string.sub(_formatString_, 2)
            end
            return _formatString_
        else
            _formatString_ = date("%H:%M", 82800 + time)
            if string.sub(_formatString_, 1, 1) == "0" then
                _formatString_ = string.sub(_formatString_, 2)
            end
            if mode == "00:00m" then
                return _formatString_.."h"
            else
                return _formatString_.."H"
            end
        end
    elseif mode == "0m" or mode == "0M" then
        if time < 60 then
            _formatString_ = date("%S", 82800 + time)
            if string.sub(_formatString_, 1, 1) == "0" then
                _formatString_ = string.sub(_formatString_, 2)
            end
            return _formatString_
        elseif  time < 3600  then
            _formatString_ = date("%M", 82800 + time)
            if string.sub(_formatString_, 1, 1) == "0" then
                _formatString_ = string.sub(_formatString_, 2)
            end
            if mode == "0m" then
                return _formatString_.."m"
            else
                return _formatString_.."M"
            end
        else
            _formatString_ = date("%H", 82800 + time)
            if string.sub(_formatString_, 1, 1) == "0" then
                _formatString_ = string.sub(_formatString_, 2)
            end
            if mode == "0m" then
                return _formatString_.."h"
            else
                return _formatString_.."H"
            end
        end
    end
end


function OnClickHandler(self)
    local chatPostConf = CooldownButtons.db.profile.chatPost
    if chatPostConf.enableChatPost then
        local cooldown = CooldownManager.db[self.cdIdx]

        local start, duration = _G["Get"..cooldown.kind.."Cooldown"](cooldown.id, BOOKTYPE_SPELL)
        local formated_time = formatTime(start + duration - GetTime(), "00:00m")
        local chatmsg
        if chatPostConf.postDefaultMsg then
            chatmsg = CooldownButtons:gsub(L["Cooldown on $spell active for $time."], "$spell", cooldown["name"])
            chatmsg = CooldownButtons:gsub(chatmsg, "$time", formated_time)
        else
            chatmsg = CooldownButtons:gsub(chatPostConf.chatPostMessage, "$spell", cooldown["name"])
            chatmsg = CooldownButtons:gsub(chatmsg, "$time", formated_time)
        end
        
        local postto = chatPostConf.toChat
        if postto["chatframe"] then
            DEFAULT_CHAT_FRAME:AddMessage(chatmsg)
        end
        if postto["say"] then
            SendChatMessage(chatmsg, "SAY", GetDefaultLanguage("player"))
        end
        if postto["party"] then
            if (GetNumPartyMembers() > 0) then
                SendChatMessage(chatmsg, "PARTY", GetDefaultLanguage("player"))
            end
        end
        if postto["raid"] then
            if (GetNumRaidMembers() > 0) then
                SendChatMessage(chatmsg, "RAID", GetDefaultLanguage("player"))
            end
        end
        if postto["guild"] then
            if (IsInGuild()) then
                SendChatMessage(chatmsg, "GUILD", GetDefaultLanguage("player"))
            end
        end
        if postto["officer"] then
            -- TODO: Check if you are allowed to write in /o
            SendChatMessage(chatmsg, "OFFICER", GetDefaultLanguage("player"))
        end
        if postto["emote"] then
            SendChatMessage(chatmsg, "EMOTE", GetDefaultLanguage("player"))
        end
        if postto["raidwarn"] then
            if ((GetNumRaidMembers() > 0) and IsRaidOfficer()) then
                SendChatMessage(chatmsg, "RAID_WARNING", GetDefaultLanguage("player"))
            end
        end
        if postto["battleground"] then
            if select(2, IsInInstance()) == "pvp" then
                SendChatMessage(chatmsg, "BATTLEGROUND", GetDefaultLanguage("player"))
            end
        end
        if postto["yell"] then
            SendChatMessage(chatmsg, "YELL", GetDefaultLanguage("player"))
        end
        for i = 5, 10 do
            local channame = tostring(select(2, GetChannelName(i)))
            if postto["channel"..i] and channame ~= "nil" then
                SendChatMessage(chatmsg, "CHANNEL", GetDefaultLanguage("player"), i)
            end
        end
        
    end
end
