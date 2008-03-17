CoolDownButtons = LibStub("AceAddon-3.0"):NewAddon("CoolDown Buttons", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("CoolDown Buttons", false)

local LSM = LibStub("LibSharedMedia-2.0")
LSM:Register("font", "Skurri", [[Interface\AddOns\CoolDownButtons\skurri.ttf]])

CoolDownButtonAnchor = CreateFrame("Frame", "CoolDownButtonAnchor", UIParent)
CoolDownButtonAnchor:SetWidth(20);      CoolDownButtonAnchor:SetHeight(20)
CoolDownButtonAnchor:SetMovable(true);  CoolDownButtonAnchor:EnableMouse(true); 
CoolDownButtonAnchor:SetScript("OnMouseDown", function(self) self:StartMoving()         end)
CoolDownButtonAnchor:SetScript("OnMouseUp",   function(self) self:StopMovingOrSizing(); CoolDownButtons:SaveAnchorPos(self) end)
CoolDownButtonAnchor:SetScript("OnDragStop",  function(self) self:StopMovingOrSizing(); end)
CoolDownButtonAnchor:SetScript("OnLeave",     function() GameTooltip:Hide()                         end)
CoolDownButtonAnchor:SetScript("OnEnter",     function() GameTooltip:SetOwner(this, "ANCHOR_CURSOR"); GameTooltip:SetText(L["Click to Move"]) end)
CoolDownButtonAnchor:SetClampedToScreen(true)
CoolDownButtonAnchor:SetFrameStrata("DIALOG")
CoolDownButtonAnchor.what = "spells"

CoolDownButtonAnchor.texture = CoolDownButtonAnchor:CreateTexture(nil,"OVERLAY")
CoolDownButtonAnchor.texture:SetTexture("Interface\\Icons\\Spell_Nature_WispSplode")
CoolDownButtonAnchor.texture:SetAllPoints(CoolDownButtonAnchor)

CoolDownButtonAnchor2 = CreateFrame("Frame", "CoolDownButtonAnchor2", UIParent)
CoolDownButtonAnchor2:SetWidth(20);      CoolDownButtonAnchor2:SetHeight(20)
CoolDownButtonAnchor2:SetMovable(true);  CoolDownButtonAnchor2:EnableMouse(true); 
CoolDownButtonAnchor2:SetScript("OnMouseDown", function(self) self:StartMoving()         end)
CoolDownButtonAnchor2:SetScript("OnMouseUp",   function(self) self:StopMovingOrSizing(); CoolDownButtons:SaveAnchorPos(self) end)
CoolDownButtonAnchor2:SetScript("OnDragStop",  function(self) self:StopMovingOrSizing(); end)
CoolDownButtonAnchor2:SetScript("OnLeave",     function() GameTooltip:Hide()                         end)
CoolDownButtonAnchor2:SetScript("OnEnter",     function() GameTooltip:SetOwner(this, "ANCHOR_CURSOR"); GameTooltip:SetText(L["Click to Move"]) end)
CoolDownButtonAnchor2:SetClampedToScreen(true)
CoolDownButtonAnchor2:SetFrameStrata("DIALOG")
CoolDownButtonAnchor2.what = "items"

CoolDownButtonAnchor2.texture = CoolDownButtonAnchor2:CreateTexture(nil,"OVERLAY")
CoolDownButtonAnchor2.texture:SetTexture("Interface\\Icons\\Spell_Nature_WispSplode")
CoolDownButtonAnchor2.texture:SetAllPoints(CoolDownButtonAnchor2)

CoolDownButtonAnchor3 = CreateFrame("Frame", "CoolDownButtonAnchor3", UIParent)
CoolDownButtonAnchor3:SetWidth(20);      CoolDownButtonAnchor3:SetHeight(20)
CoolDownButtonAnchor3:SetMovable(true);  CoolDownButtonAnchor3:EnableMouse(true); 
CoolDownButtonAnchor3:SetScript("OnMouseDown", function(self) self:StartMoving()         end)
CoolDownButtonAnchor3:SetScript("OnMouseUp",   function(self) self:StopMovingOrSizing(); CoolDownButtons:SaveAnchorPos(self) end)
CoolDownButtonAnchor3:SetScript("OnDragStop",  function(self) self:StopMovingOrSizing(); end)
CoolDownButtonAnchor3:SetScript("OnLeave",     function() GameTooltip:Hide()                         end)
CoolDownButtonAnchor3:SetScript("OnEnter",     function() GameTooltip:SetOwner(this, "ANCHOR_CURSOR"); GameTooltip:SetText(L["Click to Move"]) end)
CoolDownButtonAnchor3:SetClampedToScreen(true)
CoolDownButtonAnchor3:SetFrameStrata("DIALOG")
CoolDownButtonAnchor3.what = "soon"

CoolDownButtonAnchor3.texture = CoolDownButtonAnchor3:CreateTexture(nil,"OVERLAY")
CoolDownButtonAnchor3.texture:SetTexture("Interface\\Icons\\Spell_Nature_WispSplode")
CoolDownButtonAnchor3.texture:SetAllPoints(CoolDownButtonAnchor3)

local cooldowns = {}

local defaults = {
	profile = {
        font        = "Skurri",
        fontColor   = { Red = 1, Green = 1, Blue = 1, Alpha = 1, },
        scale       = 0.85,
        alpha       = 1,
		direction   = "right",
        maxbuttons  = 10,
        showTime    = true,
        splitRows   = false,
        splitSoon   = false,
        anchors     = {
            spells = {
                show          = true,
                maxbuttons    = 10,
                scale         = 0.85,
                alpha         = 1,
                direction     = "right",
                pos           = { x = 100, y = 300, },
                textSettings  = false,
                textSide      = "down",
                textScale     = 0.85,
                textAlpha     = 1,
                buttonPadding = 50,
                textPadding   = 33,
            },
            items = {
                show          = true,
                maxbuttons    = 10,
                scale         = 0.85,
                alpha         = 1,
                direction     = "right",
                pos           = { x = 100, y = 250, },
                textSettings  = false,
                textSide      = "down",
                textScale     = 0.85,
                textAlpha     = 1,
                buttonPadding = 50,
                textPadding   = 33,
            },
            soon = {
                show          = true,
                timeToSplit   = 5,
                maxbuttons    = 10,
                scale         = 0.85,
                alpha         = 1,
                direction     = "right",
                pos           = { x = 100, y = 350, },
                textSettings  = false,
                textSide      = "down",
                textScale     = 0.85,
                textAlpha     = 1,
                buttonPadding = 50,
                textPadding   = 33,
            },
            single = {
                scale         = 0.85,
                alpha         = 1,
                textSettings  = false,
                textSide      = "down",
                textScale     = 0.85,
                textAlpha     = 1,
                buttonPadding =  0,
                textPadding   = 33,
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
    self:RegisterMessage("CoolDownButtonsConfigChanged")
end

function CoolDownButtons:OnEnable()
    self.testMode = false
    self.testModeTime = 15
    self.testModeStart = 0
    self.testModeData = {}

    self.numcooldownbuttons = 1
    self.cdbtns = {}
    
    for i = 1, self.numcooldownbuttons do
        self.cdbtns[i] = self:createButton(i)
    end
    
    -- Hack to keep code "dry" :)
    self:CoolDownButtonsConfigChanged()    
    
    local frame = CreateFrame("Frame"); frame:SetScript("OnUpdate", CoolDownButtons_UPDATE)
end

function CoolDownButtons:SaveAnchorPos(anchor)
    self.db.profile.anchors[anchor.what].pos.x = anchor:GetLeft()
    self.db.profile.anchors[anchor.what].pos.y = anchor:GetBottom()
end
function CoolDownButtons:CoolDownButtonsConfigChanged()
    if self.db.profile.anchors.spells.show then
        CoolDownButtonAnchor:Show()
    else
        CoolDownButtonAnchor:Hide()
    end	
    if self.db.profile.anchors.items.show and self.db.profile.splitRows then
        CoolDownButtonAnchor2:Show()
    else
        CoolDownButtonAnchor2:Hide()
    end	
    if self.db.profile.anchors.soon.show and self.db.profile.splitSoon then
        CoolDownButtonAnchor3:Show()
    else
        CoolDownButtonAnchor3:Hide()
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
    CoolDownButtonAnchor:ClearAllPoints()
    CoolDownButtonAnchor2:ClearAllPoints()
    CoolDownButtonAnchor3:ClearAllPoints()
    CoolDownButtonAnchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.profile.anchors.spells.pos.x, self.db.profile.anchors.spells.pos.y)
    CoolDownButtonAnchor2:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.profile.anchors.items.pos.x, self.db.profile.anchors.items.pos.y)
    CoolDownButtonAnchor3:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.profile.anchors.soon.pos.x, self.db.profile.anchors.soon.pos.y)
end

function CoolDownButtons_UPDATE()
    for key, cooldown in pairs(cooldowns) do
        if type(cooldown) == "table" then
            local frame = CoolDownButtons.cdbtns[cooldown["buttonID"]]
            local cooldownframe = frame.cooldown

            frame:Show()
            cooldownframe.textFrame.text:Show()
            if not CoolDownButtons.testMode then
                if cooldown["cdtype"] == "spell" then -- spell
                    if (GetSpellCooldown(cooldown["id"], BOOKTYPE_SPELL) ~= nil and GetSpellCooldown(cooldown["id"], BOOKTYPE_SPELL) > 0) then
                        local time = ceil(cooldown["start"] + cooldown["duration"] - GetTime())
                        if time < 60 then
                            cooldownframe.textFrame.text:SetText(string.format("0:%02d", time))
                        elseif( time < 3600 ) then
                            local m = math.floor(time / 60)
                            local s = math.fmod(time, 60)
                            cooldownframe.textFrame.text:SetText(string.format("%d:%02d", m, s))
                        else
                            local hr = math.floor(time / 3600)
                            local m = math.floor( math.fmod(time, 3600) / 60 )
                            cooldownframe.textFrame.text:SetText(string.format("%d.%02dhr", hr, m))
                        end
                        frame.texture:SetTexture(cooldown["texture"])
                        
                        cooldownframe:SetCooldown(cooldown["start"], cooldown["duration"])
                    else
                        frame:Hide()
                        cooldownframe.textFrame.text:Hide()
                        cooldowns[key] = nil
                        frame.used = false
                        frame.usedInBar = ""
                    end
                elseif cooldown["cdtype"] == "eq_item" then -- equipped Item (see Character Info)
                    if  GetInventoryItemCooldown("player", cooldown["id"]) ~= nil
                    and GetInventoryItemCooldown("player", cooldown["id"]) > 0
                    and cooldown["name"] == select(3, string.find(GetInventoryItemLink("player", cooldown["id"]), "Hitem[^|]+|h%[([^[]+)%]")) then
                        local time = ceil(cooldown["start"] + cooldown["duration"] - GetTime())
                        if time < 60 then
                            cooldownframe.textFrame.text:SetText(string.format("0:%02d", time))
                        elseif( time < 3600 ) then
                            local m = math.floor(time / 60)
                            local s = math.fmod(time, 60)
                            cooldownframe.textFrame.text:SetText(string.format("%d:%02d", m, s))
                        else
                            local hr = math.floor(time / 3600)
                            local m = math.floor( math.fmod(time, 3600) / 60 )
                            cooldownframe.textFrame.text:SetText(string.format("%d.%02dhr", hr, m))
                        end
                        frame.texture:SetTexture(cooldown["texture"])
                        
                        cooldownframe:SetCooldown(cooldown["start"], cooldown["duration"])
                    else
                        frame:Hide()
                        cooldownframe.textFrame.text:Hide()
                        cooldowns[key] = nil
                        frame.used = false
                        frame.usedInBar = ""
                    end
                elseif cooldown["cdtype"] == "bag_item" then -- Item in Bag
                    if  GetContainerItemCooldown(cooldown["id"], cooldown["id2"]) ~= nil
                    and GetContainerItemCooldown(cooldown["id"], cooldown["id2"]) > 0 then
                        local link = GetContainerItemLink(cooldown["id"], cooldown["id2"])
                        local itemID = select(3, string.find(link, "item:(%d+):"))
                        local name = CoolDownButtons:getItemGroup(itemID) or select(3, string.find(link, "Hitem[^|]+|h%[([^[]+)%]"))
                        if cooldown["name"] == name then
                            local time = ceil(cooldown["start"] + cooldown["duration"] - GetTime())
                            if time < 60 then
                                cooldownframe.textFrame.text:SetText(string.format("0:%02d", time))
                            elseif( time < 3600 ) then
                                local m = math.floor(time / 60)
                                local s = math.fmod(time, 60)
                                cooldownframe.textFrame.text:SetText(string.format("%d:%02d", m, s))
                            else
                                local hr = math.floor(time / 3600)
                                local m = math.floor( math.fmod(time, 3600) / 60 )
                                cooldownframe.textFrame.text:SetText(string.format("%d.%02dhr", hr, m))
                            end
                            frame.texture:SetTexture(cooldown["texture"])                    
                            cooldownframe:SetCooldown(cooldown["start"], cooldown["duration"])
                        end
                    else
                        frame:Hide()
                        cooldownframe.textFrame.text:Hide()
                        cooldowns[key] = nil
                        frame.used = false
                        frame.usedInBar = ""
                    end
                end
            else
                local time = ceil(cooldown["start"] + cooldown["duration"] - GetTime())
                if time > 0 then
                    local time = ceil(cooldown["start"] + cooldown["duration"] - GetTime())
                    if time < 60 then
                        cooldownframe.textFrame.text:SetText(string.format("0:%02d", time))
                    elseif( time < 3600 ) then
                        local m = math.floor(time / 60)
                        local s = math.fmod(time, 60)
                        cooldownframe.textFrame.text:SetText(string.format("%d:%02d", m, s))
                    else
                        local hr = math.floor(time / 3600)
                        local m = math.floor( math.fmod(time, 3600) / 60 )
                        cooldownframe.textFrame.text:SetText(string.format("%d.%02dhr", hr, m))
                    end
                    frame.texture:SetTexture(cooldown["texture"]) -- "Interface\\Icons\\INV_Misc_Food_02"               
                    cooldownframe:SetCooldown(cooldown["start"], cooldown["duration"])
                else
                    frame:Hide()
                    cooldownframe.textFrame.text:Hide()
                    cooldowns[key] = nil
                    frame.used = false
                    frame.usedInBar = ""
                end
            end

            if frame.used then
                -- set position, scaling and alpha :)
                local order = cooldown["order"] - 1
                local forBar = frame.usedInBar
                
                if not CoolDownButtons.db.profile.splitRows and forBar == "items" then
                    forBar = "spells"                    
                end
                if not CoolDownButtons.db.profile.splitSoon and forBar == "soon" then
                    forBar = "spells"                    
                end
                --[[
                if not CoolDownButtons.db.profile.splitRows or (forBar ~= "soon" or forBar ~= "single") then
                    forBar = "spells"
                end
                if not CoolDownButtons.db.profile.splitSoon or (forBar ~= "soon" or forBar ~= "single" or forBar ~= "items") then
                    forBar = "spells"
                end
                --]]
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

                frame:SetWidth (45 * scale)
                frame:SetHeight(45 * scale)
                frame:GetNormalTexture():SetWidth(75 * scale)
                frame:GetNormalTexture():SetHeight(75 * scale)

                cooldownframe.textFrame.text:ClearAllPoints()
                cooldownframe.textFrame.text:SetFont(LSM:Fetch("font", CoolDownButtons.db.profile.font), 15 * textScale, "OUTLINE")

                if textDirection == "left" then
                    cooldownframe.textFrame.text:SetPoint("CENTER", cooldownframe.textFrame, "CENTER", - (textPadding * scale), 0)
                elseif textDirection == "right" then
                    cooldownframe.textFrame.text:SetPoint("CENTER", cooldownframe.textFrame, "CENTER", (textPadding * scale), 0)
                elseif textDirection == "up" then
                    cooldownframe.textFrame.text:SetPoint("CENTER", cooldownframe.textFrame, "CENTER", 0, (textPadding * scale))
                elseif textDirection == "down" then 
                    cooldownframe.textFrame.text:SetPoint("CENTER", cooldownframe.textFrame, "CENTER", 0, - (textPadding * scale))
                end

                frame:ClearAllPoints()

                local save = CoolDownButtons.db.profile.saveToPos
                if save[cooldown["name"]] and save[cooldown["name"]].saved then
                    local pos = save[cooldown["name"]].pos
                    frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                else
                    local anchorTo = CoolDownButtonAnchor
                    if CoolDownButtons.db.profile.splitRows then
                        if forBar == "spells" then
                            anchorTo = CoolDownButtonAnchor
                        elseif forBar == "items" then
                            anchorTo = CoolDownButtonAnchor2
                        elseif forBar == "soon" then
                            anchorTo = CoolDownButtonAnchor3
                        end
                    end 
                    if CoolDownButtons.db.profile.splitSoon and forBar == "soon" then
                        anchorTo = CoolDownButtonAnchor3
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
                cooldownframe.textFrame.text:SetTextColor(c.Red, c.Green,  c.Blue,  c.Alpha)

                frame:SetAlpha(alpha)               
                cooldownframe.textFrame:SetAlpha(textAlpha)
                if not CoolDownButtons.db.profile.showTime then
                    cooldownframe.textFrame.text:Hide()
                end
            end
        end
    end
    CoolDownButtons:SPELL_UPDATE_COOLDOWN()
    CoolDownButtons:BAG_UPDATE_COOLDOWN()
end

function CoolDownButtons:SPELL_UPDATE_COOLDOWN()
    if self.testMode then return end
    for tabIndex = 1, MAX_SKILLLINE_TABS do
        local tabName, tabTexture, tabSpellOffset, tabNumSpells = GetSpellTabInfo(tabIndex)
        if not tabName then
            break
        end
        for spellIndex = tabSpellOffset + 1, tabSpellOffset + tabNumSpells do
            local spellName, spellRank = self:myGetSpellName(spellIndex)
            local spellTexture = GetSpellTexture(spellIndex, BOOKTYPE_SPELL)
            if (GetSpellCooldown(spellIndex, BOOKTYPE_SPELL) ~= nil and GetSpellCooldown(spellIndex, BOOKTYPE_SPELL) > 0) then
                local start, duration, enable = GetSpellCooldown(spellIndex, BOOKTYPE_SPELL)
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
            local name = select(3, string.find(link, "Hitem[^|]+|h%[([^[]+)%]"))
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
	for i=0,4 do
		local slots = GetContainerNumSlots(i)
		for j=1,slots do
			local start, duration, enable = GetContainerItemCooldown(i,j)
			if self.db.profile.itemShowAfterMaxDurationPassed then
                remaining = ceil(start + duration - GetTime())
            else
                remaining = duration
            end
            if duration > 3 and enable == 1  and remaining < self.db.profile.maxItemDuration then
            -- continue only if duration > GCD AND cooldown started
                local link = GetContainerItemLink(i,j)
                local itemID = select(3, string.find(link, "item:(%d+):"))
                local name = self:getItemGroup(itemID) or select(3, string.find(link, "Hitem[^|]+|h%[([^[]+)%]"))
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
    local spellID     = select(3, string.find(spellLink, "spell:(%d+)"))
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
        return self.spellgroups[groupKey].name, rank
    else
        return spell, rank
    end
end
--]]

function CoolDownButtons:checkSpell(index)
    for i = 1, self.numcooldownbuttons do
        if self.cdbtns[i].curspell ~= -1 then
            local spell, _ = self:myGetSpellName(index)
            local curspell, _ = self:myGetSpellName(CoolDownButtons.cdbtns[i].curspell)
            if spell == curspell then
                return 0
            end
        end
    end
    return 1
end

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
    local button = CreateFrame("Button", "CoolDownButton"..i, UIParent, "CoolDownButtonTemplate")
    button:SetWidth(45 * self.db.profile.scale); button:SetHeight(45 * self.db.profile.scale); button:SetID(i)
    button:EnableMouse(true)
    button:SetClampedToScreen(true)
    button:SetParent("UIParent")
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
                                                        formated_time = string.format("0:%02d", time)
                                                    elseif( time < 3600 ) then
                                                        local m = math.floor(time / 60)
                                                        local s = math.fmod(time, 60)
                                                        formated_time = string.format("%d:%02d", m, s)
                                                    else
                                                        local hr = math.floor(time / 3600)
                                                        local m = math.floor( math.fmod(time, 3600) / 60 )
                                                        formated_time = string.format("%d.%02dhr", hr, m)
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

    button.texture = button:CreateTexture(nil,"BACKGROUND")
    button.texture:SetTexture("Interface\\Icons\\Spell_Nature_WispSplode")
    button.texture:SetAllPoints(button)
    
    button:GetNormalTexture():SetWidth(75 * self.db.profile.scale)
    button:GetNormalTexture():SetHeight(75 * self.db.profile.scale)

    button.used      = false
    button.usedInBar = ""
    button.id        = i

    local cooldown -- Get Cooldown Frame
    local kids = { button:GetChildren() };
    for _, child in ipairs(kids) do
        if child:GetObjectType() == "Cooldown" then
            cooldown = child
            break
        end
    end
    
    local c  = self.db.profile.fontColor
    button.cooldown = cooldown
    button.cooldown.textFrame = CreateFrame("Frame", "CoolDownButton"..i.."CooldownText", UIParent)
    button.cooldown.textFrame:SetAllPoints(button)
    button.cooldown.textFrame.text = cooldown.textFrame:CreateFontString(nil, "OVERLAY")
    button.cooldown.textFrame.text:SetPoint("CENTER", cooldown.textFrame, "CENTER", 0, -33 * self.db.profile.scale)
    button.cooldown.textFrame.text:SetFont(LSM:Fetch("font", self.db.profile.font), 15 * self.db.profile.scale, "OUTLINE")
    button.cooldown.textFrame.text:SetTextColor(c.Red, c.Green,  c.Blue,  c.Alpha)
    button.cooldown.textFrame.text:SetText("00:00")
    button.cooldown.textFrame:SetFrameStrata("HIGH")
    button.cooldown.textFrame:Show()
    
    button:Hide()
    return button
end

function CoolDownButtons:gsub(text, variable, value)
	if (value) then
		text = string.gsub(text, variable, value);
	elseif (string.find(text, " "..variable)) then
		text = string.gsub(text, " "..variable, "");
	else
		text = string.gsub(text, variable, "");
	end
	return text;
end

function  CoolDownButtons:ResetCooldowns()
    cooldowns = {}  
    for key, button in pairs(self.cdbtns) do
        button:Hide()
        button.cooldown.textFrame.text:Hide()
        button.used = false
        button.usedInBar = ""
    end
    if not self.testMode then
        self:SPELL_UPDATE_COOLDOWN()
        self:BAG_UPDATE_COOLDOWN()
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
end

function CoolDownButtons:EndTestMode(force)
    ChatFrame2:AddMessage("ende")
    CoolDownButtons.testMode = false
    CoolDownButtons:ResetCooldowns()
	CoolDownButtons:SendMessage("CoolDownButtonsTestModeEnd")
    if force then
        LibStub("AceTimer-3.0"):CancelTimer(CoolDownButtons.AceTimerHandler)
    end
end

function CoolDownButtons:StartTestMode(mode)
    self.AceTimerHandler = LibStub("AceTimer-3.0"):ScheduleTimer(CoolDownButtons.EndTestMode, self.testModeTime)
    self.testMode = true
    self.testModeData = mode
    self.testModeStart = GetTime()
    self:ResetCooldowns()
    self:SetUpTestModeFakeCDS(mode)
    ChatFrame2:AddMessage("start")
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
end


-- http://www.wowwiki.com/HOWTO:_Do_Tricks_With_Tables#Iterate_with_sorted_keys
function sortedpairs(t,comparator)
    local sortedKeys = {};
	table.foreach(t, function(k,v) table.insert(sortedKeys,k) end);
	table.sort(sortedKeys,comparator);
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
        ChatFrame2:AddMessage("Position in the row: "..cooldown["order"])
        ChatFrame2:AddMessage("Used in the row: "..frame.usedInBar)
        ChatFrame2:AddMessage("----------------------")
    end
end
