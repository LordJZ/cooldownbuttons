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
CoolDownButtonAnchor:SetFrameStrata("HIGH")

CoolDownButtonAnchor.texture = CoolDownButtonAnchor:CreateTexture(nil,"OVERLAY")
CoolDownButtonAnchor.texture:SetTexture("Interface\\Icons\\Spell_Nature_WispSplode")
CoolDownButtonAnchor.texture:SetAllPoints(CoolDownButtonAnchor)

local cooldowns = {}

local defaults = {
	profile = {
        font        = "Skurri",
        scale       = 0.85,
        alpha       = 1,
		direction   = "right",
        maxbuttons  = 10,
        showAnchor  = true,
        X_Anchor    = UIParent:GetWidth() / 2,   --default to screen center 
        Y_Anchor    = UIParent:GetHeight() / 2,  --default to screen center 
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
        itemShowAfterMaxDurationPassed = true,
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
    self.numcooldownbuttons = 1
    self.cdbtns = {}
    for i = 1, self.numcooldownbuttons do
        self.cdbtns[i] = self:createButton(i)
    end
    if self.db.profile.showAnchor then
        CoolDownButtonAnchor:Show()
    else
        CoolDownButtonAnchor:Hide()
    end	
    CoolDownButtonAnchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.profile.X_Anchor, self.db.profile.Y_Anchor)
    local frame = CreateFrame("Frame"); frame:SetScript("OnUpdate", Text_OnUpdate2)
end

function CoolDownButtons:SaveAnchorPos(anchor)
    self.db.profile.Y_Anchor = anchor:GetBottom()
    self.db.profile.X_Anchor = anchor:GetLeft()
end
function CoolDownButtons:CoolDownButtonsConfigChanged()
    if self.db.profile.showAnchor then
        CoolDownButtonAnchor:Show()
    else
        CoolDownButtonAnchor:Hide()
    end	
end

function Text_OnUpdate2()
    for key, cooldown in pairs(cooldowns) do
        if type(cooldown) == "table" then
            local frame = CoolDownButtons.cdbtns[cooldown["buttonID"]]
            local kids = { frame:GetChildren() };
            local cooldownframe
            for _, child in ipairs(kids) do
                if child:GetObjectType() == "Cooldown" then
                    cooldownframe = child
                    break
                end
            end
            frame:Show()
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
                    cooldowns[key] = nil
                    frame.used = false
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
                    cooldowns[key] = nil
                    frame.used = false
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
                    cooldowns[key] = nil
                    frame.used = false
                end
            end 

            -- set position, scaling and alpha :)
            local order = cooldown["order"] - 1
            local scale = CoolDownButtons.db.profile.scale
            local alpha = CoolDownButtons.db.profile.alpha

            frame:SetWidth (45 * scale)
            frame:SetHeight(45 * scale)
            frame:GetNormalTexture():SetWidth(75 * scale)
            frame:GetNormalTexture():SetHeight(75 * scale)
            cooldownframe.textFrame.text:SetPoint("CENTER", cooldownframe.textFrame, "CENTER", 0, -33 * scale)
            cooldownframe.textFrame.text:SetFont(LSM:Fetch("font", CoolDownButtons.db.profile.font), 15 * scale, "OUTLINE")

            frame:ClearAllPoints()

            local save = CoolDownButtons.db.profile.saveToPos
            if save[cooldown["name"]] and save[cooldown["name"]].saved then
                local pos = save[cooldown["name"]].pos
                frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", pos.x, pos.y)
            else
                if CoolDownButtons.db.profile.direction == "left" then
                    frame:SetPoint("CENTER", CoolDownButtonAnchor, "CENTER", - (50 * order * scale), 0)
                elseif CoolDownButtons.db.profile.direction == "right" then
                    frame:SetPoint("CENTER", CoolDownButtonAnchor, "CENTER", (50 * order * scale), 0)
                elseif CoolDownButtons.db.profile.direction == "up" then
                    frame:SetPoint("CENTER", CoolDownButtonAnchor, "CENTER", 0, (65 * order * scale))
                elseif CoolDownButtons.db.profile.direction == "down" then 
                    frame:SetPoint("CENTER", CoolDownButtonAnchor, "CENTER", 0, - (65 * order * scale))
                end
            end

            frame:SetAlpha(alpha)
            cooldownframe.textFrame:SetAlpha(alpha)
        end
    end
    CoolDownButtons:SPELL_UPDATE_COOLDOWN()
    CoolDownButtons:BAG_UPDATE_COOLDOWN()
end

function CoolDownButtons:SPELL_UPDATE_COOLDOWN()
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
                    local freeindex, nextindex = self:getFreeFrame()
                    if freeindex or nextindex then
                        local saved = nil
                        if self.db.profile.saveToPos[spellName].default then
                            self.db.profile.saveToPos[spellName].default = false -- added to DB!
                            self.db.profile.saveToPos[spellName].cdtype  = "spell"
                            CoolDownButtonsConfig:InitPositions()
                        end
                        if self.db.profile.saveToPos[spellName].saved then
                            saved = 1
                        end
                        if freeindex == nil and nextindex then
                            self.cdbtns[nextindex] = self:createButton(nextindex)
                            self.numcooldownbuttons = self.numcooldownbuttons + 1
                        elseif freeindex then
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
                            --self:Print("Spell: "..spellName.." assigned to button: "..freeindex)
                            self.cdbtns[freeindex].used = true
                        end
                    end
                end 
            end
        end
    end
    self:sortButtons()
end

function CoolDownButtons:BAG_UPDATE_COOLDOWN()
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
                local freeindex, nextindex = self:getFreeFrame()
                if freeindex or nextindex then
                    local saved = nil
                    if self.db.profile.saveToPos[name].default then
                        self.db.profile.saveToPos[name].default = false -- added to DB!
                        self.db.profile.saveToPos[name].cdtype  = "item"
                        CoolDownButtonsConfig:InitPositions()
                    end
                    if self.db.profile.saveToPos[name].saved then
                        saved = 1
                    end
                    if freeindex == nil and nextindex then
                        self.cdbtns[nextindex] = self:createButton(nextindex)
                        self.numcooldownbuttons = self.numcooldownbuttons + 1
                    elseif freeindex then
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
                    local freeindex, nextindex = self:getFreeFrame()
                    if freeindex or nextindex then
                        local saved = nil
                        if self.db.profile.saveToPos[name].default then
                            self.db.profile.saveToPos[name].default = false -- added to DB!
                            self.db.profile.saveToPos[name].cdtype  = "item"
                            CoolDownButtonsConfig:InitPositions()
                        end
                        if self.db.profile.saveToPos[name].saved then
                            saved = 1
                        end
                        if freeindex == nil and nextindex then
                            self.cdbtns[nextindex] = self:createButton(nextindex)
                            self.numcooldownbuttons = self.numcooldownbuttons + 1
                        elseif freeindex then
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
                                order     = 0,   -- display position
                                saved     = saved,   -- position saved?
                            }
                            self.cdbtns[freeindex].used = true
                        end
                    end
                end
            end
		end
	end
    self:sortButtons()
end

function CoolDownButtons:getItemGroup(itemid)
    for groupKey, value in pairs(self.itemgroups) do
        if type(value) == "table" then
            for _, curid in pairs(value.ids) do
                if curid == tonumber(itemid) then
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
    for key, cooldown in pairs(cooldowns) do
        if type(cooldown) == "table" then
            cooldown = nil
        end
    end
    cooldowns = nil
    cooldowns = {}
    for i = 1, self.numcooldownbuttons do
        self.cdbtns[i]:Hide()
        self.cdbtns[i].used = false
    end
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

function CoolDownButtons:getFreeFrame()
    local x
    for i = 1, self.numcooldownbuttons do
        x = i
        if self.cdbtns[i].used == false and i <= self.db.profile.maxbuttons then
            return i, nil
        end
    end
    x = x + 1
    if x <= self.db.profile.maxbuttons then
        return nil, x
    else
        return nil, nil
    end
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
                                                if CoolDownButtons.db.profile.chatPost then
                                                    GameTooltip:SetText(cooldown["name"]..": Click to Post Cooldown")
                                                else
                                                    GameTooltip:SetText(cooldown["name"])
                                                end
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

    button.used = false
    button.id   = i

    local cooldown -- Get Cooldown Frame
    local kids = { button:GetChildren() };
    for _, child in ipairs(kids) do
        if child:GetObjectType() == "Cooldown" then
            cooldown = child
            break
        end
    end
    
    cooldown.textFrame = CreateFrame("Frame", "CoolDownButton"..i.."CooldownText", cooldown:GetParent())
    cooldown.textFrame:SetAllPoints(button)
    cooldown.textFrame:SetFrameLevel(cooldown.textFrame:GetFrameLevel() + 1)
    cooldown.textFrame.text = cooldown.textFrame:CreateFontString(nil, "OVERLAY")
    cooldown.textFrame.text:SetPoint("CENTER", cooldown.textFrame, "CENTER", 0, -33 * self.db.profile.scale)
    cooldown.textFrame.text:SetFont(LSM:Fetch("font", self.db.profile.font), 15 * self.db.profile.scale, "OUTLINE")
    cooldown.textFrame.text:SetTextColor(10,10,10)
    cooldown.textFrame.text:SetText("00:00")
    cooldown.textFrame:Show()

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
        button.used = false
    end
    self:SPELL_UPDATE_COOLDOWN()
    self:BAG_UPDATE_COOLDOWN()
end

function CoolDownButtons:sortButtons()
    local i = 1
    for key, cooldown in pairs(cooldowns) do
        if type(cooldown) == "table" and cooldown["saved"] ~= 1 then
            cooldown["order"] = i
            i = i + 1
        end
    end
end
