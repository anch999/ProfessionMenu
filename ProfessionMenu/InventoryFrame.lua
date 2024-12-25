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

local inventoryItems
local bagThrottle = false

function PM:InitializeInventoryUI()
    self.InventoryFrame = CreateFrame("FRAME", "ProfessionMenuExtractFrame", UIParent,"UIPanelDialogTemplate")
    self.InventoryFrame:SetSize(640,508)
    self.InventoryFrame:SetPoint("CENTER",0,0)
    self.InventoryFrame:EnableMouse(true)
    self.InventoryFrame:SetMovable(true)
    self.InventoryFrame:SetToplevel(true)
    self.InventoryFrame:RegisterForDrag("LeftButton")
    self.InventoryFrame:SetScript("OnDragStart", function() self.InventoryFrame:StartMoving() end)
    self.InventoryFrame:SetScript("OnDragStop", function() self.InventoryFrame:StopMovingOrSizing() end)
    self.InventoryFrame:SetScript("OnShow", function()
        if self.InventoryFrame.profession == "Enchanting" then
            self.InventoryFrame.TitleText:SetText("Disenchanting List")
            self.InventoryFrame.filterMenu:Show()
            self.InventoryFrame.openFirstBtn:Hide()
            self:SearchBags()
        elseif self.InventoryFrame.profession == "Lockpicking" then
            self.InventoryFrame.TitleText:SetText("Lockpicking List")
            self.InventoryFrame.filterMenu:Hide()
            self.InventoryFrame.openFirstBtn:Show()
            self:SearchBagsLockboxs()
        end
        self:RegisterEvent("BAG_UPDATE")
        self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    end)
    self.InventoryFrame:SetScript("OnHide", function()
        self.InventoryFrame.profession = nil
        self:UnregisterEvent("BAG_UPDATE")
        self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    end)
    self.InventoryFrame.TitleText = self.InventoryFrame:CreateFontString()
    self.InventoryFrame.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 12)
    self.InventoryFrame.TitleText:SetFontObject(GameFontNormal)
    self.InventoryFrame.TitleText:SetPoint("TOP", 0, -9)
    self.InventoryFrame.TitleText:SetShadowOffset(1,-1)
    self.InventoryFrame:Hide()

------------------ScrollFrameTooltips---------------------------
    local function ItemTemplate_OnEnter(self)
        if not self.link and (not self.bag and not self.slot) then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -13, -50)
        if self.bag and self.slot then
            GameTooltip:SetBagItem(self.bag, self.slot)
        else
            GameTooltip:SetHyperlink(self.link)
        end
        GameTooltip:Show()
    end

    local function ItemTemplate_OnLeave()
        GameTooltip:Hide()
    end

    --ScrollFrame

    local ROW_HEIGHT = 16   -- How tall is each row?
    local MAX_ROWS = 25      -- How many rows can be shown at once?

    self.DeScrollFrame = CreateFrame("Frame", "", self.InventoryFrame)
    self.DeScrollFrame:EnableMouse(true)
    self.DeScrollFrame:SetSize(self.InventoryFrame:GetWidth()-40, ROW_HEIGHT * MAX_ROWS + 16)
    self.DeScrollFrame:SetPoint("TOP",0,-42)
    self.DeScrollFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    function self:InventroyScrollFrameUpdate()
        local maxValue = #inventoryItems
        FauxScrollFrame_Update(self.DeScrollFrame.scrollBar, maxValue, MAX_ROWS, ROW_HEIGHT)
        local offset = FauxScrollFrame_GetOffset(self.DeScrollFrame.scrollBar)
        for i = 1, MAX_ROWS do
            local value = i + offset
            self.DeScrollFrame.rows[i]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
            self.DeScrollFrame.rows[i]:Hide()
            if value <= maxValue then
                local row = self.DeScrollFrame.rows[i]
                local text1, text2 = self:GetPosibleMats(inventoryItems[value][4], inventoryItems[value][5])
                row.Text:SetText(inventoryItems[value][3])
                row.Text1:SetText(text1)
                if text2 then
                    row.Text2:SetText(text2)
                else
                    row.Text2:SetText("")
                end
                row.link = inventoryItems[value][3]
                row.bag = inventoryItems[value][1]
                row.slot = inventoryItems[value][2]
                row.type = inventoryItems[value][7]
                if self.InventoryFrame.profession == "Enchanting" then
                    row:SetAttribute("type", "spell")
                    row:SetAttribute("spell", "Disenchant")
                    row:SetAttribute("target-bag", row.bag)
                    row:SetAttribute("target-slot", row.slot)
                elseif self.InventoryFrame.profession == "Lockpicking" then
                    if inventoryItems[value][7] == "locked" then
                        row:SetAttribute("type", "spell")
                        row:SetAttribute("spell", "Pick Lock")
                        row:SetAttribute("target-bag", row.bag)
                        row:SetAttribute("target-slot", row.slot)
                        row.Text1:SetText(RED.."Locked")
                    elseif inventoryItems[value][7] == "unLocked" then
                        row:SetAttribute("type", "item")
                        row:SetAttribute("item", row.bag.." "..row.slot)
                        row.Text1:SetText(GREEN.."Unlocked")
                    end
                end
                row.tNumber = value
                row:Show()
            end
        end
    end

    self.DeScrollFrame.scrollBar = CreateFrame("ScrollFrame","ProfessionMenuDEListFrameScroll",self.DeScrollFrame,"FauxScrollFrameTemplate")
    self.DeScrollFrame.scrollBar:SetPoint("TOPLEFT", 0, -8)
    self.DeScrollFrame.scrollBar:SetPoint("BOTTOMRIGHT", -30, 8)
    self.DeScrollFrame.scrollBar:SetScript("OnVerticalScroll", function(self, offset)
        self.offset = math.floor(offset / ROW_HEIGHT + 0.5)
        PM:InventroyScrollFrameUpdate()
    end)

    local rows = setmetatable({}, { __index = function(t, i)
        local row = CreateFrame("Button", "$parentRow"..i, self.DeScrollFrame, "SecureActionButtonTemplate")
        if i == 1 then self.InventoryFrame.firstButton = row end
        row:SetSize(405, ROW_HEIGHT)
        row:SetNormalFontObject(GameFontHighlightLeft)
        row.Text = row:CreateFontString("$parentRow"..i.."Text","OVERLAY","GameFontNormal")
        row.Text:SetSize(230, ROW_HEIGHT)
        row.Text:SetPoint("LEFT",row)
        row.Text:SetJustifyH("LEFT")
        row.Text1 = row:CreateFontString("$parentRow"..i.."Text1","OVERLAY","GameFontNormal")
        row.Text1:SetSize(180, ROW_HEIGHT)
        row.Text1:SetPoint("LEFT",row,230,0)
        row.Text1:SetJustifyH("LEFT")
        row.Text2 = row:CreateFontString("$parentRow"..i.."Text2","OVERLAY","GameFontNormal")
        row.Text2:SetSize(180, ROW_HEIGHT)
        row.Text2:SetPoint("LEFT",row,390,0)
        row.Text2:SetJustifyH("LEFT")
        row:SetScript("OnShow", function(self)
            if GameTooltip:GetOwner() == self:GetName() then
                ItemTemplate_OnEnter(self)
            end
        end)
        row:SetScript("OnMouseDown", function()
            local itemID = GetItemInfoFromHyperlink(row.link)
            local appearanceID = C_Appearance.GetItemAppearanceID(itemID)
            if appearanceID and not C_AppearanceCollection.IsAppearanceCollected(appearanceID) then
                C_AppearanceCollection.CollectItemAppearance(itemID)
            end
        end)
        row:SetScript("OnEnter", function(self)
            ItemTemplate_OnEnter(self)
        end)
        row:SetScript("OnLeave", ItemTemplate_OnLeave)
        if i == 1 then
            row:SetPoint("TOPLEFT", self.DeScrollFrame, 8, -8)
        else
            row:SetPoint("TOPLEFT", self.DeScrollFrame.rows[i-1], "BOTTOMLEFT")
        end
        rawset(t, i, row)
        return row
    end })

    self.DeScrollFrame.rows = rows

    --Shows a menu with options and sharing options
    self.InventoryFrame.filterMenu = CreateFrame("Button", "ProfessionMenu_InventoryFrameFilterMenu", self.InventoryFrame, "FilterDropDownMenuTemplate")
    self.InventoryFrame.filterMenu:SetSize(133, 30)
    self.InventoryFrame.filterMenu:SetPoint("BOTTOMRIGHT", self.DeScrollFrame, "BOTTOMRIGHT", 0, -35)
    self.InventoryFrame.filterMenu:RegisterForClicks("LeftButtonDown")
    self.InventoryFrame.filterMenu:SetScript("OnClick", function(button)
        self:ItemMenuRegister(button)
    end)

	self.InventoryFrame.moneyFrame = CreateFrame("Frame", "ProfessionMenu_InventoryFramePrice", self.InventoryFrame.filterMenu, "MoneyInputFrameTemplate")
	self.InventoryFrame.moneyFrame:SetPoint("TOP", self.DeScrollFrame, "BOTTOM", 20, -10)
	self.InventoryFrame.moneyFrame:SetScript("OnShow", function()
		MoneyInputFrame_SetCopper(ProfessionMenu_InventoryFramePrice,self.db.Gold)
		end)
		MoneyInputFrame_SetOnValueChangedFunc(self.InventoryFrame.moneyFrame, function()
			self.db.Gold = MoneyInputFrame_GetCopper(self.InventoryFrame.moneyFrame)
		end)

    self.InventoryFrame.moneyEnable = CreateFrame("CheckButton", "ProfessionMenu_InventoryFramePriceCheck", self.InventoryFrame.filterMenu, "UICheckButtonTemplate")
    self.InventoryFrame.moneyEnable:SetPoint("RIGHT", self.InventoryFrame.moneyFrame, "LEFT", -10, -1)
    self.InventoryFrame.moneyEnable:SetScript("OnShow", function()
        self.InventoryFrame.moneyEnable:SetChecked(self.db.GoldFilter)
    end)
    self.InventoryFrame.moneyEnable:SetScript("OnClick", function()
        self.db.GoldFilter = self.InventoryFrame.moneyEnable:GetChecked()
        self:SearchBags()
    end)
    self.InventoryFrame.moneyEnable:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_TOP")
        GameTooltip:AddLine("Toggle money filter")
        GameTooltip:Show()
    end)
    self.InventoryFrame.moneyEnable:SetScript("OnLeave", function() GameTooltip:Hide() end)

    --Shows a vendor all thats left button
    self.InventoryFrame.vendorBttn = CreateFrame("Button", "ProfessionMenu_InventoryFrameVendorButton", self.InventoryFrame.filterMenu, "OptionsButtonTemplate")
    self.InventoryFrame.vendorBttn:SetSize(133, 30)
    self.InventoryFrame.vendorBttn:SetPoint("BOTTOMLEFT", self.DeScrollFrame, "BOTTOMLEFT", 0, -35)
    self.InventoryFrame.vendorBttn:RegisterForClicks("LeftButtonDown")
    self.InventoryFrame.vendorBttn:SetText("Vendor All")
    self.InventoryFrame.vendorBttn:SetScript("OnClick", function(button)
        if not PROFESSIONMENU.inventoryItems then return end
        for _,item in pairs(PROFESSIONMENU.inventoryItems) do
            local appearanceID = C_Appearance.GetItemAppearanceID(item[6])
            if appearanceID and not C_AppearanceCollection.IsAppearanceCollected(appearanceID) then
                C_AppearanceCollection.CollectItemAppearance(item[6])
            end
            PickupContainerItem(item[1], item[2])
            PickupMerchantItem(0)
        end
    end)
    self.InventoryFrame.vendorBttn:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_TOP")
        GameTooltip:AddLine("Vendor all currenty shown items if merchant is open")
        GameTooltip:Show()
    end)
    self.InventoryFrame.vendorBttn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    --Shows a openFirstBtn button
    self.InventoryFrame.openFirstBtn = CreateFrame("Button", "ProfessionMenu_InventoryFrameVendorButton", self.InventoryFrame, "OptionsButtonTemplate,SecureActionButtonTemplate")
    self.InventoryFrame.openFirstBtn:SetSize(133, 30)
    self.InventoryFrame.openFirstBtn:SetPoint("BOTTOMLEFT", self.DeScrollFrame, "BOTTOMLEFT", 0, -35)
    self.InventoryFrame.openFirstBtn:SetText("Unlock/Open First")
    self.InventoryFrame.openFirstBtn:SetScript("OnShow", function() self.InventoryFrame.openFirstBtn:Enable() end)
    self.InventoryFrame.openFirstBtn:SetScript("OnEnter", function(button)
        local firstButton = self.InventoryFrame.firstButton
        if not firstButton then return end
        if firstButton.type == "locked" then
            button:SetAttribute("type", "spell")
            button:SetAttribute("spell", "Pick Lock")
            button:SetAttribute("target-bag", firstButton.bag)
            button:SetAttribute("target-slot", firstButton.slot)
        elseif firstButton.type == "unLocked" then
            button:SetAttribute("type", "item")
            button:SetAttribute("item", firstButton.bag.." "..firstButton.slot)
        end
    end)
    self.InventoryFrame.openFirstBtn:SetScript("OnMouseDown", function()
            if inventoryItems and #inventoryItems > 0 then
                Timer.After(.2, function() self.InventoryFrame.openFirstBtn:Disable() end)
            end
        end)

    --Add the ProfessionMenu Extract Frame to the special frames tables to enable closing wih the ESC key
    tinsert(UISpecialFrames, "ProfessionMenuExtractFrame")
end

PM.FilterList = {
    [1] = {"Uncommon", 2},
    [2] = {"Rare", 3},
    [3] = {"Epic", 4},
    Soulbound = "Soulbound",
    Bags = {
        "Backpack",
        "Bag 1",
        "Bag 2",
        "Bag 3",
        "Bag 4",
    }
}

local enchantingMats = {
    ["Commen"] = {
        -- Classic Mats
        {itemLevel = {5,15}, dust = {10940, " 1-3"}, Essence = {10938, " 1-2"}},
        {itemLevel = {16,20},dust = {10940, " 2-5"}, Essence = {10939, " 1-2"}},
        {itemLevel = {21,25},dust = {10940, " 2-5"}, Essence = {10998, " 1-2"}},
        {itemLevel = {26,30},dust = {11083, " 1-3"}, Essence = {11082, " 1-2"}},
        {itemLevel = {31,35},dust = {11083, " 2-5"}, Essence = {11134, " 1-2"}},
        {itemLevel = {36,40},dust = {11137, " 1-3"}, Essence = {11135, " 1-2"}},
        {itemLevel = {41,45},dust = {11137, " 2-5"}, Essence = {11174, " 1-2"}},
        {itemLevel = {46,50},dust = {11176, " 1-3"}, Essence = {11175, " 1-2"}},
        {itemLevel = {51,55},dust = {11176, " 2-5"}, Essence = {16202, " 1-2"}},
        {itemLevel = {56,60},dust = {16204, " 1-3"}, Essence = {16203, " 1-2"}},
        {itemLevel = {61,65},dust = {16204, " 2-5"}, Essence = {16203, " 1-3"}},
        -- TBC Mats
        {itemLevel = {80,99},dust = {22445, " 1-3"}, Essence = {22447, " 1-3"}},
        {itemLevel = {100,120},dust = {22445, " 2-5"}, Essence = {22446, " 1-2"}},
        -- Wrath Mats
        {itemLevel = {130,151},dust = {34054, " 2-3"}, Essence = {34056, " 1-2"}},
        {itemLevel = {152,200},dust = {34054, " 4-7"}, Essence = {34055, " 1-2"}},
    },
    ["Rare"] = {
        -- Classic Mats
        {itemLevel = {16,25}, Shard = 10978},
        {itemLevel = {26,30}, Shard = 11084},
        {itemLevel = {31,35}, Shard = 11138},
        {itemLevel = {36,40}, Shard = 11139},
        {itemLevel = {41,45}, Shard = 11177},
        {itemLevel = {46,50}, Shard = 11178},
        {itemLevel = {51,55}, Shard = 14343},
        {itemLevel = {56,65}, Shard = 14344},
        -- TBC Mats
        {itemLevel = {80,99}, Shard = 22448},
        {itemLevel = {100,120}, Shard = 22449},
        -- Wrath Mats
        {itemLevel = {130,151}, Shard = 34053},
        {itemLevel = {152,200}, Shard = 34052},
    },
    ["Epic"] = {
        {itemLevel = {56,80}, Crystal = 20725},
        -- TBC Mats
        {itemLevel = {95,164}, Crystal = 22450},
        -- Wrath Mats
        {itemLevel = {165,264}, Crystal = 34057},
    }
}

function PM:GetPosibleMats(quality, itemLevel)
    if quality == 2 then
        for _, mat in ipairs (enchantingMats.Commen) do
            if itemLevel >= mat.itemLevel[1]  and itemLevel <= mat.itemLevel[2] then
                local itemLink = select(2,GetItemInfo(mat.dust[1]))..mat.dust[2]
                local itemLink2 = select(2,GetItemInfo(mat.Essence[1]))..mat.Essence[2]
                return itemLink, itemLink2
            end
        end
    elseif quality == 3 then
        for _, mat in ipairs (enchantingMats.Rare) do
            if itemLevel >= mat.itemLevel[1]  and itemLevel <= mat.itemLevel[2] then
                local itemLink = select(2,GetItemInfo(mat.Shard))
                return itemLink
            end
        end
    elseif quality == 4 then
        for _, mat in ipairs (enchantingMats.Epic) do
            if itemLevel >= mat.itemLevel[1]  and itemLevel <= mat.itemLevel[2] then
                local itemLink = select(2,GetItemInfo(mat.Crystal))
                return itemLink
            end
        end
    end
end

local InventoryTypes = {
    ["Weapon"] = true,
    ["Armor"] = true
}

function PM:InventoryFrameOpen(profession)
    if not profession then return end
    if self.InventoryFrame:IsVisible() then
        self.InventoryFrame:Hide()
        self.InventoryFrame.profession = nil
    else
        self.InventoryFrame.profession = profession
        self.InventoryFrame:Show()
    end
end

function PM:BAG_UPDATE()
    if self.InventoryFrame.profession == "Enchanting" then
        Timer.After(.10, function() self:SearchBags() end)
    elseif self.InventoryFrame.profession == "Lockpicking" then
        Timer.After(.10, function() self:SearchBagsLockboxs() end)
    end
end

function PM:FilterCheck(quality, bagID, slotID, link)
    for _, _ in ipairs(self.FilterList) do
        local binding = self:GetTooltipItemInfo(nil, bagID, slotID)
        if (self.db.FilterList[4] and binding.isSoulbound) or (self.db.GoldFilter and select(11, GetItemInfo(link)) > self.db.Gold ) or (quality < 1 or quality > 5) or self.db.FilterList[quality-1] then
            return true
        end
    end
    return false
end

--finds the next bag slot with an item with an enchant on it
function PM:SearchBags()
    if not bagThrottle then
        inventoryItems = {}
        for bagID = 0, 4 do
            if not self.db.BagFilter[bagID+1] then
                for slotID = 1, GetContainerNumSlots(bagID) do
                    local quality,_,_,link = select(4,GetContainerItemInfo(bagID,slotID))
                    local itemID = GetContainerItemID(bagID,slotID)
                    if link and not self.db.ItemBlacklist[itemID] then
                        local itemLevel, _, itemType = select(4,GetItemInfo(itemID))
                        if not self:FilterCheck(quality, bagID, slotID, link) and InventoryTypes[itemType] then
                            tinsert(inventoryItems,{bagID,slotID,link,quality,itemLevel,itemID})
                        end
                    end
                end
            end
        end
        bagThrottle = true
        self.bagThrottle = self:ScheduleTimer(function() bagThrottle = false end, .1)
        self:InventroyScrollFrameUpdate()
        self.inventoryItems = inventoryItems
    end
end

--finds the next bag slot with an item with an enchant on it
function PM:SearchBagsLockboxs()
    if not bagThrottle then
        inventoryItems = {}
        for bagID = 0, 4 do
            for slotID = 1, GetContainerNumSlots(bagID) do
                local quality,_,_,link = select(4,GetContainerItemInfo(bagID,slotID))
                local itemID = GetContainerItemID(bagID,slotID)
                local tooltipInfo = self:GetTooltipItemInfo(nil, bagID, slotID)
                if tooltipInfo.isLocked then
                    tinsert(inventoryItems,{bagID,slotID,link,quality,nil,itemID,"locked"})
                elseif tooltipInfo.isUnlocked then
                    tinsert(inventoryItems,{bagID,slotID,link,quality,nil,itemID,"unLocked"})
                end
            end
        end
        bagThrottle = true
        self.bagThrottle = self:ScheduleTimer(function() bagThrottle = false end, .1)
        self:InventroyScrollFrameUpdate()
        self.inventoryItems = inventoryItems
        self.InventoryFrame.openFirstBtn:Enable()
    end
end

function PM:ItemMenuRegister(button)
    if dewdrop:IsOpen(button) then dewdrop:Close() return end

    dewdrop:Register(button,
        'point', function(parent)
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value)
            if level == 1 then
                for k, v in ipairs(self.FilterList) do
                    local text = v[1]
                    if tonumber(v[2]) then
                        text = select(4, GetItemQualityColor(v[2])) .. v[1]
                    end
                    dewdrop:AddLine(
                        'text', text,
                        'func', function() self.db.FilterList[k] = not self.db.FilterList[k] self:SearchBags() end,
                        'checked', self.db.FilterList[k],
                        'textHeight', 12,
                        'textWidth', 12
                    )
                end
                dewdrop:AddLine(
                    'text', self.FilterList.Soulbound,
                    'func', function() self.db.FilterList[4] = not self.db.FilterList[4] self:SearchBags() end,
                    'checked', self.db.FilterList[4],
                    'textHeight', 12,
                    'textWidth', 12
                )
                dewdrop:AddLine(
                    'text', "Bag Filter",
                    'value', "BagFilter",
                    'hasArrow', true,
                    'textHeight', 12,
                    'textWidth', 12,
                    "notCheckable", true
                )
                dewdrop:AddLine(
                    'text', "Close Menu",
                    'textR', 0,
                    'textG', 1,
                    'textB', 1,
                    'textHeight', 12,
                    'textWidth', 12,
                    'closeWhenClicked', true,
                    'notCheckable', true
                )
            elseif level == 2 then
                if value and value == "BagFilter" then
                    for i, bag in ipairs(self.FilterList.Bags) do
                        dewdrop:AddLine(
                            'text', bag,
                            'func', function() self.db.BagFilter[i] = not self.db.BagFilter[i] self:SearchBags() end,
                            'checked', self.db.BagFilter[i],
                            'textHeight', 12,
                            'textWidth', 12
                        )
                    end
                end
            end
        end,
        'dontHook', true
    )
    dewdrop:Open(button)
end