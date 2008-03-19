local LibStub = LibStub
CoolDownButtons = LibStub("AceAddon-3.0"):NewAddon("CoolDown Buttons", "AceConsole-3.0", "AceEvent-3.0")
local CoolDownButtons = CoolDownButtons
local rev = tonumber(("$Revision$"):match("%d+")) or 0
CoolDownButtons.rev = rev
local L = LibStub("AceLocale-3.0"):GetLocale("CoolDown Buttons", false)
local LSM = LibStub("LibSharedMedia-2.0")
LSM:Register("font", "Skurri", [[Interface\AddOns\CoolDownButtons\skurri.ttf]])

local GetInventoryItemCooldown = GetInventoryItemCooldown
local GetContainerItemCooldown = GetContainerItemCooldown
local GetInventoryItemLink = GetInventoryItemLink
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemInfo = GetContainerItemInfo
local GetSpellCooldown = GetSpellCooldown
local GetSpellTexture = GetSpellTexture
local GetNumSpellTabs = GetNumSpellTabs
local GetSpellTabInfo = GetSpellTabInfo
local IsAddOnLoaded = IsAddOnLoaded
local string_format = string.format
local table_foreach = table.foreach
local getmetatable = getmetatable
local GetSpellName = GetSpellName
--local GetSpellLink = GetSpellLink
local table_insert = table.insert
local CreateFrame = CreateFrame
local string_gsub = string.gsub
local string_find = string.find
local table_sort = table.sort
local tostring = tostring
local tonumber = tonumber
local ceil = math.ceil
local select = select
local pairs = pairs
local type = type
local CDB_SetCooldown = getmetatable(CreateFrame('Cooldown', nil, nil, 'CooldownFrameTemplate')).__index.SetCooldown

CoolDownButtonAnchor = {}
local CoolDownButtonAnchor = CoolDownButtonAnchor
for i = 1, 3 do
    CoolDownButtonAnchor[i] = CreateFrame("Frame", "CoolDownButtonAnchor"..i, UIParent)
    CoolDownButtonAnchor[i]:SetWidth(20);      CoolDownButtonAnchor[i]:SetHeight(20)
    CoolDownButtonAnchor[i]:SetMovable(true);  CoolDownButtonAnchor[i]:EnableMouse(true); 
    CoolDownButtonAnchor[i]:SetScript("OnMouseDown", function(self) self:StartMoving()         end)
    CoolDownButtonAnchor[i]:SetScript("OnMouseUp",   function(self) self:StopMovingOrSizing(); CoolDownButtons:SaveAnchorPos(self) end)
    CoolDownButtonAnchor[i]:SetScript("OnDragStop",  function(self) self:StopMovingOrSizing(); end)
    CoolDownButtonAnchor[i]:SetScript("OnLeave",     function() GameTooltip:Hide()                         end)
    CoolDownButtonAnchor[i]:SetScript("OnEnter",     function() GameTooltip:SetOwner(this, "ANCHOR_CURSOR"); GameTooltip:SetText(L["Click to Move"]) end)
    CoolDownButtonAnchor[i]:SetClampedToScreen(true)
    CoolDownButtonAnchor[i]:SetFrameStrata("MEDIUM")
    CoolDownButtonAnchor[i]:SetFrameLevel(CoolDownButtonAnchor[i]:GetFrameLevel()+4)
    if i == 1 then
        CoolDownButtonAnchor[i].what = "spells"
    elseif i == 2 then
        CoolDownButtonAnchor[i].what = "items"
    elseif i == 3 then
        CoolDownButtonAnchor[i].what = "soon"
    end
    CoolDownButtonAnchor[i].texture = CoolDownButtonAnchor[i]:CreateTexture(nil,"OVERLAY")
    CoolDownButtonAnchor[i].texture:SetTexture("Interface\\Icons\\Spell_Nature_WispSplode")
    CoolDownButtonAnchor[i].texture:SetAllPoints(CoolDownButtonAnchor[i])
end

local cooldowns = {}
local spellTable = {}

local defaults = {
	profile = {
        font        = "Skurri",
        fontColor   = { Red = 1, Green = 1, Blue = 1, Alpha = 1, },
        fontSize    = 14,
        splitRows   = false,
        splitSoon   = false,
        anchors     = {
            spells = {
                show          = true,
                center        = false,
                usePulse      = false,
                showTime      = true,
                showCoolDownSpiral = true,
                showOmniCC    = false,
                maxbuttons    = 10,
                scale         = 1,
                alpha         = 1,
                direction     = "right",
                pos           = { x = 100, y = 300, },
                textSettings  = false,
                textSide      = "down",
                textScale     = 1,
                textAlpha     = 1,
                buttonPadding = 45,
                textPadding   = 28,
            },
            items = {
                show          = true,
                center        = false,
                usePulse      = false,
                showTime      = true,
                showCoolDownSpiral = true,
                showOmniCC    = false,
                maxbuttons    = 10,
                scale         = 1,
                alpha         = 1,
                direction     = "right",
                pos           = { x = 100, y = 250, },
                textSettings  = false,
                textSide      = "down",
                textScale     = 1,
                textAlpha     = 1,
                buttonPadding = 45,
                textPadding   = 28,
            },
            soon = {
                show          = true,
                center        = false,
                usePulse      = false,
                showTime      = true,
                showCoolDownSpiral = true,
                showOmniCC    = false,
                timeToSplit   = 5,
                maxbuttons    = 10,
                scale         = 1,
                alpha         = 1,
                direction     = "right",
                pos           = { x = 100, y = 350, },
                textSettings  = false,
                textSide      = "down",
                textScale     = 1,
                textAlpha     = 1,
                buttonPadding = 45,
                textPadding   = 28,
            },
            single = {
                usePulse      = false,
                showTime      = true,
                showCoolDownSpiral = true,
                showOmniCC    = false,
                scale         = 1,
                alpha         = 1,
                textSettings  = false,
                textSide      = "down",
                textScale     = 1,
                textAlpha     = 1,
                buttonPadding = 0,
                textPadding   = 28,
            },
        }, 
        chatPost    = false,
        posttochats = {
            ["*"] = false,
        },
        postdefaultmsg = true,
        postcustom = L["RemainingCoolDown"],
        saveToPos  = {
            ["**"] = {
                cdtype  = "",
                default = true,
                saved   = false,
                pos     = { x = UIParent:GetWidth() / 2, y = UIParent:GetHeight() / 2, },
                show    = true,
            },
        },
        maxSpellDuration = 1800,
        spellShowAfterMaxDurationPassed = true,
        maxItemDuration  = 1800,
        itemShowAfterMaxDurationPassed  = true,
	},
}

function CoolDownButtons:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("CoolDownButtonsDB", defaults, "Default")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	self:RegisterEvent("BAG_UPDATE_COOLDOWN")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("SPELLS_CHANGED", "ResetSpells")
    self:RegisterMessage("CoolDownButtonsConfigChanged")
end

function CoolDownButtons:OnEnable()

    self.spellTable = spellTable
    self:ResetSpells()

    self.testMode = false
    self.testModeTime = 15
    self.testModeStart = 0
    self.testModeData = {}
    
    self.cydb = nil
    if IsAddOnLoaded("cyCircled") and cyCircled_CoolDownButtons then
        self.cydb = cyCircled:AcquireDBNamespace("CoolDownButtons")
    end
    if not IsAddOnLoaded("OmniCC") then
        self.noOmniCC = true
        for k,v in pairs(self.db.profile.anchors) do
            self.db.profile.anchors[k].showOmniCC = false
        end
    end

    self.spellnum = 0
    self.itemsnum = 0
    self.soonnum  = 0

    self.numcooldownbuttons = 1
    self.cdbtns = {}

    for i = 1, self.numcooldownbuttons do
        self.cdbtns[i] = self:createButton(i)
    end

    -- Hack to keep code "dry" :)
    self:CoolDownButtonsConfigChanged()    

    local frame = CreateFrame("Frame"); frame:SetScript("OnUpdate", CoolDownButtons_UPDATE)
end

function CoolDownButtons:ResetSpells()
	for k in pairs(spellTable) do
		spellTable[k] = nil
	end
	for spellTree = 1, GetNumSpellTabs() do
		local _, _, offset, num = GetSpellTabInfo(spellTree)
		for j = 1, num do
			local spellIndex = offset + j
			local spellName, spellID  = self:myGetSpellName(spellIndex)
			spellTable[spellName] = {
                spellName  = spellName,
                spellIndex = spellIndex,
                spellID    = spellID,
                spellTree  = spellTree,
            }
		end
	end
    self:ResetCooldowns()
end

function CoolDownButtons:SaveAnchorPos(anchor)
    self.db.profile.anchors[anchor.what].pos.x = anchor:GetLeft()
    self.db.profile.anchors[anchor.what].pos.y = anchor:GetBottom()
    
    -- I'm a Haxx0r :D
    -- CoolDownButtonsConfig:UpdateConfig();
    --  ^- this shit wont work so i use this -v
    LibStub("AceConfigRegistry-3.0"):NotifyChange("CoolDown Buttons") -- It causes a short flash but it works :/
end

function CoolDownButtons:CoolDownButtonsConfigChanged()
    if self.db.profile.anchors.spells.show then
        CoolDownButtonAnchor[1]:Show()
    else
        CoolDownButtonAnchor[1]:Hide()
    end	
    if self.db.profile.anchors.items.show and self.db.profile.splitRows then
        CoolDownButtonAnchor[2]:Show()
    else
        CoolDownButtonAnchor[2]:Hide()
    end	
    if self.db.profile.anchors.soon.show and self.db.profile.splitSoon then
        CoolDownButtonAnchor[3]:Show()
    else
        CoolDownButtonAnchor[3]:Hide()
    end	
    for i = 1, self.numcooldownbuttons do
        if self.db.profile.chatPost then
            self.cdbtns[i]:EnableMouse(true)
        else
            self.cdbtns[i]:EnableMouse(false)
        end
    end
    self:ResetCooldowns()
    if self.testMode then
        self:SetUpTestModeFakeCDS()
    end
    for i = 1, 3 do
        local forBar = CoolDownButtonAnchor[i].what
        CoolDownButtonAnchor[i]:ClearAllPoints()
        CoolDownButtonAnchor[i]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.profile.anchors[forBar].pos.x, self.db.profile.anchors[forBar].pos.y)
    end    
end

function CoolDownButtons_UPDATE(self, elapsed)
    for key, cooldown in pairs(cooldowns) do
        if type(cooldown) == "table" then
            local frame = CoolDownButtons.cdbtns[cooldown["buttonID"]]
            local hideFrame = false

            frame:Show()
            frame.text:Show()
            if not CoolDownButtons.testMode then
                if cooldown["cdtype"] == "spell" then -- spell
                    local cooldownCheck = GetSpellCooldown(cooldown["id"], BOOKTYPE_SPELL)
                    if (not cooldownCheck) or cooldownCheck == 0 then
                        hideFrame = true
                    end
                elseif cooldown["cdtype"] == "eq_item" then -- equipped Item (see Character Info)
                    local cooldownCheck = GetInventoryItemCooldown("player", cooldown["id"])
                    local itemLink = GetInventoryItemLink("player", cooldown["id"])
                    if (not cooldownCheck) or cooldownCheck == 0 or (not itemLink) then
                        hideFrame = true
                    end
                    if (not itemLink) or cooldown["name"] ~= select(3, string_find(GetInventoryItemLink("player", cooldown["id"]), "Hitem[^|]+|h%[([^[]+)%]")) then
                        cooldown.forceHide = true
                    end
                elseif cooldown["cdtype"] == "bag_item" then -- Item in Bag
                    local cooldownCheck = GetContainerItemCooldown(cooldown["id"], cooldown["id2"])
                    local itemLink = GetContainerItemLink(cooldown["id"], cooldown["id2"])
                    if (not cooldownCheck) or cooldownCheck == 0 or (not itemLink) then
                        hideFrame = true
                    end
                    if (not itemLink) or cooldown["name"] ~= (CoolDownButtons:getItemGroup(select(3, string_find(itemLink, "item:(%d+):"))) or select(3, string_find(itemLink, "Hitem[^|]+|h%[([^[]+)%]"))) then
                        cooldown.forceHide = true
                    end
                end
            else
                local time = ceil(cooldown["start"] + cooldown["duration"] - GetTime())
                if time < 0 then
                    hideFrame = true
                end
            end
            if hideFrame or cooldown.forceHide then
                frame.pulse.icon:Hide() -- Should avoid bugged pulses
                if CoolDownButtons.db.profile.anchors[frame.usedInBar].usePulse and not cooldown.forceHide and not CoolDownButtons.db.profile.anchors[frame.usedInBar].showOmniCC then
                    if not frame.pulseActive then
                        local icon = frame.texture
                        if icon and frame:IsVisible() then
                            local pulse = frame.pulse
                            if pulse then
                                pulse.scale = 1
                                pulse.icon:SetTexture(icon:GetTexture())
                                local r, g, b = icon:GetVertexColor()
                                pulse.icon:SetVertexColor(r, g, b, 0.7)
                                frame.pulseActive = true
                            end
                        end
                    else
                        local pulse = frame.pulse
                        if pulse.scale >= 2 then
                            pulse.dec = 1
                        end
                        pulse.scale = max(min(pulse.scale + (pulse.dec and -1 or 1) * pulse.scale * (elapsed/0.5), 2), 1)
                        if pulse.scale <= 1 then
                            pulse.icon:Hide()
                            pulse.dec = nil
                            frame.pulseActive = false

                            frame:Hide()
                            frame.text:Hide()
                            cooldowns[key] = nil
                            frame.used = false
                            frame.usedInBar = ""
                        else
                            pulse.icon:Show()
                            pulse.icon:SetHeight(pulse:GetHeight() * pulse.scale)
                            pulse.icon:SetWidth(pulse:GetWidth() * pulse.scale)
                        end
                    end
                else
                    frame:Hide()
                    frame.text:Hide()
                    cooldowns[key] = nil
                    frame.used = false
                    frame.usedInBar = ""
                end
            else
                local time = ceil(cooldown["start"] + cooldown["duration"] - GetTime())
                if time < 0 then
                    cooldown.forceHide = true
                end
                if time < 60 then
                    frame.text:SetText(string_format("0:%02d", time))
                elseif( time < 3600 ) then
                    local m = math.floor(time / 60)
                    local s = math.fmod(time, 60)
                    frame.text:SetText(string_format("%d:%02d", m, s))
                else
                    local hr = math.floor(time / 3600)
                    local m = math.floor( math.fmod(time, 3600) / 60 )
                    frame.text:SetText(string_format("%d.%02dh", hr, m))
                end
                frame.texture:SetTexture(cooldown["texture"])
                frame.cooldown:SetCD(cooldown["start"], cooldown["duration"], CoolDownButtons.db.profile.anchors[frame.usedInBar].showOmniCC)
            end
            if frame.used then
                local order = cooldown["order"] - 1
                local forBar = frame.usedInBar
                
                if not CoolDownButtons.db.profile.splitRows and forBar == "items" then
                    forBar = "spells"                    
                end
                if not CoolDownButtons.db.profile.splitSoon and forBar == "soon" then
                    forBar = "spells"                    
                end
                
                local center = CoolDownButtons.db.profile.anchors[forBar].center
                if center and forBar == "spells" then
                    local sub = CoolDownButtons.spellnum / 2
                    order = order - sub + 1
                end
                if center and forBar == "items" then
                    local sub = CoolDownButtons.itemsnum / 2
                    order = order - sub + 1
                end
                if center and forBar == "soon" then
                    local sub = CoolDownButtons.soonnum / 2
                    order = order - sub + 1
                end

                local scale = CoolDownButtons.db.profile.anchors[forBar].scale
                local alpha = CoolDownButtons.db.profile.anchors[forBar].alpha
                local direction = CoolDownButtons.db.profile.anchors[forBar].direction
                local buttonPadding = CoolDownButtons.db.profile.anchors[forBar].buttonPadding

                local textScale = CoolDownButtons.db.profile.anchors[forBar].textScale
                local textAlpha = CoolDownButtons.db.profile.anchors[forBar].textAlpha
                local textDirection = CoolDownButtons.db.profile.anchors[forBar].textSide
                local textPadding = CoolDownButtons.db.profile.anchors[forBar].textPadding                

                if not CoolDownButtons.db.profile.anchors[forBar].textSettings then
                    textScale     = scale
                    textAlpha     = alpha
                    textDirection = "down"
                end

                frame:SetScale(scale)

                frame.text:ClearAllPoints()
                frame.textFrame:SetScale(textScale)
                frame.text:SetFont(LSM:Fetch("font", CoolDownButtons.db.profile.font), CoolDownButtons.db.profile.fontSize, "OUTLINE")

                if textDirection == "left" then
                    frame.text:SetPoint("CENTER", frame, "CENTER", - (textPadding * scale), 0)
                elseif textDirection == "right" then
                    frame.text:SetPoint("CENTER", frame, "CENTER", (textPadding * scale), 0)
                elseif textDirection == "up" then
                    frame.text:SetPoint("CENTER", frame, "CENTER", 0, (textPadding * scale))
                elseif textDirection == "down" then 
                    frame.text:SetPoint("CENTER", frame, "CENTER", 0, - (textPadding * scale))
                end

                frame:ClearAllPoints()

                local save = CoolDownButtons.db.profile.saveToPos
                if save[cooldown["name"]] and save[cooldown["name"]].saved then
                    local pos = save[cooldown["name"]].pos
                    frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                else
                    local anchorTo = CoolDownButtonAnchor[1]
                    if CoolDownButtons.db.profile.splitRows then
                        if forBar == "spells" then
                            anchorTo = CoolDownButtonAnchor[1]
                        elseif forBar == "items" then
                            anchorTo = CoolDownButtonAnchor[2]
                        elseif forBar == "soon" then
                            anchorTo = CoolDownButtonAnchor[3]
                        end
                    end 
                    if CoolDownButtons.db.profile.splitSoon and forBar == "soon" then
                        anchorTo = CoolDownButtonAnchor[3]
                    end
                    if direction == "left" then
                        frame:SetPoint("CENTER", anchorTo, "CENTER", - (buttonPadding * order * scale), 0)
                    elseif direction == "right" then
                        frame:SetPoint("CENTER", anchorTo, "CENTER", (buttonPadding * order * scale), 0)
                    elseif direction == "up" then
                        frame:SetPoint("CENTER", anchorTo, "CENTER", 0, (buttonPadding * order * scale))
                    elseif direction == "down" then 
                        frame:SetPoint("CENTER", anchorTo, "CENTER", 0, - (buttonPadding * order * scale))
                    end
                end
                
                local c  = CoolDownButtons.db.profile.fontColor
                frame.text:SetTextColor(c.Red, c.Green,  c.Blue,  c.Alpha)

                frame:SetAlpha(alpha)               
                frame.text:SetAlpha(textAlpha)
                if not CoolDownButtons.db.profile.anchors[forBar].showTime then
                   frame.text:Hide()
                end
            end
        end
    end
    CoolDownButtons:SPELL_UPDATE_COOLDOWN()
    CoolDownButtons:BAG_UPDATE_COOLDOWN()
end

function CoolDownButtons:SPELL_UPDATE_COOLDOWN()
    if self.testMode then return end
    for k, spellData in pairs(spellTable) do
        local spellIndex = spellData.spellIndex
        local spellName  = spellData.spellName
        local spellTexture = GetSpellTexture(spellIndex, BOOKTYPE_SPELL)
        local start, duration, enable = GetSpellCooldown(spellIndex, BOOKTYPE_SPELL)
        if (start ~= nil and start > 0) then
            if self.db.profile.spellShowAfterMaxDurationPassed then
                remaining = ceil(start + duration - GetTime())
            else
                remaining = duration
            end
            if duration > 3 and enable == 1 and cooldowns[spellName] == nil and remaining < self.db.profile.maxSpellDuration and self.db.profile.saveToPos[spellName].show then
            -- continue only if duration > GCD AND cooldown started AND cooldown not registred yet
                local freeindex = self:getFreeFrame(spellName, "spells")
                if freeindex then
                    local saved = nil
                    if self.db.profile.saveToPos[spellName].default then
                        self.db.profile.saveToPos[spellName].default = false -- added to DB!
                        self.db.profile.saveToPos[spellName].cdtype  = "spell"
                        CoolDownButtonsConfig:InitPositions()
                    end
                    if self.db.profile.saveToPos[spellName].saved then
                        saved = 1
                    end
                    cooldowns[spellName] = {
                        cdtype    = "spell",       -- "item" or "spell"
                        id        = spellIndex,    -- itemid or spellid
                        name      = spellName,     -- item or spell name
                        start     = start,         -- cooldown start time
                        duration  = duration,      -- cooldown duration
                        texture   = spellTexture,  -- item or spell texture
                        buttonID  = freeindex,     -- assign to button #?
                        order     = 0,             -- display position
                        saved     = saved,         -- position saved?
                    }
                    if spellName == L["Spellgroup: Shocks"] then
                        cooldowns[spellName].texture = "Interface\\AddOns\\CoolDownButtons\\shocks.tga"
                    end
                    if spellName == L["Spellgroup: Traps"] then
                        cooldowns[spellName].texture = "Interface\\Icons\\Spell_Frost_ChainsOfIce"
                    end
                    --[[ for 2.4
                    if spellName == L["Spellgroup: Shocks"] or spellName == L["Spellgroup: Traps"] then
                        cooldowns[spellName].texture = self.spellgroups[spellName].texture
                    end
                    --]]
                    
                    self.cdbtns[freeindex].used = true
                    if saved ~= 1 then
                        self.cdbtns[freeindex].usedInBar = "spells"
                    else
                        self.cdbtns[freeindex].usedInBar = "single"
                    end
                end
            end 
        end
    end
    self:sortButtons()
end

function CoolDownButtons:BAG_UPDATE_COOLDOWN()
    if self.testMode then return end
  	for i=1,18 do
		local start, duration, enable = GetInventoryItemCooldown("player", i)
        if self.db.profile.itemShowAfterMaxDurationPassed then
            remaining = ceil(start + duration - GetTime())
        else
            remaining = duration
        end
        if duration > 3 and enable == 1  and remaining < self.db.profile.maxItemDuration then
        -- continue only if duration > GCD AND cooldown started
            local link = GetInventoryItemLink("player",i)
            local name = select(3, string_find(link, "Hitem[^|]+|h%[([^[]+)%]"))
            if cooldowns[name] == nil and self.db.profile.saveToPos[name].show then
                local freeindex = self:getFreeFrame(name, "items")
                if freeindex then
                    local saved = nil
                    if self.db.profile.saveToPos[name].default then
                        self.db.profile.saveToPos[name].default = false -- added to DB!
                        self.db.profile.saveToPos[name].cdtype  = "item"
                        CoolDownButtonsConfig:InitPositions()
                    end
                    if self.db.profile.saveToPos[name].saved then
                        saved = 1
                    end
                    local itemTexture = GetInventoryItemTexture("player", i)
                    cooldowns[name] = {
                        cdtype    = "eq_item",    -- "item" or "spell"
                        id        = i,            -- itemid or spellid
                        name      = name,         -- item or spell name
                        start     = start,        -- cooldown start time
                        duration  = duration,     -- cooldown duration
                        texture   = itemTexture,  -- item or spell texture
                        buttonID  = freeindex,    -- assign to button #?
                        order     = 0,   -- display position
                        saved     = saved,   -- position saved?
                    }
                    self.cdbtns[freeindex].used = true
                    if saved ~= 1 then
                        self.cdbtns[freeindex].usedInBar = "items"
                    else
                        self.cdbtns[freeindex].usedInBar = "single"
                    end
                end
            end
        end
	end
	for i=0, 4 do
		local slots = GetContainerNumSlots(i)
		for j=1, slots do
			local start, duration, enable = GetContainerItemCooldown(i,j)
			if self.db.profile.itemShowAfterMaxDurationPassed then
                remaining = ceil(start + duration - GetTime())
            else
                remaining = duration
            end
            if duration > 3 and enable == 1  and remaining < self.db.profile.maxItemDuration then
            -- continue only if duration > GCD AND cooldown started
                local link = GetContainerItemLink(i,j)
                local itemID = select(3, string_find(link, "item:(%d+):"))
                local name = self:getItemGroup(itemID) or select(3, string_find(link, "Hitem[^|]+|h%[([^[]+)%]"))
                if cooldowns[name] == nil and self.db.profile.saveToPos[name].show then
                    local freeindex = self:getFreeFrame(name, "items")
                    if freeindex then
                        local saved = nil
                        if self.db.profile.saveToPos[name].default then
                            self.db.profile.saveToPos[name].default = false -- added to DB!
                            self.db.profile.saveToPos[name].cdtype  = "item"
                            CoolDownButtonsConfig:InitPositions()
                        end
                        if self.db.profile.saveToPos[name].saved then
                            saved = 1
                        end
                        local itemTexture = self:getItemGroupTexture(name) or select(1, GetContainerItemInfo(i,j)	)
                        cooldowns[name] = {
                            cdtype    = "bag_item",   -- "item" or "spell"
                            id        = i,            -- bag
                            id2       = j,            -- bag slot
                            name      = name,         -- item or spell name
                            start     = start,        -- cooldown start time
                            duration  = duration,     -- cooldown duration
                            texture   = itemTexture,  -- item or spell texture
                            buttonID  = freeindex,    -- assign to button #?
                            order     = 0,            -- display position
                            saved     = saved,        -- position saved?
                        }
                        self.cdbtns[freeindex].used = true
                        if saved ~= 1 then
                            self.cdbtns[freeindex].usedInBar = "items"
                        else
                            self.cdbtns[freeindex].usedInBar = "single"
                        end
                    end
                end
            end
		end
	end
    self:sortButtons()
end

function CoolDownButtons:getItemGroup(itemid)
    if not itemid then return nil end
    local group = select(2, LibStub("LibPeriodicTable-3.1"):ItemInSet(itemid, "CDB_Itemgroup"))
    for groupKey, value in pairs(self.itemgroups) do
        if type(value) == "table" then
            for _, curid in pairs(value.ids) do
                if curid == group then
                    return groupKey
                end
            end
        end
    end
    return nil
end

function CoolDownButtons:getItemGroupTexture(itemgroup)
    if self.itemgroups[itemgroup] then
        return self.itemgroups[itemgroup].texture
    end
    return nil
end

function CoolDownButtons:PLAYER_ENTERING_WORLD()
    self:ResetCooldowns()
    self:SPELL_UPDATE_COOLDOWN()
    self:BAG_UPDATE_COOLDOWN()
end

function CoolDownButtons:myGetSpellName(index)
    local spell, rank = GetSpellName(index, BOOKTYPE_SPELL)
    -- Shaman shocks
    if spell == L["Earth Shock"] or spell == L["Flame Shock"] or spell == L["Frost Shock"] then
        spell = L["Spellgroup: Shocks"]
    end
    -- Hunter traps
    if spell == L["Immolation Trap"] or spell == L["Freezing Trap"]
    or spell == L["Frost Trap"] or spell == L["Snake Trap"] or spell == L["Explosive Trap"] then
        spell = L["Spellgroup: Traps"]
    end

    return spell, rank
end

--[[ for 2.4
function CoolDownButtons:myGetSpellName(index)
    local spell, rank = GetSpellName(index, BOOKTYPE_SPELL)
    local spellLink   = GetSpellLink(spell)
    local spellID     = select(3, string_find(spellLink, "spell:(%d+)"))
    local group       = select(2, LibStub("LibPeriodicTable-3.1"):ItemInSet(spellID, "CDB_Spellgroup"))
    local groupKey    = nil
    
    for key, value in pairs(self.spellgroups) do
        if type(value) == "table" then
            for _, curid in pairs(value.ids) do
                if curid == group then
                    groupKey = key
                end
            end
        end
    end
    if groupKey then
        return self.spellgroups[groupKey].name, spellID
    else
        return spell, spellID
    end
end
--]]

function CoolDownButtons:getFreeFrame(forThis, whatBar)
    local x
    if self.testMode then
        for i = 1, self.numcooldownbuttons do
            x = i
            if self.cdbtns[i].used == false then
                return i, nil
            end
        end
        x = x + 1
        return self:setupFrame(x)
    end
    if self.db.profile.saveToPos[forThis].saved then
        for i = 1, self.numcooldownbuttons do
            x = i
            if self.cdbtns[i].used == false then
                return i, nil
            end
        end
        x = x + 1
        return self:setupFrame(x)
    else
        local z = 1
        for i = 1, self.numcooldownbuttons do
            x = i
            if self.cdbtns[i].usedInBar == whatBar then
                z = z + 1
            end
            if self.cdbtns[i].used == false and z <= self.db.profile.anchors[whatBar].maxbuttons then
                return i, nil
            end
        end
        x = x + 1
        if z <= self.db.profile.anchors[whatBar].maxbuttons then
            return self:setupFrame(x)
        else
            return nil, nil
        end
    end
end

function CoolDownButtons:setupFrame(num)
    self.cdbtns[num] = self:createButton(num)
    self.numcooldownbuttons = self.numcooldownbuttons + 1
    return num
end

function CoolDownButtons:createButton(i, justMove)
    local button = CreateFrame("Button", "CoolDownButton"..i, UIParent, "ActionButtonTemplate")
    button:SetClampedToScreen(true)
    if not justMove then
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        button:SetScript("OnEnter", function(self) 
                                        GameTooltip:SetOwner(this, "ANCHOR_CURSOR");
                                        for key, cooldown in pairs(cooldowns) do
                                            if type(cooldown) == "table" and cooldown["buttonID"] == self.id then
                                                GameTooltip:SetText(L["Click to Post Cooldown"])
                                                break
                                            end
                                        end
                                    end)
        button:SetScript("OnMouseDown", function(self)
                                        if CoolDownButtons.db.profile.chatPost then
                                            for key, cooldown in pairs(cooldowns) do
                                                if type(cooldown) == "table" and cooldown["buttonID"] == self.id then
                                                    local time = ceil(cooldown["start"] + cooldown["duration"] - GetTime())
                                                    local formated_time
                                                    if time < 60 then
                                                        formated_time = string_format("0:%02d", time)
                                                    elseif( time < 3600 ) then
                                                        local m = math.floor(time / 60)
                                                        local s = math.fmod(time, 60)
                                                        formated_time = string_format("%d:%02d", m, s)
                                                    else
                                                        local hr = math.floor(time / 3600)
                                                        local m = math.floor( math.fmod(time, 3600) / 60 )
                                                        formated_time = string_format("%d.%02dh", hr, m)
                                                    end
                                                    
                                                    local chatmsg
                                                    if CoolDownButtons.db.profile.postdefaultmsg then
                                                        chatmsg = CoolDownButtons:gsub(L["RemainingCoolDown"], "$spell", cooldown["name"])
                                                        chatmsg = CoolDownButtons:gsub(chatmsg, "$time", formated_time)
                                                    else
                                                        chatmsg = CoolDownButtons:gsub(CoolDownButtons.db.profile.postcustom, "$spell", cooldown["name"])
                                                        chatmsg = CoolDownButtons:gsub(chatmsg, "$time", formated_time)
                                                    end
                                                    
                                                    local postto = CoolDownButtons.db.profile.posttochats
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
                                                        if (GetNumRaidMembers() > 0) then
                                                            SendChatMessage(chatmsg, "RAID_WARNING", GetDefaultLanguage("player"))
                                                        end
                                                    end
                                                    if postto["battleground"] then
                                                        if select(2,IsInInstance()) == "pvp" then
                                                            SendChatMessage(chatmsg, "BATTLEGROUND", GetDefaultLanguage("player"))
                                                        end
                                                    end
                                                    if postto["yell"] then
                                                        SendChatMessage(chatmsg, "YELL", GetDefaultLanguage("player"))
                                                    end
                                                    for i = 5, 10 do
                                                        local channame = tostring(select(2,GetChannelName(i)))
                                                        if postto["channel"..i] and channame ~= "nil" then
                                                            SendChatMessage(chatmsg, "CHANNEL", GetDefaultLanguage("player"), i)
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end)
    end -- if not justMove
    
    
    if self.db.profile.chatPost then
        button:EnableMouse(true)
    else
        button:EnableMouse(false)
    end
    
    button:SetID(i)
    button.used      = false
    button.usedInBar = ""
    button.id        = i
    
--[[
	frame.border = _G[("%sBorder"):format(name)]
	frame.macroName = _G[("%sName"):format(name)]
	frame.hotkey = _G[("%sHotKey"):format(name)]
	frame.count = _G[("%sCount"):format(name)]
	frame.flash = _G[("%sFlash"):format(name)]
	frame.flash:Hide()
--]]

	button.texture  = _G[("%sIcon"):format(button:GetName())]
    button.texture:SetTexture("Interface\\Icons\\Spell_Nature_WispSplode")

    button.cooldown = _G[("%sCooldown"):format(button:GetName())]

    local c  = self.db.profile.fontColor

    if self.cydb then
		if self.cydb.profile["CoolDown Buttons"] ~= nil then
            if i ~= 1 then cyCircled_CoolDownButtons:AddElement(i) end
            cyCircled_CoolDownButtons:ApplySkin()
            if not button.overlay then
                button.overlay = _G[button:GetName() .. "Overlay"]
            end
		end
	end
    
    button.textFrame = CreateFrame("Frame", "CoolDownButton"..i.."CooldownText", UIParent)
    button.textFrame:SetAllPoints(button)
    button.textFrame:SetFrameLevel(button.cooldown:GetFrameLevel() + 1)
    button.text = button.textFrame:CreateFontString(nil, "OVERLAY")
    button.text:SetFont(LSM:Fetch("font", self.db.profile.font), self.db.profile.fontSize, "OUTLINE")
    button.text:SetTextColor(c.Red, c.Green,  c.Blue,  c.Alpha)
    
    button.cooldown.SetCooldown2 = CDB_SetCooldown    
    button.cooldown.SetCD = function(self, start, duration, showOmniCC)
                                if showOmniCC then
                                    self:SetCooldown(start, duration)
                                else
                                    self:SetCooldown(0, 0)
                                    self:SetCooldown2(start, duration)
                                    self:SetAlpha(1)
                                    if not CoolDownButtons.db.profile.anchors[self:GetParent().usedInBar].showCoolDownSpiral then
                                        self:SetAlpha(0)
                                    end
                                end
                            end

    button.pulse = CreateFrame('Frame', nil, button)
    button.pulse:SetAllPoints(button)
    button.pulse:SetToplevel(true)
    button.pulse.icon = button:CreateTexture(nil, 'OVERLAY')
    button.pulse.icon:SetPoint('CENTER')
    button.pulse.icon:SetBlendMode('ADD')
    button.pulse.icon:SetHeight(button:GetHeight())
    button.pulse.icon:SetWidth(button:GetWidth())
    button.pulse.icon:Hide()
    button.pulseActive = false

    button:Hide()
    return button
end

function CoolDownButtons:gsub(text, variable, value)
	if (value) then
		text = string_gsub(text, variable, value);
	elseif (string_find(text, " "..variable)) then
		text = string_gsub(text, " "..variable, "");
	else
		text = string_gsub(text, variable, "");
	end
	return text;
end

function CoolDownButtons:ResetCooldowns()
    if self.cdbtns then
        for k in pairs(cooldowns) do
            cooldowns[k] = nil
        end
        for key, button in pairs(self.cdbtns) do
            button:Hide()
            button.text:Hide()
            button.used = false
            button.usedInBar = ""
        end
        if not self.testMode then
            self:SPELL_UPDATE_COOLDOWN()
            self:BAG_UPDATE_COOLDOWN()
        end
    end
end

function CoolDownButtons:sortButtons()
    local spells = 1
    local items = 1
    local soon = 1
    local timeToSplit = self.db.profile.anchors.soon.timeToSplit
    for key, cooldown in pairs(cooldowns) do
        if type(cooldown) == "table" and cooldown["saved"] ~= 1 then
            local remaining = ceil(cooldown["start"] + cooldown["duration"] - GetTime())
            if self.db.profile.splitSoon and remaining < timeToSplit then
                self.cdbtns[cooldown["buttonID"]].usedInBar = "soon"
                cooldown["order"] = soon
                soon = soon + 1                
            else
                if self.db.profile.splitRows then
                    if cooldown.cdtype == "spell" then
                        cooldown["order"] = spells
                        spells = spells + 1
                    elseif cooldown.cdtype == "eq_item" or cooldown.cdtype == "bag_item" then
                        cooldown["order"] = items
                        items = items + 1
                    end
                else
                    cooldown["order"] = spells
                    spells = spells + 1
                end
            end
        end
    end
    self.spellnum = spells
    self.itemsnum = items
    self.soonnum  = soon
end

function CoolDownButtons:EndTestMode(force)
    CoolDownButtons.testMode = false
    CoolDownButtons:ResetCooldowns()
	CoolDownButtons:SendMessage("CoolDownButtonsTestModeEnd")
    if force then
        LibStub("AceTimer-3.0"):CancelTimer(CoolDownButtons.AceTimerHandler)
    end
end

function CoolDownButtons:StartTestMode(mode)
    self.AceTimerHandler = LibStub("AceTimer-3.0"):ScheduleTimer(CoolDownButtons.EndTestMode, self.testModeTime + 1)
    self.testMode = true
    self.testModeData = mode
    self.testModeStart = GetTime()
    self:ResetCooldowns()
    self:SetUpTestModeFakeCDS(mode)
end

function CoolDownButtons:SetUpTestModeFakeCDS()
    for k, v in pairs(self.testModeData) do
        if (v == "spells") 
        or (v == "items" and self.db.profile.splitRows) 
        or (v == "soon" and self.db.profile.splitSoon) then
            local cdtype
            if v == "spells" then 
                cdtype = "spell"
            elseif v == "items" then
                cdtype = "eq_item"
            elseif v == "soon" then
                cdtype = "soon"
            end
            for i = 1, self.db.profile.anchors[v].maxbuttons do
                local freeindex = self:getFreeFrame(nil, v)
                if freeindex then
                    cooldowns["TestCooldown_"..v.."_"..i] = {
                        cdtype    = cdtype,
                        id        = nil,
                        name      = "TestCooldown_"..v.."_"..i,
                        start     = self.testModeStart,
                        duration  = self.testModeTime,
                        texture   = "Interface\\Icons\\INV_Misc_Food_02",
                        buttonID  = freeindex,
                        order     = i,
                        saved     = nil,
                    }
                    self.cdbtns[freeindex].used = true
                    self.cdbtns[freeindex].usedInBar = v
                end
            end
        elseif v == "single" then
            local i = 1
            for name, data in sortedpairs(self.db.profile.saveToPos) do
                if data.saved then
                    i = i + 1
                    local freeindex = self:getFreeFrame(nil, v)
                    if freeindex then
                        cooldowns["TestCooldown_"..v.."_"..i] = {
                            cdtype    = "single",
                            id        = nil,
                            name      = name,
                            start     = self.testModeStart,
                            duration  = self.testModeTime,
                            texture   = "Interface\\Icons\\INV_Misc_Food_02",
                            buttonID  = freeindex,
                            order     = i,
                            saved     = nil,
                        }
                        self.cdbtns[freeindex].used = true
                        self.cdbtns[freeindex].usedInBar = "single"
                    end
                end
            end
        end
    end
    self.spellnum = self.db.profile.anchors.spells.maxbuttons + 1
    self.itemsnum = self.db.profile.anchors.items.maxbuttons  + 1
    self.soonnum  = self.db.profile.anchors.soon.maxbuttons   + 1
end


-- http://www.wowwiki.com/HOWTO:_Do_Tricks_With_Tables#Iterate_with_sorted_keys
function sortedpairs(t,comparator)
    local sortedKeys = {};
	table_foreach(t, function(k,v) table_insert(sortedKeys,k) end);
	table_sort(sortedKeys,comparator);
	local i = 0;
	local function _f(_s,_v)
		i = i + 1;
		local k = sortedKeys[i];
		if (k) then
			return k,t[k];
		end
	end
	return _f,nil,nil;
end

-- Debug function :)
function cdb()
    for key, cooldown in sortedpairs(cooldowns) do
        local frame = CoolDownButtons.cdbtns[cooldown["buttonID"]]
        local remaining = ceil(cooldown["start"] + cooldown["duration"] - GetTime())
        ChatFrame2:AddMessage(cooldown["name"].." @ "..remaining.." of "..cooldown["duration"])
        ChatFrame2:AddMessage("Assgined to Button: "..cooldown["buttonID"] .." / "..CoolDownButtons.numcooldownbuttons)
        if frame.usedInBar == "spells" then
            ChatFrame2:AddMessage("Position in the row: "..cooldown["order"].." / "..CoolDownButtons.spellnum - 1)
        end
        if frame.usedInBar == "items" then
            ChatFrame2:AddMessage("Position in the row: "..cooldown["order"].." / "..CoolDownButtons.itemsnum - 1)
        end
        if frame.usedInBar == "soon" then
            ChatFrame2:AddMessage("Position in the row: "..cooldown["order"].." / "..CoolDownButtons.soonnum - 1)
        end
        ChatFrame2:AddMessage("Used in the row: "..frame.usedInBar)
        ChatFrame2:AddMessage("----------------------")
    end
end
