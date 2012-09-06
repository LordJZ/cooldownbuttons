local engine = { }
CDB.engine = engine

local LS2 = LibStub("LibSink-2.0")
local LSM = LibStub("LibSharedMedia-3.0")
local MSQ = LibStub("Masque", true)
local newList, newDict, del, deepDel, deepCopy = CDB.GetRecyclingFunctions()
local math_ceil = math.ceil
local gsub = CDB.gsub
local table_insert = table.insert
local table_remove = table.remove

local function LibSinkMessage(name, texture)
    if LS2 then
        local db = CDB.db.profile.LibSink
        local message = gsub(db.message, "$cooldown", name)
        message = gsub(message, "$icon", "|T"..texture.."::|t")
        local tex = ((db.texture and texture) or nil)
        local c = db.color
        LS2.Pour(CDB, message, c.Red, c.Green, c.Blue, nil, nil, nil, nil, nil, tex)
    end
end


local UpdateInterval = 0.5; -- How often the OnUpdate code will run (in seconds)
local function OnUpdate(self)
	local nowint = floor(GetTime() + 0.5)
	if nowint == self.lastUpdate then return end
    if not (nowint - self.lastUpdate > UpdateInterval) then return end
    self.lastUpdate = nowint
    
    if not self.obj then return end -- maybe a todo
    
    local start, duration = self.obj:Timer()
    if ((not start) or (start == 0)) or (start+duration < GetTime() ) then --hideFrame
        local db = self.parent.db
        LibSinkMessage(self.obj.name, self.obj.texture)
        if (not db.showomnicc) and db.showpulse then
            if not self.pulse.active then
                self.pulse:SetScript("OnUpdate", self.pulse.handler)
            end
        else
            self.text:SetText("")
            self:Hide()
            CDB:RemoveCooldown(self.obj.name) 
        end
    else
        self.text:SetText(date("%M:%S", 82800 + start + duration - GetTime()))
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
end

local function OnDragStart(self)
end

local function OnDragStop(self)
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

        button.idx = i
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
        local buttons = barData.buttons
        for _, name in pairs(self.cooldownsSort) do
            local data = self.cooldowns[name]
            if data.active and self:IsInBar(name, barName) and i <= #buttons then
                local button = buttons[i]
                button.obj = data
                button.texture:SetTexture(data.texture)
                button.cooldown:SetCooldown(data:Timer())
                button:Show()
                i = i+1
            end
        end
        do
            local db = barData.db
            if db.center then
                local used = i
                if not db.multirow then
                    local offsetx, offsety
                    if db.direction == "left" or db.direction == "right" then
                        offsetx = ((((buttons[1]:GetWidth() + db.spacing) * used)) / 2) - buttons[1]:GetWidth() - db.spacing
                        if db.direction == "left" then
                            offsetx = db.posx + offsetx
                        else
                            offsetx = db.posx - offsetx
                        end
                        offsety = db.posy
                    elseif db.direction == "up" or db.direction == "down" then 
                        offsety = ((((buttons[1]:GetHeight() + db.spacing) * used)) / 2) - buttons[1]:GetHeight() - db.spacing
                        if db.direction == "down" then
                            offsety = db.posy + offsety
                        else
                            offsety = db.posy - offsety 
                        end
                        offsetx = db.posx
                    end
                    buttons[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", offsetx, offsety)                    
                else
                end
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
    -------------------
    --- todo: continue here !
    -------------------
    end
end

function engine:IsInBar(name, bar)
    local cooldown = self.cooldowns[name]
    local type2bar = self.db.profile.type2bar[cooldown.type][bar]
    local cooldown2bar
    local cooldown2bar_tmp = self.db.profile.cooldown2bar[name]
    
    -- if cooldown is a preview cooldown, then its in ALL bars :)
    if cooldown.preview then return true end
    
    -- if cooldown2bar_tmp is a table ignore type2bar (by setting it to false)
    -- and set cooldown2bar to cooldown2bar_tmp[bar] to have the value for this bar
    -- if cooldown2bar_tmp is NOT a table set cooldown2bar to false
    if type(cooldown2bar_tmp) == "table" then
        type2bar = false
        cooldown2bar = cooldown2bar_tmp[bar]
    else
        cooldown2bar = false
    end

    -- if cooldown2bar == true, we retrun true as its chosen to be shown on this bar
    -- else we return the value of type2bar
    --- possible values for type2bar for diffrent conditions:
    -- true:  if cooldown2bar_tmp ~= table and the cooldown.type is assigned to this bar
    -- false: if neither cooldown2bar_tmp is a table nor the cooldown.type is assigned to this bar
    -- false: if cooldown2bar_tmp IS a table (what forced type2bar to false)
    if cooldown2bar then return true
    else return type2bar end
end

function engine:CreateBar(name, db)
    local bar = { db = db, }
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
        for k, v in pairs(buttons) do
            v:ClearAllPoints()
            if not db.multirow then
                if k == 1 then -- set anchor
                    v:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.posx, db.posy)
                else -- i > 1
                    local x, y = 0, 0
                    if db.direction == "left" then
                        x = 0 - db.spacing
                    elseif db.direction == "right" then
                        x = db.spacing
                    elseif db.direction == "up" then
                        y = db.spacing
                    elseif db.direction == "down" then 
                        y = 0 - db.spacing
                    end
                    v:SetPoint(A[0][db.direction], buttons[k-1], A[1][db.direction], x, y)
                end
            else
                if k == 1 then -- set anchor
                    v:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.posx, db.posy)
--ChatFrame3:AddMessage("first")
                else  -- i > 1
                    local point, relativeTo, relativePoint, xOffset, yOffset
                    if ((k-1) % db.countperrow) ~= 0 then
--ChatFrame3:AddMessage("button")
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
--ChatFrame3:AddMessage("break")
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
                    v:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
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
