local PM = LibStub("AceAddon-3.0"):GetAddon("ProfessionMenu")
local dewdrop = AceLibrary("Dewdrop-2.0")
local GREY = "|cff999999"
local RED = "|cffff0000"
local WHITE = "|cffFFFFFF"
local GREEN = "|cff1eff00"
local LIMEGREEN = "|cFF32CD32"
local BLUE = "|cff0070dd"
local ORANGE = "|cffFF8400"
local YELLOW = "|cffFFd200"


-- add altar summon button via dewdrop secure
function PM:AddItem(itemID)
    local item = GetItemInfoInstant(itemID)
    local name, icon = item.name, item.icon 
    local startTime, duration = GetItemCooldown(itemID)
    local cooldown = math.ceil(((duration - (GetTime() - startTime))/60))
    local text = name
    if cooldown > 0 then
    text = name.." |cFF00FFFF("..cooldown.." ".. "mins" .. ")"
    end
    local selfCast = self.db.selfCast and "[@player] " or ""
    local secure = {
      type1 = "macro",
      macrotext = "/use "..selfCast..name,
    }
    self.dewdrop:AddLine(
            'text', text,
            'icon', icon,
            'secure', secure,
            'func', function() if not self:HasItem(itemID) then RequestDeliverVanityCollectionItem(itemID) else if self.db.DeleteItem then self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED") end self.dewdrop:Close() end end,
            'textHeight', self.db.txtSize,
            'textWidth', self.db.txtSize
    )
end

function PM:AddProfessions()
local function getProfessionRanks(compName)
    for skillIndex = 1, GetNumSkillLines() do
        local name, _, _, rank, _, _, maxRank, _, _, _, _, _, _ = GetSkillLineInfo(skillIndex)
        if compName:match(name) then
            return rank, maxRank
        end
    end
end

 for _, prof in ipairs(self.profList) do
    for _, spellID in ipairs(prof) do
        if CA_IsSpellKnown(spellID) and ((prof.Show and self.db[prof.Show]) or not prof.Show) then
            local name, _, icon = GetSpellInfo(spellID)
            if prof.Name then
                name = prof.Name
            end
            local profName = name
            if prof.main then
                name = GetSpellInfo(prof.main)
            end
            local rank, maxRank = getProfessionRanks(name)
            if not self.db.hideRank and self.db.hideMaxRank then
                name = name .. " |cFF00FFFF("..rank..")"
            end
            if not self.db.hideMaxRank and self.db.hideRank then
                name = name .. " |cFF00FFFF("..maxRank..")"
            end
            if not self.db.hideMaxRank and not self.db.hideRank then
                name = name .. " |cFF00FFFF("..rank.."/"..maxRank..")"
            end

            local tooltipTitle, tooltipText, leftClick, rightClick
            local btnClick = "type1"
            if prof.rightClick then
                tooltipTitle = prof.rightClick[2]
                tooltipText = prof.rightClick[3]
                rightClick = function() self:InventoryFrameOpen(prof.rightClick[2]) end
            elseif prof.leftClick then
                tooltipTitle = prof.leftClick[2]
                tooltipText = prof.leftClick[3]
                leftClick = function() self:InventoryFrameOpen(prof.leftClick[2]) end
                btnClick = "type2"
            end

            local selfCast = self.db.selfCast and "[@player] " or ""
            local secure
            if prof.CraftingSpell then
                secure = {
                    [btnClick] = "spell",
                    spell = spellID,
                }
            else
                secure = {
                    [btnClick] = "macro",
                    macrotext = "/cast "..selfCast..profName,
                }
            end

            self.dewdrop:AddLine(
                    'text', name,
                    'icon', icon,
                    'secure', secure,
                    'closeWhenClicked', true,
                    'func', leftClick,
                    'funcRight', rightClick,
                    'textHeight', self.db.txtSize,
                    'textWidth', self.db.txtSize,
                    'tooltipTitle', tooltipTitle,
                    'tooltipText', tooltipText
            )
            break
        end
    end
end
end

--sets up the drop down menu for specs
function PM:DewdropRegister(button, showUnlock, resetPoint)
if self.dewdrop:IsOpen(button) then self.dewdrop:Close() return end
self.dewdrop:Register(button,
    'point', function(parent)
        local point1, _, point2 = self:GetTipAnchor(button)
        return point1, point2
      end,
    'children', function(level, value)
        self.dewdrop:AddLine(
            'text', "|cffffff00Professions",
            'textHeight', self.db.txtSize,
            'textWidth', self.db.txtSize,
            'isTitle', true,
            'notCheckable', true
        )
        self:AddProfessions()
        local divider

        local SummonItems = self:ReturnItemIDs()

        if #SummonItems > 0 then
            if not divider then divider = self:AddDividerLine(35) end
            for _, itemID in ipairs(SummonItems) do
                self:AddItem(itemID)
            end
        end

        if CA_IsSpellKnown(750750) then
            if not divider then divider = self:AddDividerLine(35) end
            local name, _, icon = GetSpellInfo(750750)
            local selfCast = self.db.selfCast and "[@player] " or ""
            local secure = {
              type1 = "macro",
              macrotext = "/cast "..selfCast..name,
            }
            self.dewdrop:AddLine( 'text', name, 'icon', icon, 'secure', secure, 'closeWhenClicked', true, 'textHeight', self.db.txtSize, 'textWidth', self.db.txtSize)
        end

        local spells = self:ReturnSpellIDs()
        if #spells > 0 then
            self:AddDividerLine(35)
            for _, spellInfo in ipairs(spells) do

                local tooltipTitle, tooltipText, leftClick, rightClick
                local btnClick = "type1"
                if spellInfo.rightClick then
                    tooltipTitle = spellInfo.rightClick[1]
                    tooltipText = spellInfo.rightClick[2]
                    rightClick = function() self:InventoryFrameOpen(spellInfo.rightClick[1]) end
                elseif spellInfo.leftClick then
                    tooltipTitle = spellInfo.leftClick[1]
                    tooltipText = spellInfo.leftClick[2]
                    leftClick = function() self:InventoryFrameOpen(spellInfo.leftClick[1]) end
                    btnClick = "type2"
                end

                local name, _, icon = GetSpellInfo(spellInfo[1])
                    local selfCast = self.db.selfCast and "[@player] " or ""
                    local secure = {
                    [btnClick] = "macro",
                    macrotext = "/cast "..selfCast..name,
                    }
                self.dewdrop:AddLine(
                    'text', name,
                    'icon', icon,
                    'secure', secure,
                    'closeWhenClicked', true,
                    'textHeight', self.db.txtSize,
                    'textWidth', self.db.txtSize,
                    'func', leftClick,
                    'funcRight', rightClick,
                    'tooltipTitle', tooltipTitle,
                    'tooltipText', tooltipText
                )
            end
        end
        self:AddDividerLine(35)
        if showUnlock then
            self.dewdrop:AddLine(
                'text', "Unlock Frame",
                'textHeight', self.db.txtSize,
                'textWidth', self.db.txtSize,
                'func', self.UnlockFrame,
                'notCheckable', true,
                'closeWhenClicked', true
            )
        end
        self.dewdrop:AddLine(
            'text', "Options",
            'textHeight', self.db.txtSize,
            'textWidth', self.db.txtSize,
            'func', self.Options_Toggle,
            'notCheckable', true,
            'closeWhenClicked', true
        )
        self.dewdrop:AddLine(
            'text', "Close Menu",
            'textR', 0,
            'textG', 1,
            'textB', 1,
            'textHeight', self.db.txtSize,
            'textWidth', self.db.txtSize,
            'closeWhenClicked', true,
            'notCheckable', true
        )
    end,
    'dontHook', true
)
self.dewdrop:Open(button)
local hook
if not hook then
    WorldFrame:HookScript("OnEnter", function()
        if self.dewdrop:IsOpen(button) then
            self.dewdrop:Close()
        end
    end)
    hook = true
end

GameTooltip:Hide()
end

-- Used to show highlight as a frame mover
function PM:UnlockFrame()
self = PM
if self.standaloneButton.unlocked then
    self.standaloneButton:SetMovable(false)
    self.standaloneButton:RegisterForDrag()
    self.standaloneButton.Highlight:Hide()
    self.standaloneButton.unlocked = false
    GameTooltip:Hide()
    if self.db.ShowMenuOnHover then
        self.standaloneButton:SetAlpha(0)
    end
else
    self.standaloneButton:SetMovable(true)
    self.standaloneButton:RegisterForDrag("LeftButton")
    self.standaloneButton.Highlight:Show()
    self.standaloneButton.unlocked = true
    if self.db.ShowMenuOnHover then
        self.standaloneButton:SetAlpha(10)
    end
end
end

function PM:InitializeStandaloneButton()
    --Creates the main interface
    self.standaloneButton = CreateFrame("Button", "ProfessionMenuFrame", UIParent, nil)
    self.standaloneButton:SetSize(70,70)
    self.standaloneButton:EnableMouse(true)
    self.standaloneButton:SetScript("OnDragStart", function() self.standaloneButton:StartMoving() end)
    self.standaloneButton:SetScript("OnDragStop", function()
        self.standaloneButton:StopMovingOrSizing()
        self.db.menuPos = {self.standaloneButton:GetPoint()}
        self.db.menuPos[2] = "UIParent"
    end)
    self.standaloneButton:SetScript("OnShow", function()
        self.standaloneButton.icon:Show()
        self.standaloneButton.Text:Show()
    end)
    self.standaloneButton:SetScript("OnHide", function()
        self.standaloneButton.icon:Hide()
        self.standaloneButton.Text:Hide()
    end)

    self.standaloneButton:SetMovable(true)
    self.standaloneButton:RegisterForClicks("LeftButtonDown", "RightButtonDown")
    self.standaloneButton.icon = self.standaloneButton:CreateTexture(nil, "ARTWORK")
    self.standaloneButton.icon:SetSize(55,55)
    self.standaloneButton.icon:SetPoint("CENTER", self.standaloneButton,"CENTER",0,0)
    self.standaloneButton.icon:SetTexture(self.defaultIcon)
    self.standaloneButton.Text = self.standaloneButton:CreateFontString()
    self.standaloneButton.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)
    self.standaloneButton.Text:SetFontObject(GameFontNormal)
    self.standaloneButton.Text:SetText("|cffffffffProf\nMenu")
    self.standaloneButton.Text:SetPoint("CENTER", self.standaloneButton.icon, "CENTER", 0, 0)
    self.standaloneButton.Highlight = self.standaloneButton:CreateTexture(nil, "OVERLAY")
    self.standaloneButton.Highlight:SetSize(70,70)
    self.standaloneButton.Highlight:SetPoint("CENTER", self.standaloneButton, 0, 0)
    self.standaloneButton.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
    self.standaloneButton.Highlight:Hide()
    self.standaloneButton:Hide()
    self.standaloneButton:SetScript("OnClick", function(button, btnclick)
        if btnclick == "RightButton" and  self.standaloneButton.unlocked then
            self:UnlockFrame()
        elseif not self.standaloneButton.unlocked then
            if not self.db.autoMenu then
                self:DewdropRegister(button, true)
            end
        end
    end)

    self.standaloneButton:SetScript("OnEnter", function(button)
        if self.standaloneButton.unlocked then
            GameTooltip:SetOwner(button, "ANCHOR_TOP")
            GameTooltip:AddLine("Left click to drag")
            GameTooltip:AddLine("Right click to lock frame")
            GameTooltip:Show()
        else
            self:OnEnter(button, true)
            self.standaloneButton.Highlight:Show()
        end
        if self.db.ShowMenuOnHover then
            self.standaloneButton:SetAlpha(10)
        end
    end)

    self.standaloneButton:SetScript("OnLeave", function()
        if not self.standaloneButton.unlocked  then
            self.standaloneButton.Highlight:Hide()
            GameTooltip:Hide()
            if self.db.ShowMenuOnHover then
                self.standaloneButton:SetAlpha(0)
            end
        end
    end)

    if self.db.menuPos then
        self.standaloneButton:ClearAllPoints()
        self.standaloneButton:SetPoint(unpack(self.db.menuPos))
    else
        self.standaloneButton:ClearAllPoints()
        self.standaloneButton:SetPoint("CENTER", UIParent)
    end

    self:SetFrameAlpha()

    if not self.db.HideMenu then
        self.standaloneButton:Show()
    end

end

function PM:SetFrameAlpha()
    if self.db.ShowMenuOnHover then
        self.standaloneButton:SetAlpha(0)
    else
        self.standaloneButton:SetAlpha(10)
    end
end

-- toggle the main button frame
function PM:ToggleMainFrame()
    if  self.standaloneButton:IsVisible() then
        self.standaloneButton:Hide()
    else
        self.standaloneButton:Show()
    end
end

