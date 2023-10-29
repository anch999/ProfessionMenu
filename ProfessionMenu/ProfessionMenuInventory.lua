local PM = LibStub("AceAddon-3.0"):GetAddon("ProfessionMenu")
local dewdrop = AceLibrary("Dewdrop-2.0")
local mainframe = CreateFrame("FRAME", "ProfessionMenuExtractFrame", UIParent,"UIPanelDialogTemplate")
    mainframe:SetSize(460,508)
    mainframe:SetPoint("CENTER",0,0)
    mainframe:EnableMouse(true)
    mainframe:SetMovable(true)
    mainframe:RegisterForDrag("LeftButton")
    mainframe:SetScript("OnDragStart", function(self) mainframe:StartMoving() end)
    mainframe:SetScript("OnDragStop", function(self) mainframe:StopMovingOrSizing() end)
    mainframe:SetScript("OnShow", function()
        PM:SearchBags()
        PM:RegisterEvent("BAG_UPDATE", PM.SearchBags)
    end)
    mainframe:SetScript("OnHide", function()
        PM:UnregisterEvent("BAG_UPDATE")
    end)
    mainframe.TitleText = mainframe:CreateFontString()
    mainframe.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 12)
    mainframe.TitleText:SetFontObject(GameFontNormal)
    mainframe.TitleText:SetText("Disenchanting List")
    mainframe.TitleText:SetPoint("TOP", 0, -9)
    mainframe.TitleText:SetShadowOffset(1,-1)
    mainframe:Hide()

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

local InventoryTypes = {
    ["Weapon"] = true,
    ["Armor"] = true
}

function PM:InventoryFrame_Open(isEnabled)
    if not isEnabled then return end
    if mainframe:IsVisible() then
        mainframe:Hide()
    else
        mainframe:Show()
    end
end

function PM:UpdateItemFrame(arg2)
    if arg2 ~= "Disenchant" then return end
    PM:RegisterEvent("BAG_UPDATE")
    PM:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

function PM:BAG_UPDATE()
    PM:ScheduleTimer(function() PM:SearchBags() end, .10)
    PM:UnregisterEvent("BAG_UPDATE")
end

local function filterCheck(quality, bagID, slotID)
    for _, _ in ipairs(PM.FilterList) do
        if (PM.db.FilterList[4] and PM:IsSoulbound(bagID, slotID)) or (quality < 1 or quality > 5) or PM.db.FilterList[quality-1] then
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
            if not PM.db.BagFilter[bagID+1] then
                for slotID = 1, GetContainerNumSlots(bagID) do
                    local quality,_,_,link = select(4,GetContainerItemInfo(bagID,slotID))
                    local itemID = GetContainerItemID(bagID,slotID)
                    if link and not PM.db.ItemBlacklist[itemID] then
                        local itemType = select(6,GetItemInfo(itemID))
                        if not filterCheck(quality, bagID, slotID) and InventoryTypes[itemType] then
                            tinsert(inventoryItems,{bagID,slotID,link,quality})
                        end
                    end
                end
            end
        end
        bagThrottle = true
        PM.bagThrottle = PM:ScheduleTimer(function() bagThrottle = false end, .1)
        ProfessionMenu_InventroyScrollFrameUpdate()
    end
end

function PM:ItemMenuRegister(self)
    dewdrop:Register(self,
        'point', function(parent)
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value)
            if level == 1 then
                for k, v in ipairs(PM.FilterList) do
                    local text = v[1]
                    if tonumber(v[2]) then
                        text = select(4, GetItemQualityColor(v[2])) .. v[1]
                    end
                    dewdrop:AddLine(
                        'text', text,
                        'func', function() PM.db.FilterList[k] = not PM.db.FilterList[k] PM:SearchBags() end,
                        'checked', PM.db.FilterList[k],
                        'textHeight', 12,
                        'textWidth', 12
                    )
                end
                dewdrop:AddLine(
                    'text', PM.FilterList.Soulbound,
                    'func', function() PM.db.FilterList[4] = not PM.db.FilterList[4] PM:SearchBags() end,
                    'checked', PM.db.FilterList[4],
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
                    for i, bag in ipairs(PM.FilterList.Bags) do
                        dewdrop:AddLine(
                            'text', bag,
                            'func', function() PM.db.BagFilter[i] = not PM.db.BagFilter[i] PM:SearchBags() end,
                            'checked', PM.db.BagFilter[i],
                            'textHeight', 12,
                            'textWidth', 12
                        )
                    end
                end
            end
        end,
        'dontHook', true
    )
end

------------------ScrollFrameTooltips---------------------------
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

local scrollFrame = CreateFrame("Frame", "ProfessionMenu_DE_ScrollFrame", ProfessionMenuExtractFrame)
    scrollFrame:EnableMouse(true)
    scrollFrame:SetSize(420, ROW_HEIGHT * MAX_ROWS + 16)
    scrollFrame:SetPoint("TOPLEFT",20,-42)
    scrollFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

function ProfessionMenu_InventroyScrollFrameUpdate()
    local maxValue = #inventoryItems
	FauxScrollFrame_Update(scrollFrame.scrollBar, maxValue, MAX_ROWS, ROW_HEIGHT)
	local offset = FauxScrollFrame_GetOffset(scrollFrame.scrollBar)
	for i = 1, MAX_ROWS do
		local value = i + offset
        scrollFrame.rows[i]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
		if value <= maxValue then
			local row = scrollFrame.rows[i]
            row.Text:SetText(inventoryItems[value][3])
            row.link = inventoryItems[value][3]
			row.bag = inventoryItems[value][1]
            row.slot = inventoryItems[value][2]
            row:SetAttribute("type", "spell")
            row:SetAttribute("spell", "Disenchant")
            row:SetAttribute("target-bag", row.bag)
            row:SetAttribute("target-slot", row.slot)
            row.tNumber = value
            row:Show()
		else
			scrollFrame.rows[i]:Hide()
		end
	end
end

local scrollSlider = CreateFrame("ScrollFrame","ProfessionMenuDEListFrameScroll",ProfessionMenu_DE_ScrollFrame,"FauxScrollFrameTemplate")
scrollSlider:SetPoint("TOPLEFT", 0, -8)
scrollSlider:SetPoint("BOTTOMRIGHT", -30, 8)
scrollSlider:SetScript("OnVerticalScroll", function(self, offset)
    self.offset = math.floor(offset / ROW_HEIGHT + 0.5)
    ProfessionMenu_InventroyScrollFrameUpdate()
end)

scrollFrame.scrollBar = scrollSlider

local rows = setmetatable({}, { __index = function(t, i)
	local row = CreateFrame("Button", "$parentRow"..i, scrollFrame, "SecureActionButtonTemplate")
	row:SetSize(405, ROW_HEIGHT)
	row:SetNormalFontObject(GameFontHighlightLeft)
    row.Text = row:CreateFontString("$parentRow"..i.."Text","OVERLAY","GameFontNormal")
    row.Text:SetSize(260, ROW_HEIGHT)
    row.Text:SetPoint("LEFT",row)
    row.Text:SetJustifyH("LEFT")
    row:SetScript("OnMouseDown", function()
        PM:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
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
local extractMenu = CreateFrame("Button", "ProfessionMenu_ExtractInterface_FilterMenu", ProfessionMenu_DE_ScrollFrame, "FilterDropDownMenuTemplate")
    extractMenu:SetSize(133, 30)
    extractMenu:SetPoint("BOTTOMRIGHT", ProfessionMenu_DE_ScrollFrame, "BOTTOMRIGHT", 0, -35)
    extractMenu:RegisterForClicks("LeftButtonDown")
    extractMenu:SetScript("OnClick", function(self)
        if dewdrop:IsOpen() then
            dewdrop:Close()
        else
            PM:ItemMenuRegister(self)
            dewdrop:Open(self)
        end
    end)


