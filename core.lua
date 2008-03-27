--[[
Autor: Dodge (Netrox @ Sen'Jin-EU)

  by using this piece of software, you accept that it
  has no warranty at all, use it at your own risk.

  - all rights reserved -
  
Date: $Date$
]]

local LibStub = LibStub
CoolDownButtons = LibStub("AceAddon-3.0"):NewAddon("CoolDown Buttons", "AceConsole-3.0", "AceEvent-3.0")
local CoolDownButtons = CoolDownButtons
local rev = tonumber(("$Revision$"):match("%d+")) or 0
CoolDownButtons.rev = rev
local L = LibStub("AceLocale-3.0"):GetLocale("CoolDown Buttons", false)
local LSM = LibStub("LibSharedMedia-2.0")
LSM:Register("font", "Skurri", [[Interface\AddOns\CoolDownButtons\skurri.ttf]])
local LS2 = LibStub("LibSink-2.0")

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
local GetSpellLink = GetSpellLink
local table_insert = table.insert
local CreateFrame = CreateFrame
local string_gsub = string.gsub
local string_find = string.find
local table_sort = table.sort
local math_floor = math.floor
local math_fmod = math.fmod
local tostring = tostring
local tonumber = tonumber
local select = select
local pairs = pairs
local type = type
local CDB_SetCooldown = getmetatable(CreateFrame('Cooldown', nil, nil, 'CooldownFrameTemplate')).__index.SetCooldown


-- from ckknight's LibDogTag-3.0, with his permission:
local poolNum = 0
local newList, newDict, del, deepDel, deepCopy
do
	local pool = setmetatable({}, {__mode='k'})
    function newList(...)
		poolNum = poolNum + 1
		local t = next(pool)
		if t then
			pool[t] = nil
			for i = 1, select('#', ...) do
				t[i] = select(i, ...)
			end
		else
			t = { ... }
		end
		-- if TABLE_DEBUG and pool == normalPool then
		-- 	TABLE_DEBUG[#TABLE_DEBUG+1] = { '***', "newList", poolNum, tostring(t), debugstack() }
		-- end
		return t
	end
	function newDict(...)
		poolNum = poolNum + 1
		local t = next(pool)
		if t then
			pool[t] = nil
		else
			t = {}
		end
		for i = 1, select('#', ...), 2 do
			t[select(i, ...)] = select(i+1, ...)
		end
		-- if TABLE_DEBUG and pool == normalPool then
		-- 	TABLE_DEBUG[#TABLE_DEBUG+1] = { '***', "newDict", poolNum, tostring(t), debugstack() }
		-- end
		return t
	end
	function del(t)
		if type(t) ~= "table" then
			error("Bad argument #1 to `del'. Expected table, got nil.", 2)
		end
		if pool[t] then
			error("Double-free syndrome.", 2)
		end
		pool[t] = true
		poolNum = poolNum - 1
		for k in pairs(t) do
			t[k] = nil
		end
		setmetatable(t, nil)
		t[''] = true
		t[''] = nil
		
		-- if TABLE_DEBUG then
		-- 	local tostring_t = tostring(t)
		-- 	TABLE_DEBUG[#TABLE_DEBUG+1] = { '***', "del", poolNum, tostring_t, debugstack() }
		-- 	for _, line in ipairs(TABLE_DEBUG) do
		-- 		if line[4] == tostring_t then
		-- 			line[1] = ''
		-- 		end
		-- 	end
		-- 	pool[t] = nil
		-- end
		return nil
	end
	local deepDel_data
	function deepDel(t)
		local made_deepDel_data = not deepDel_data
		if made_deepDel_data then
			deepDel_data = newList()
		end
		if type(t) == "table" and not deepDel_data[t] then
			deepDel_data[t] = true
			for k,v in pairs(t) do
				deepDel(v)
				deepDel(k)
			end
			del(t)
		end
		if made_deepDel_data then
			deepDel_data = del(deepDel_data)
		end
		return nil
	end
	function deepCopy(t)
		if type(t) ~= "table" then
			return t
		else
			local u = newList()
			for k, v in pairs(t) do
				u[deepCopy(k)] = deepCopy(v)
			end
			return u
		end
	end
end
-- end of ckknight's code

CoolDownButtonAnchor = newList()
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

local cooldowns = newList()
local spellTable = newList()
local cooldownsChanged = false

local defaults = {
	profile = {
        font        = "Skurri",
        fontColor   = { Red = 1, Green = 1, Blue = 1, Alpha = 1, },
        fontColor20sec = { Red = 1, Green = 0.6, Blue = 0.25, Alpha = 1, },
        fontColor5sec = { Red = 1, Green = 0, Blue = 0, Alpha = 1, },
        timerStyle  = "00:00m",
        timedColors = false,
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
        chatSink = { sink20OutputSink = "None" },
        useSink = true,
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

function CoolDownButtons:GetNumButtons()
    return self.numcooldownbuttons
end

function CoolDownButtons:OnEnable()
    if LS2 then
        LS2.SetSinkStorage(self, self.db.profile.chatSink)
    end
    
    self.spellTable = spellTable
    self:ResetSpells()

    self.testMode = false
    self.testModeTime = 15
    self.testModeStart = 0
    self.testModeData = newList()
    
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

    self.numcooldownbuttons = 0
    self.cdbtns = newList()

    -- Hack to keep code "dry" :)
    self:CoolDownButtonsConfigChanged()

    local frame = CreateFrame("Frame"); frame:SetScript("OnUpdate", CoolDownButtons_UPDATE)
end

function CoolDownButtons:ResetSpells()
    spellTable = deepDel(spellTable)
	spellTable = newList()
	for spellTree = 1, GetNumSpellTabs() do
		local treeName, treeTexture, offset, num = GetSpellTabInfo(spellTree)
		for j = 1, num do
			local spellIndex = offset + j
			local spellName, spellID  = self:myGetSpellName(spellIndex)
            if not spellTable[spellName] then
                spellTable[spellName] = newDict(
                    "spellName"    , spellName,
                    "spellIndex"   , spellIndex,
                    "spellTexture" , GetSpellTexture(spellIndex, BOOKTYPE_SPELL),
                    "spellTree"    , newDict(
                        "treeIndex"   , spellTree,
                        "treeName"    , treeName,
                        "treeTexture" , treeTexture
                    )
                )
            end
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
            local time = cooldown["start"] + cooldown["duration"] - GetTime()
            local forBar = frame.usedInBar
            if not CoolDownButtons.db.profile.splitRows and forBar == "items" then   forBar = "spells"   end
            if not CoolDownButtons.db.profile.splitSoon and forBar == "soon"  then   forBar = "spells"   end

            frame:Show()
            frame.text:Show()
            if not CoolDownButtons.testMode then
                if cooldown["cdtype"] == "spell" and not cooldown["subtype"] then -- spell
                    local cooldownCheck = GetSpellCooldown(cooldown["id"], BOOKTYPE_SPELL)
                    if (not cooldownCheck) or cooldownCheck == 0 then
                        hideFrame = true
                    end
                elseif cooldown["cdtype"] == "spell" and (cooldown["subtype"] == "tree") then -- spelltree
                    local cooldownCheck = GetSpellCooldown(cooldown["subid"], BOOKTYPE_SPELL)
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
                if time < 0 then
                    hideFrame = true
                end
            end
            if hideFrame or cooldown.forceHide then
                frame.pulse.icon:Hide() -- Should avoid bugged pulses
                if CoolDownButtons.db.profile.anchors[forBar].usePulse 
                and not cooldown.forceHide 
                and not CoolDownButtons.db.profile.anchors[forBar].showOmniCC then
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
                            if LS2 and CoolDownButtons.db.profile.useSink then
                                local message = CoolDownButtons:gsub(L["Cooldown on $obj ready!"], "$obj", cooldown["name"])
                                LS2.Pour(CoolDownButtons, message)
                            end
                            frame:Hide()
                            frame.text:Hide()
                            cooldowns[key] = del(cooldowns[key])
                            frame.used = false
                            frame.usedInBar = ""
                            cooldownsChanged = true
                        else
                            pulse.icon:Show()
                            pulse.icon:SetHeight(pulse:GetHeight() * pulse.scale)
                            pulse.icon:SetWidth(pulse:GetWidth() * pulse.scale)
                        end
                    end
                else
                    if LS2 and CoolDownButtons.db.profile.useSink then
                        local message = CoolDownButtons:gsub(L["Cooldown on $obj ready!"], "$obj", cooldown["name"])
                        LS2.Pour(CoolDownButtons, message)
                    end
                    frame:Hide()
                    frame.text:Hide()
                    cooldowns[key] = del(cooldowns[key])
                    frame.used = false
                    frame.usedInBar = ""
                    cooldownsChanged = true
                end
            else
                local remaining = tonumber(string.format("%.3f", cooldown["start"] + cooldown["duration"] - GetTime() ))
                if CoolDownButtons.db.profile.splitSoon and remaining < CoolDownButtons.db.profile.anchors.soon.timeToSplit then
                    cooldownsChanged = true
                end
                frame.text:SetText(CoolDownButtons:formatCooldownTime(cooldown, true))
                local tC = CoolDownButtons.db.profile.timedColors
                local c = CoolDownButtons.db.profile.fontColor
                if tC and (time < 20) and (time > 5) then
                    c = CoolDownButtons.db.profile.fontColor20sec
                elseif tC and (time <= 5) then
                    c = CoolDownButtons.db.profile.fontColor5sec
                end
                frame.text:SetTextColor(c.Red, c.Green,  c.Blue,  c.Alpha)
                frame.texture:SetTexture(cooldown["texture"])
                frame.cooldown:SetCD(cooldown["start"], 
                    cooldown["duration"], 
                    CoolDownButtons.db.profile.anchors[forBar].showOmniCC)
            end
            if frame.used then
                local order = cooldown["order"] - 1
                
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
                    frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", pos.x / scale, pos.y / scale)
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

                frame:SetAlpha(alpha)               
                frame.text:SetAlpha(textAlpha)
                if not CoolDownButtons.db.profile.anchors[forBar].showTime then
                   frame.text:Hide()
                end
            end
        end
    end
    -- Disabled :SPELL_UPDATE_COOLDOWN()
    -- It Bugs with spellTreeTable
    -- CoolDownButtons:SPELL_UPDATE_COOLDOWN() 
    CoolDownButtons:BAG_UPDATE_COOLDOWN()
end

function CoolDownButtons:SPELL_UPDATE_COOLDOWN()
    if self.testMode then return end
    local spellsToAdd = newList()
    local spellTreeTable = newList({},{},{},{})
    for k, spellData in pairs(spellTable) do
        local spellName  = spellData.spellName
        local spellIndex = spellData.spellIndex
        local start, duration, enable = GetSpellCooldown(spellIndex, BOOKTYPE_SPELL)
        local remaining = 0
        if self.db.profile.spellShowAfterMaxDurationPassed then
            remaining = start + duration - GetTime()
        else
            remaining = duration
        end
		local check = enable == 1 and start > 0 and duration > 3 -- GCD
        check = check and remaining < self.db.profile.maxSpellDuration 
        check = check and self.db.profile.saveToPos[spellName].show
        if check then
            spellTreeTable[spellData.spellTree.treeIndex][start*duration] = 1 + (spellTreeTable[spellData.spellTree.treeIndex][start*duration] or 0)
            if not cooldowns[spellName] then
                spellsToAdd[spellName] = newList(spellTable[spellName].spellIndex, start, duration)
            end
        end
    end
    for treeIndex = 1, GetNumSpellTabs() do 
        for time in pairs(spellTreeTable[treeIndex]) do
            if spellTreeTable[treeIndex][time] > 3 then
                local start, duration, spellIndex = nil, nil, nil
                for name, data in pairs(spellsToAdd) do
                    if treeIndex == spellTable[name].spellTree.treeIndex then
                        if data[2] * data[3] == time then
                            spellsToAdd[name] = nil
                            start, duration, spellIndex = data[2], data[3], data[1]
                        end
                    end
                end
                local treeName, treeTexture = GetSpellTabInfo(treeIndex)
                if not cooldowns[treeName] then
                    local freeindex = self:getFreeFrame(treeName, "spells")
                    if freeindex then             
                        local saved = nil
                        if self.db.profile.saveToPos[treeName].default then
                            self.db.profile.saveToPos[treeName].default = false -- added to DB!
                            self.db.profile.saveToPos[treeName].cdtype  = "spell"
                            CoolDownButtonsConfig:InitPositions()
                        end
                        if self.db.profile.saveToPos[treeName].saved then
                            saved = 1
                        end
                        cooldowns[treeName] = newList()
                        cooldowns[treeName].cdtype    = "spell"       -- "item" or "spell"
                        cooldowns[treeName].subtype   = "tree"
                        cooldowns[treeName].id        = treeIndex    -- itemid or spellid
                        cooldowns[treeName].subid     = spellIndex
                        cooldowns[treeName].name      = treeName     -- item or spell name
                        cooldowns[treeName].start     = start         -- cooldown start time
                        cooldowns[treeName].duration  = duration      -- cooldown duration
                        cooldowns[treeName].texture   = treeTexture  -- item or spell texture
                        cooldowns[treeName].buttonID  = freeindex     -- assign to button #?
                        cooldowns[treeName].order     = 0             -- display position
                        cooldowns[treeName].saved     = saved         -- position saved?
                        self.cdbtns[freeindex].used = true
                        if saved ~= 1 then
                            self.cdbtns[freeindex].usedInBar = "spells"
                        else
                            self.cdbtns[freeindex].usedInBar = "single"
                        end

                        cooldownsChanged = true
                    end
                end
            end
        end
    end
    for spellName in pairs(spellsToAdd) do
        local spellIndex = spellTable[spellName].spellIndex
        local spellTexture = spellTable[spellName].spellTexture
        local start, duration = GetSpellCooldown(spellIndex, BOOKTYPE_SPELL)
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
            cooldowns[spellName] = newList()
            cooldowns[spellName].cdtype    = "spell"       -- "item" or "spell"
            cooldowns[spellName].id        = spellIndex    -- itemid or spellid
            cooldowns[spellName].name      = spellName     -- item or spell name
            cooldowns[spellName].start     = start         -- cooldown start time
            cooldowns[spellName].duration  = duration      -- cooldown duration
            cooldowns[spellName].texture   = spellTexture  -- item or spell texture
            cooldowns[spellName].buttonID  = freeindex     -- assign to button #?
            cooldowns[spellName].order     = 0             -- display position
            cooldowns[spellName].saved     = saved         -- position saved?

            if spellName == L["Spellgroup: Shocks"] or spellName == L["Spellgroup: Traps"] or spellName == L["Spellgroup: Divine Shields"] then
                cooldowns[spellName].texture = self.spellgroups[spellName].texture
            end
            
            self.cdbtns[freeindex].used = true
            if saved ~= 1 then
                self.cdbtns[freeindex].usedInBar = "spells"
            else
                self.cdbtns[freeindex].usedInBar = "single"
            end

            cooldownsChanged = true
        end
        
    end
    spellTreeTable = deepDel(spellTreeTable)
    spellsToAdd = del(spellsToAdd)
    self:sortButtons()
end

function CoolDownButtons:BAG_UPDATE_COOLDOWN()
    if self.testMode then return end
  	for i=1,18 do
		local start, duration, enable = GetInventoryItemCooldown("player", i)
        if self.db.profile.itemShowAfterMaxDurationPassed then
            remaining = start + duration - GetTime()
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
                    cooldowns[name] = newList()
                    cooldowns[name].cdtype    = "eq_item"    -- "item" or "spell"
                    cooldowns[name].id        = i            -- itemid or spellid
                    cooldowns[name].name      = name         -- item or spell name
                    cooldowns[name].start     = start        -- cooldown start time
                    cooldowns[name].duration  = duration     -- cooldown duration
                    cooldowns[name].texture   = itemTexture  -- item or spell texture
                    cooldowns[name].buttonID  = freeindex    -- assign to button #?
                    cooldowns[name].order     = 0   -- display position
                    cooldowns[name].saved     = saved   -- position saved?
                    self.cdbtns[freeindex].used = true
                    if saved ~= 1 then
                        self.cdbtns[freeindex].usedInBar = "items"
                    else
                        self.cdbtns[freeindex].usedInBar = "single"
                    end

                    cooldownsChanged = true
                end
            end
        end
	end
	for i=0, 4 do
		local slots = GetContainerNumSlots(i)
		for j=1, slots do
			local start, duration, enable = GetContainerItemCooldown(i,j)
			if self.db.profile.itemShowAfterMaxDurationPassed then
                remaining = start + duration - GetTime()
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
                        cooldowns[name] = newList()
                        cooldowns[name].cdtype    = "bag_item"   -- "item" or "spell"
                        cooldowns[name].id        = i            -- bag
                        cooldowns[name].id2       = j            -- bag slot
                        cooldowns[name].name      = name         -- item or spell name
                        cooldowns[name].start     = start        -- cooldown start time
                        cooldowns[name].duration  = duration     -- cooldown duration
                        cooldowns[name].texture   = itemTexture  -- item or spell texture
                        cooldowns[name].buttonID  = freeindex    -- assign to button #?
                        cooldowns[name].order     = 0            -- display position
                        cooldowns[name].saved     = saved        -- position saved?
                        self.cdbtns[freeindex].used = true
                        if saved ~= 1 then
                            self.cdbtns[freeindex].usedInBar = "items"
                        else
                            self.cdbtns[freeindex].usedInBar = "single"
                        end

                        cooldownsChanged = true
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
    local spellLink   = GetSpellLink(spell) or "invalid"

    local spellID = 1
    local group   = ""
    local groupKey    = nil

    if spellLink ~= "invalid" then -- Known Bugged Spells where GetSpellLink returns nil: "Faerie Fire (Feral)"
        spellID = select(3, string_find(spellLink, "spell:(%d+)"))
        group   = select(2, LibStub("LibPeriodicTable-3.1"):ItemInSet(spellID, "CDB_Spellgroup"))
    end

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

function CoolDownButtons:getFreeFrame(forThis, whatBar)
    local x = 0
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
                                                    local formated_time = CoolDownButtons:formatCooldownTime(cooldown, false)
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
            cyCircled_CoolDownButtons:AddElement(i)
            cyCircled_CoolDownButtons:ApplySkin()
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

function CoolDownButtons:formatCooldownTime(cooldown, applySettings)
    local time = cooldown["start"] + cooldown["duration"] - GetTime()
    cooldown.time = time
    if time < 0 then
        cooldown.forceHide = true
        return ""
    end
    if applySettings then
        return self:formatTime(time, self.db.profile.timerStyle)
    else
        return self:formatTime(time, "00:00m")
    end
end

function CoolDownButtons:formatTime(time, mode)
    if mode == "00:00m" or mode == "00:00M" then
        if time < 60 then
            return string_format("0:%02d", time)
        elseif time < 3600 then
            local m = math_floor(time / 60)
            local s = math_fmod(time, 60)
            return string_format("%d:%02d", m, s)
        else
            local hr = math_floor(time / 3600)
            local m = math_floor( math.fmod(time, 3600) / 60 )
            if mode == "00:00m" then
                return string_format("%d.%02dh", hr, m)
            else
                return string_format("%d.%02dH", hr, m)
            end
        end
    elseif mode == "0m" or mode == "0M" then
        if time < 60 then
            return string_format("%d", time)
        elseif  time < 3600  then
            local m = math_floor(time / 60)
            if mode == "0m" then
                return string_format("%dm", m)
            else
                return string_format("%dM", m)
            end
            
        else
            local hr = math_floor(time / 3600)
            if mode == "0m" then
                return string_format("%dh", hr)
            else
                return string_format("%dH", hr)
            end
        end
        return floor(s + 0.5), s - floor(s)
    end
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
        cooldownsChanged = true
        cooldowns = deepDel(cooldowns)
        cooldowns = newList()
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
    local numCooldowns = false
    for key, cooldown in pairs(cooldowns) do
        numCooldowns = true
        break
    end
    if numCooldowns and cooldownsChanged then
        cooldownsChanged = false
        local timeToSplit = self.db.profile.anchors.soon.timeToSplit
        local sortMe = newList()
        sortMe["spells"] = newList()
        sortMe["items"]  = newList()
        sortMe["soon"]   = newList()
        for key, cooldown in pairs(cooldowns) do
            if cooldown["saved"] ~= 1 then
                local remaining = tonumber(string.format("%.3f", cooldown["start"] + cooldown["duration"] - GetTime() ))
                if self.db.profile.splitSoon and remaining < timeToSplit then
                    self.cdbtns[cooldown["buttonID"]].usedInBar = "soon"
                    table_insert(sortMe["soon"], newList(remaining, cooldown["name"]))
                else
                    if self.db.profile.splitRows then
                        if cooldown.cdtype == "spell" then
                            table_insert(sortMe["spells"], newList(remaining, cooldown["name"]))
                        elseif cooldown.cdtype == "eq_item" or cooldown.cdtype == "bag_item" then
                            table_insert(sortMe["items"], newList(remaining, cooldown["name"]))
                        end
                    else
                        table_insert(sortMe["spells"], newList(remaining, cooldown["name"]))
                    end
                end
            end
        end
        
        local counts = newList()
        counts["spells"] = 1
        counts["items"]  = 1
        counts["soon"]   = 1
        for bar in pairs(sortMe) do
            table_sort(sortMe[bar], function(a, b) return a[1] < b[1] end)
            for _, data in pairs(sortMe[bar]) do
                cooldowns[data[2]].order = counts[bar]
                counts[bar] = counts[bar] + 1
            end
        end
        self.spellnum = counts["spells"]
        self.itemsnum = counts["items"]
        self.soonnum  = counts["soon"]
        counts = del(counts)
        sortMe = deepDel(sortMe)
    end
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
    local sortedKeys = newList()
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
        local remaining = cooldown["start"] + cooldown["duration"] - GetTime()
        ChatFrame2:AddMessage(cooldown["name"].." @ "..string_format("%.2f", remaining).." of "..cooldown["duration"])
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

-- Rock("LibRockConsole-1.0"):PrintLiteral(CoolDownButtons)