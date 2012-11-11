local engine = { }
CDB.engine = engine

local LS2 = LibStub("LibSink-2.0")
local LSM = LibStub("LibSharedMedia-3.0")
local MSQ = LibStub("Masque", true)
local newList, newDict, del, deepDel, deepCopy = CDB.GetRecyclingFunctions()
local math_ceil = math.ceil
local math_floor = math.floor
local gsub = CDB.gsub
local table_insert = table.insert
local table_remove = table.remove

local function LibSinkMessage(name, texture)
    if LS2 then
        local db = CDB.db.profile.notifications.sink
        local message = gsub(db.message, "$cooldown", name)
        message = gsub(message, "$icon", "|T"..texture.."::|t")
        local tex = ((db.showIcon and texture) or nil)
        local c = db.color
        LS2.Pour(CDB, message, c.Red, c.Green, c.Blue, nil, nil, nil, nil, nil, tex)
    end
end


local UpdateInterval = 0.1; -- How often the OnUpdate code will run (in seconds)
local function OnUpdate(self)
	local nowint = GetTime()
	if nowint == self.lastUpdate then return end
    if not (nowint - self.lastUpdate > UpdateInterval) then return end
    self.lastUpdate = nowint
    
    if not self.obj then return end -- maybe a todo
    
    local start, duration = self.obj:Timer()
    if ((not start) or (start == 0)) or (start+duration < GetTime() ) then --hideFrame
        local db = self.parent.db
        if (not db.showomnicc) and db.showpulse then
            if not self.pulse.active then
                LibSinkMessage(self.obj.name, self.obj.texture)
                self.pulse:SetScript("OnUpdate", self.pulse.handler)
            end
        else
            LibSinkMessage(self.obj.name, self.obj.texture)
            self.text:SetText("")
            self:Hide()
            CDB:RemoveCooldown(self.obj.name) 
        end
    else
        local db = self.parent.db
        local timestamp = start + duration - GetTime()
        if db.showMs and timestamp < (db.showMsLimit + 1) then
            local _, _, sec, ms = string.find(timestamp,"([0-9]*)\.([0-9])")
            if sec == nil then
                sec = 0
            end
            if ms == nil then
                ms= 0
            end
            self.text:SetText(sec.."."..ms)
        else
            self.text:SetText(engine:formatTime(timestamp, db.style))
        end
        
        if db.flash and (timestamp <= db.flashstart) then
            local c
            if (math_floor(timestamp) % 2) == 0 then
                c = db.flashcolor1
            else
                c = db.flashcolor2
            end
            self.text:SetTextColor(c.Red, c.Green,  c.Blue)
        else
            local c = db.color
            self.text:SetTextColor(c.Red, c.Green,  c.Blue)           
        end
    end
end

local function OnEnter(self)
--  GameTooltip:SetOwner(button, "ANCHOR_CURSOR")
--  GameTooltip["Set"..self.obj.type](self.obj.index, BOOKTYPE_SPELL)
--  GameTooltip:Show()
end

local function OnLeave(self)
--  GameTooltip:Hide()
end

local function OnClick(self)
    local db = CDB.db.profile.notifications.chat
    if db.enable then
        local cooldown = self.obj

        local start, duration = cooldown:Timer()
        local time = engine:formatTime(start + duration - GetTime(), "00:00m")
        local message = db.message
        local link = cooldown:Link()
        if link == nil or link == "" then link = cooldown.name end
        message = gsub(message, "$link", link)
        message = gsub(message, "$spell", cooldown.name)
        message = gsub(message, "$time", time)
        
        local targets = db.targets
        if targets["chatframe"] then
            DEFAULT_CHAT_FRAME:AddMessage(message)
        end
        if targets["say"] then
            SendChatMessage(message, "SAY", GetDefaultLanguage("player"))
        end
        if targets["party"] then
            if GetNumGroupMembers() > 0 and not IsInRaid() then
                SendChatMessage(message, "PARTY", GetDefaultLanguage("player"))
            end
        end
        if targets["raid"] then
            if GetNumGroupMembers() > 0 and IsInRaid() then
                SendChatMessage(message, "RAID", GetDefaultLanguage("player"))
            end
        end
        if targets["guild"] then
            if IsInGuild() then
                SendChatMessage(message, "GUILD", GetDefaultLanguage("player"))
            end
        end
        if targets["officer"] then
            -- TODO: Check if you are allowed to write in /o
            SendChatMessage(message, "OFFICER", GetDefaultLanguage("player"))
        end
        if targets["emote"] then
            SendChatMessage(message, "EMOTE", GetDefaultLanguage("player"))
        end
        if targets["raidwarn"] then
            if GetNumGroupMembers() > 0 and IsInRaid() and IsRaidOfficer() then
                SendChatMessage(message, "RAID_WARNING", GetDefaultLanguage("player"))
            end
        end
        if targets["battleground"] then
            if select(2, IsInInstance()) == "pvp" then
                SendChatMessage(message, "BATTLEGROUND", GetDefaultLanguage("player"))
            end
        end
        if targets["yell"] then
            SendChatMessage(message, "YELL", GetDefaultLanguage("player"))
        end
        for i = 5, 10 do
            local channame = tostring(select(2, GetChannelName(i)))
            if targets["channel"..i] and channame ~= "nil" then
                SendChatMessage(message, "CHANNEL", GetDefaultLanguage("player"), i)
            end
        end
        
    end
end

local function OnDragStart(self)
    if self:IsMovable() then
        self.movin = true
        self:StartMoving()
    end
end

local function OnDragStop(self)
    if self:IsMovable() then
        self:StopMovingOrSizing()
        self:SaveAnchorPos()
    end 
end

local function SaveAnchorPos(self)
	local bar = engine.bars[self.name]
	local db = bar.db
	
	db.posx = self:GetLeft()   * db.scale
	db.posy = self:GetBottom() * db.scale
	
    self.movin = false
    engine:SetBarPoints(bar, db)
    LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
end

local function create(name, i)
    local button
    local buttonname = "CooldownButton_"..name.."_"..tostring(i)
    if _G[buttonname] then
        button = _G[buttonname]
        --ChatFrame3:AddMessage("reuseing: "..buttonname)
    else
        --ChatFrame3:AddMessage("creating: "..buttonname)
        
        button = CreateFrame("Button", buttonname, UIParent, "ActionButtonTemplate")

        button.name = name
        button:SetClampedToScreen(true)
        button:EnableMouse(false)
        button:RegisterForDrag("LeftButton")
        button:SetScript("OnUpdate",    OnUpdate)
        button:SetScript("OnEnter",     OnEnter)
        button:SetScript("OnLeave",     OnLeave)
        button:SetScript("OnClick",     OnClick)
        button:SetScript("OnDragStart", OnDragStart)
        button:SetScript("OnDragStop",  OnDragStop)
        button:SetScript("OnShow", function(self) self.text:DoShow() self.lastUpdate = 0 end)
        button:SetScript("OnHide", function(self) self.text:Hide() end)
        button.SaveAnchorPos = SaveAnchorPos
        
        button.texture  = _G[("%sIcon"):format(button:GetName())]
        button.cooldown = _G[("%sCooldown"):format(button:GetName())]
        button.cooldown.myname = buttonname

        button.lastUpdate = floor(GetTime() + 0.5)

        -- Text
        button.textFrame = CreateFrame("Frame", "CooldownButton"..tostring(i).."CooldownText", UIParent)
        button.textFrame:SetAllPoints(button)
        button.textFrame:SetFrameLevel(button.cooldown:GetFrameLevel() + 1)
        button.text = button.textFrame:CreateFontString(nil, "OVERLAY")
        button.text:SetJustifyH("CENTER")
        button.text.DoShow = function(self) if self.show then self:Show() end end
        button:Hide()
        
        -- Pulse
        button.pulse = CreateFrame('Frame', nil, button)
        button.pulse:SetAllPoints(button)
        button.pulse:SetToplevel(true)
        button.pulse.icon = button:CreateTexture(nil, 'OVERLAY')
        button.pulse.icon:SetPoint('CENTER')
        button.pulse.icon:SetBlendMode('ADD')
        button.pulse.icon:SetHeight(button:GetHeight())
        button.pulse.icon:SetWidth(button:GetWidth())
        button.pulse.icon:Hide()
        button.pulse.active = false
        button.pulse.handler = function(self, elapsed)
            local frame = self:GetParent()
            if not frame.pulse.active then
                local icon = frame.texture
                if icon and frame:IsVisible() then
                    self.scale = 1
                    self.icon:SetTexture(icon:GetTexture())
                    local r, g, b = icon:GetVertexColor()
                    self.icon:SetVertexColor(r, g, b, 0.7)
                    frame.pulse.active = true
                end
            else
                if self.scale >= 2 then
                    self.dec = 1
                end
                self.scale = max(min(self.scale + (self.dec and -1 or 1) * self.scale * (elapsed/0.5), 2), 1)
                if self.scale <= 1 then
                    self.icon:Hide()
                    self.dec = nil
                    frame.pulse.active = false
                    frame:Hide()
                    CDB:RemoveCooldown(frame.obj.name)
                    self:SetScript("OnUpdate", nil)
                else
                    self.icon:Show()
                    self.icon:SetHeight(self:GetHeight() * self.scale)
                    self.icon:SetWidth(self:GetWidth() * self.scale)
                end
            end
        end
    end
    return button
end

function engine:Init()
    self.db = CDB.db
    self.cooldowns = CDB.cooldowns
    self.cooldownsSort = CDB.cooldownsSort

    self.bars = {}
    for name, conf in pairs(self.db.profile.bars) do
        self.bars[name] = self:CreateBar(name, conf)
    end
end

function engine:Update()
    for barName, barData in pairs(self.bars) do
        local i = 1
        local db = barData.db
        local buttons = barData.buttons
        for _, name in pairs(self.cooldownsSort) do
            local data = self.cooldowns[name]
            local start, duration = data:Timer()
            if (not db.limitMin or duration > db.limitMinTime) and data.active and self:IsInBar(name, barName) and i <= #buttons then
                local button = buttons[i]
                button.obj = data
                button.texture:SetTexture(data.texture)
                button.cooldown:SetCooldown(start, duration)
                button:Show()
                i = i+1
            end
        end
        do
            if db.center then
                local used = i - 1
                local button = buttons[1]
                button:ClearAllPoints()
                
                --if not db.multirow then
                    local offsetx, offsety
                    if db.direction == "left" or db.direction == "right" then
                        local width = button:GetWidth() * db.scale

                        offsety = 0
                        offsetx = ((((width + db.spacing) * used)) / 2) - ((width + db.spacing) / 2)
                        if db.direction == "right" then
                            offsetx = offsetx * -1
                        end
                    elseif db.direction == "up" or db.direction == "down" then 
                        local height = button:GetHeight() * db.scale

                        offsetx = 0
                        offsety = ((((height + db.spacing) * used)) / 2) - ((height + db.spacing) / 2)
                        if db.direction == "up" then
                            offsety = offsety * -1
                        end
                    end
                    offsetx = offsetx / db.scale
                    offsety = offsety / db.scale
                    button:SetPoint("CENTER", barData.anchor, "CENTER", offsetx, offsety)                    
                --else
                    -- TODO: multirow + center
                --end
            end
        end
        -- Hide Other Buttons! :)
        while i <= #buttons do
            buttons[i].obj = nil
            buttons[i]:Hide()
            i = i+1
        end
    end
end

function engine:UpdateConfig(name, db, option)
    local bar = self.bars[name]

    if option == "posx"      or option == "posy"
    or option == "direction" or option == "rowdirection"
    or option == "spacing"   or option == "rowspacing"
    or option == "multirow"  or option == "countperrow"
    or option == "scale"     or option == "alpha"
    then
        self:SetBarPoints(bar, db)
    elseif option == "textdirection" or option == "textalpha"
        or option == "textdistance"  or option == "fontoutline"
        or option == "fontface"      or option == "fontsize"
        or option == "color"
    then
        self:SetLabelFont(bar, db)
    elseif option == "showomnicc" or option == "showspiral"
        or option == "showtime" or option == "showpulse"
    then
        self:SetSpiralStuff(bar, db)
    elseif option == "count" then
        local count = bar.btncount
        if count > db.count then
            for i = 1, count - db.count, 1 do
                bar.buttons[db.count+1]:Hide()
                table_remove(bar.buttons, db.count+1)
            end
            bar.btncount = db.count
            CDB:Print(CDB.L["UI_RELOAD_WARNING"])
        elseif count < db.count then
            for i = count+1, db.count, 1 do
                local button = create(name, i)
                button.parent = bar
                table_insert(bar.buttons, button)
            end
            bar.btncount = db.count
        end
        self:SetBarPoints(bar, db)
        self:Update()
    elseif option == "center" then
        self:SetBarPoints(bar, db)
        self:Update()
    elseif option == "limitMin" or option == "limitMinTime"
    or option == "limitMax" or option == "limitMaxTime" or option == "limitAfterMax" then
        self:Update()
    elseif option == "type2bar" or option == "hiddenCooldowns" then
        self:Update()
    -------------------
    --- todo: continue here !
    -------------------
    end
end

function engine:IsInBar(name, bar)
    local cooldown = self.cooldowns[name]
    local type2bar = self.db.profile.type2bar[cooldown.type][bar]
    local hiddenCooldowns = self.db.profile.hiddenCooldowns[cooldown.type]
    
    -- if cooldown is a preview cooldown, then its in ALL bars :)
    if cooldown.preview then return true end
    
    if hiddenCooldowns[name].hidden then
        return false
    end
    
    return type2bar
end

function engine:CreateBar(name, db)
    local bar = { db = db, }
    bar.anchor = create(name, "Anchor")
    --bar.anchor:Show()
    bar.anchor:SetMovable(true)
    bar.anchor:SetFrameStrata("HIGH")
    bar.anchor.texture:SetTexture("Interface\\Icons\\ability_seal")
    -- create buttons
    bar.buttons = { }
    bar.btncount = db.count
    bar.width = 0
    for i = 1, db.count, 1 do
        local button = create(name, i)
        button.parent = bar
        table_insert(bar.buttons, button)
    end
    self:SetBarPoints(bar, db)
    self:SetLabelFont(bar, db)
    self:SetSpiralStuff(bar, db)
    
    if MSQ then
        self.barGroup = MSQ:Group("Cooldown Buttons", name)
        self.barGroup:AddButton(bar.anchor)
        for k, v in pairs(bar.buttons) do
            self.barGroup:AddButton(v)
        end
    end
    
    return bar
end

function engine:SetLabelFont(bar, db)
    local buttons = bar.buttons
    for k, v in pairs(buttons) do
        v.text:SetFont(LSM:Fetch("font", db.fontface), db.fontsize, db.fontoutline ~= "none" and db.fontoutline or nil)
        v.text:SetTextColor(db.color.Red, db.color.Green, db.color.Blue)
        v.text:SetAlpha(db.textalpha)
        
        v.text:ClearAllPoints()
        if db.textdirection == "left" then
            v.text:SetPoint("RIGHT", v, "LEFT", -(db.textdistance), 0)
            v.text:SetJustifyH("RIGHT") 
        elseif db.textdirection == "right" then
            v.text:SetPoint("LEFT", v, "RIGHT",   db.textdistance, 0)
            v.text:SetJustifyH("LEFT") 
        elseif db.textdirection == "up" then
            v.text:SetPoint("BOTTOM", v, "TOP", 0, db.textdistance)
            v.text:SetJustifyH("CENTER") 
        elseif db.textdirection == "down" then 
            v.text:SetPoint("TOP", v, "BOTTOM", 0, -(db.textdistance))
            v.text:SetJustifyH("CENTER") 
        elseif db.textdirection == "center" then 
            v.text:SetPoint("CENTER", v, "CENTER", 0, 0)
            v.text:SetJustifyH("CENTER") 
        end
    end
end

function engine:SetSpiralStuff(bar, db)
    local buttons = bar.buttons
    for k, v in pairs(buttons) do
        v.cooldown.noCooldownCount = not db.showomnicc
        if db.showomnicc then
            v.cooldown:SetAlpha(1)
            v.text.show = false
        else
            v.cooldown:SetAlpha((db.showspiral and 1) or 0)
            v.text.show = db.showtime
        end
        if v.obj then v.cooldown:SetCooldown(v.obj:Timer()) end
        if v:IsShown() then v:Hide() v:Show() end
    end
end

do
    local A = {
        [0] = {
            ["up"]    = "BOTTOM",
            ["down"]  = "TOP",
            ["left"]  = "RIGHT",
            ["right"] = "LEFT",

            ["right-down"] = "LEFT",
            ["right-up"]   = "LEFT",
            ["left-down"]  = "RIGHT",
            ["left-up"]    = "RIGHT",

            ["down-right"] = "TOP",
            ["down-left"]  = "TOP",
            ["up-right"]   = "BOTTOM",
            ["up-left"]    = "BOTTOM",
        },
        [1] = {
            ["up"]    = "TOP",
            ["down"]  = "BOTTOM",
            ["left"]  = "LEFT",
            ["right"] = "RIGHT",

            ["right-down"] = "RIGHT",
            ["right-up"]   = "RIGHT",
            ["left-down"]  = "LEFT",
            ["left-up"]    = "LEFT",

            ["down-right"] = "BOTTOM",
            ["down-left"]  = "BOTTOM",
            ["up-right"]   = "TOP",
            ["up-left"]    = "TOP",
        },
        [2] = {
            ["right-down"] = "TOP",
            ["right-up"]   = "BOTTOM",
            ["left-down"]  = "TOP",
            ["left-up"]    = "BOTTOM",

            ["down-right"] = "LEFT",
            ["down-left"]  = "RIGHT",
            ["up-right"]   = "LEFT",
            ["up-left"]    = "RIGHT",
        },
        [3] = {
            ["right-down"] = "BOTTOM",
            ["right-up"]   = "TOP",
            ["left-down"]  = "BOTTOM",
            ["left-up"]    = "TOP",

            ["down-right"] = "RIGHT",
            ["down-left"]  = "LEFT",
            ["up-right"]   = "RIGHT",
            ["up-left"]    = "LEFT",
        },
    }
    function engine:SetBarPoints(bar, db)
        local buttons = bar.buttons
        for k, button in pairs(buttons) do
            button:ClearAllPoints()
            
            button:SetAlpha(db.alpha)
            button:SetScale(db.scale)
            bar.anchor:SetScale(db.scale)

            if not db.multirow then
                if k == 1 then -- set anchor
                    local xOffset = db.posx / db.scale
                    local yOffset = db.posy / db.scale
                    button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", xOffset, yOffset)
                    bar.anchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", xOffset, yOffset)
                else -- i > 1
                    local xOffset, yOffset = 0, 0
                    if db.direction == "left" then
                        xOffset = 0 - db.spacing
                    elseif db.direction == "right" then
                        xOffset = db.spacing
                    elseif db.direction == "up" then
                        yOffset = db.spacing
                    elseif db.direction == "down" then 
                        yOffset = 0 - db.spacing
                    end
                    xOffset = xOffset / db.scale
                    yOffset = yOffset / db.scale
                    button:SetPoint(A[0][db.direction], buttons[k-1], A[1][db.direction], xOffset, yOffset)
                end
            else
                if k == 1 then -- set anchor
                    local xOffset = db.posx / db.scale
                    local yOffset = db.posy / db.scale
                    button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", xOffset, yOffset)

                else  -- i > 1
                    local point, relativeTo, relativePoint, xOffset, yOffset
                    if ((k-1) % db.countperrow) ~= 0 then

                        id = k - 1
                        point = A[0][db.rowdirection]
                        relativeTo = buttons[k-1]
                        relativePoint = A[1][db.rowdirection]
                        if db.rowdirection == "left-down"
                        or db.rowdirection == "left-up" then
                            xOffset = 0 - db.spacing
                            yOffset = 0
                        elseif db.rowdirection == "down-left"
                        or db.rowdirection == "down-right" then
                            xOffset = 0
                            yOffset = 0 - db.rowspacing
                        elseif db.rowdirection == "right-down" 
                        or db.rowdirection == "right-up" then
                            xOffset = db.spacing
                            yOffset = 0
                        elseif db.rowdirection == "up-left"
                        or db.rowdirection == "up-right" then
                            xOffset = 0
                            yOffset = db.spacing
                        end
                    else          

                        point = A[2][db.rowdirection]
                        relativeTo = buttons[k-db.countperrow]
                        relativePoint = A[3][db.rowdirection]
                        if db.rowdirection == "left-down"
                        or db.rowdirection == "right-down" then
                            xOffset = 0
                            yOffset = 0 - db.rowspacing
                        elseif db.rowdirection == "down-left"
                        or db.rowdirection == "up-left" then
                            xOffset = 0 - db.spacing
                            yOffset = 0
                        elseif db.rowdirection == "left-up"
                        or db.rowdirection == "right-up" then
                            xOffset = 0
                            yOffset = db.rowspacing
                        elseif db.rowdirection == "down-right"
                        or db.rowdirection == "up-right" then
                            xOffset = db.spacing
                            yOffset = 0
                        end
                    end
                    xOffset = xOffset / db.scale
                    yOffset = yOffset / db.scale
                    button:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
                end    
            end
        end
        do
            local buttonWidth = buttons[1]:GetWidth()
            local barWidth
            if db.multirow then
                if db.count > db.countperrow then
                    barWidth = ((buttonWidth + db.spacing) * db.countperrow) - db.spacing
                else -- In case that someone has set more buttons per row than buttons at all ;D
                    barWidth = ((buttonWidth + db.spacing) * db.count) - db.spacing
                end
            else
                barWidth = ((buttonWidth + db.spacing) * db.count) - db.spacing
            end
            bar.width = barWidth
        end
    end
end


function engine:formatTime(time, mode)
    local _formatString_
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

function engine:SkinChanged(SkinID, Gloss, Backdrop, Group, Button, Colors)
    if Group then
        local db = self.db.profile.bars[Group]
        db.LBF_Data.SkinID   = SkinID
        db.LBF_Data.Gloss    = Gloss
        db.LBF_Data.Backdrop = Backdrop
        db.LBF_Data.Colors   = Colors
    end
end

function engine:Remove(name)
    local buttons = self.bars[name].buttons
    for k, v in pairs(buttons) do
        buttons[k]:Hide()
    end
    self.bars[name] = nil
end
