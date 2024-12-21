local PM = LibStub("AceAddon-3.0"):GetAddon("ProfessionMenu")
local dewdrop = AceLibrary("Dewdrop-2.0")
function PM:CreateInventoryUI()
    self.Extractframe = CreateFrame("FRAME", "ProfessionMenuExtractFrame", UIParent,"UIPanelDialogTemplate")
        local mainframe = self.Extractframe
        mainframe:SetSize(640,508)
        mainframe:SetPoint("CENTER",0,0)
        mainframe:EnableMouse(true)
        mainframe:SetMovable(true)
        mainframe:SetToplevel(true)
        mainframe:RegisterForDrag("LeftButton")
        mainframe:SetScript("OnDragStart", function(self) mainframe:StartMoving() end)
        mainframe:SetScript("OnDragStop", function(self) mainframe:StopMovingOrSizing() end)
        mainframe:SetScript("OnShow", function()
            self:SearchBags()
            self:RegisterEvent("BAG_UPDATE")
        end)
        mainframe:SetScript("OnHide", function()
            self:UnregisterEvent("BAG_UPDATE")
        end)
        mainframe.TitleText = mainframe:CreateFontString()
        mainframe.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 12)
        mainframe.TitleText:SetFontObject(GameFontNormal)
        mainframe.TitleText:SetText("Disenchanting List")
        mainframe.TitleText:SetPoint("TOP", 0, -9)
        mainframe.TitleText:SetShadowOffset(1,-1)
        mainframe:Hide()
        --Add the ProfessionMenu Extract Frame to the special frames tables to enable closing wih the ESC key
	    tinsert(UISpecialFrames, "ProfessionMenuExtractFrame")
end
PM:CreateInventoryUI()

PM.FilterList = {
    [1] = {"Uncommon", 2},
    [2] = {"Rare", 3},
    [3] = {"Epic", 4},
    Soulbound = "Soulbound",
    Gold = "Gold",
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

function PM:InventoryFrame_Open(isEnabled)
    if not isEnabled then return end
    if self.Extractframe:IsVisible() then
        self.Extractframe:Hide()
    else
        self.Extractframe:Show()
    end
end

function PM:BAG_UPDATE()
    self:ScheduleTimer(function() self:SearchBags() end, .10)
end

function PM:FilterCheck(quality, bagID, slotID, link)
    for _, _ in ipairs(self.FilterList) do
        if (self.db.FilterList[4] and self:IsSoulbound(bagID, slotID)) or (self.db.FilterList[5] and select(11, GetItemInfo(link)) > self.db.Gold ) or (quality < 1 or quality > 5) or self.db.FilterList[quality-1] then
            return true
        end
    end
    return false
end

local inventoryItems
local bagThrottle = false
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
                    'text', self.FilterList.Gold,
                    'func', function() self.db.FilterList[5] = not self.db.FilterList[5] self:SearchBags() end,
                    'checked', self.db.FilterList[5],
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

------------------ScrollFrameTooltips---------------------------
function PM:DeScrollFrameCreate()

local function ItemTemplate_OnEnter(self)
    if not self.link then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -13, -50)
    GameTooltip:SetHyperlink(self.link)
    GameTooltip:Show()
end

local function ItemTemplate_OnLeave()
    GameTooltip:Hide()
end

--ScrollFrame

local ROW_HEIGHT = 16   -- How tall is each row?
local MAX_ROWS = 25      -- How many rows can be shown at once?


    self.DeScrollFrame = CreateFrame("Frame", "", self.Extractframe)
    local scrollFrame = self.DeScrollFrame
        scrollFrame:EnableMouse(true)
        scrollFrame:SetSize(self.Extractframe:GetWidth()-40, ROW_HEIGHT * MAX_ROWS + 16)
        scrollFrame:SetPoint("TOP",0,-42)
        scrollFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })



function PM:InventroyScrollFrameUpdate()
    local maxValue = #inventoryItems
	FauxScrollFrame_Update(scrollFrame.scrollBar, maxValue, MAX_ROWS, ROW_HEIGHT)
	local offset = FauxScrollFrame_GetOffset(scrollFrame.scrollBar)
	for i = 1, MAX_ROWS do
		local value = i + offset
        scrollFrame.rows[i]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        scrollFrame.rows[i]:Hide()
		if value <= maxValue then
			local row = scrollFrame.rows[i]
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
            row:SetAttribute("type", "spell")
            row:SetAttribute("spell", "Disenchant")
            row:SetAttribute("target-bag", row.bag)
            row:SetAttribute("target-slot", row.slot)
            row.tNumber = value
            row:Show()
		end
	end
end

local scrollSlider = CreateFrame("ScrollFrame","ProfessionMenuDEListFrameScroll",self.DeScrollFrame,"FauxScrollFrameTemplate")
scrollSlider:SetPoint("TOPLEFT", 0, -8)
scrollSlider:SetPoint("BOTTOMRIGHT", -30, 8)
scrollSlider:SetScript("OnVerticalScroll", function(self, offset)
    self.offset = math.floor(offset / ROW_HEIGHT + 0.5)
    PM:InventroyScrollFrameUpdate()
end)

scrollFrame.scrollBar = scrollSlider

local rows = setmetatable({}, { __index = function(t, i)
	local row = CreateFrame("Button", "$parentRow"..i, scrollFrame, "SecureActionButtonTemplate")
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
		row:SetPoint("TOPLEFT", scrollFrame, 8, -8)
	else
		row:SetPoint("TOPLEFT", scrollFrame.rows[i-1], "BOTTOMLEFT")
	end
	rawset(t, i, row)
	return row
end })

scrollFrame.rows = rows

--Shows a menu with options and sharing options
local extractMenu = CreateFrame("Button", "ProfessionMenu_ExtractInterface_FilterMenu", self.DeScrollFrame, "FilterDropDownMenuTemplate")
    extractMenu:SetSize(133, 30)
    extractMenu:SetPoint("BOTTOMRIGHT", self.DeScrollFrame, "BOTTOMRIGHT", 0, -35)
    extractMenu:RegisterForClicks("LeftButtonDown")
    extractMenu:SetScript("OnClick", function(button)
        self:ItemMenuRegister(button)
    end)
--Shows a vendor all thats left button
local vendorBttn = CreateFrame("Button", "ProfessionMenu_ExtractInterface_AutoVendor", self.DeScrollFrame, "OptionsButtonTemplate")
    vendorBttn:SetSize(133, 30)
    vendorBttn:SetPoint("BOTTOMLEFT", self.DeScrollFrame, "BOTTOMLEFT", 0, -35)
    vendorBttn:RegisterForClicks("LeftButtonDown")
    vendorBttn:SetText("Vendor All")
    vendorBttn:SetScript("OnClick", function(button)
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

end

PM:DeScrollFrameCreate()
