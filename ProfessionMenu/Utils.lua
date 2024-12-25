local PM = LibStub("AceAddon-3.0"):GetAddon("ProfessionMenu")
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"

function PM:GetTipAnchor(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
    local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
    return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
end

-- returns true, if player has item with given ID in inventory or bags and it's not on cooldown
function PM:HasItem(itemID)
	local item, found, id
	-- scan bags
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			item = GetContainerItemLink(bag, slot)
			if item then
				found, _, id = item:find('^|c%x+|Hitem:(%d+):.+')
				if found and tonumber(id) == itemID then
					return true, bag, slot
				end
			end
		end
	end
	return false
end

--for a adding a divider to dew drop menus 
function PM:AddDividerLine(maxLenght)
    local text = WHITE.."----------------------------------------------------------------------------------------------------"
    self.dewdrop:AddLine(
        'text' , text:sub(1, maxLenght),
        'textHeight', self.db.txtSize,
        'textWidth', self.db.txtSize,
        'isTitle', true,
        "notCheckable", true
    )
    return true
end

local items = {
    {1777028, "Summon Thermal Anvil"}, -- thermal anvil
    {1904514, "Summon Portable Sanguine Workbench"}, -- sanguine workbench vanity
    {1904515}, -- sanguine workbench soulbound
}

-- deletes item from players inventory if value 2 in the items table is set
function PM:RemoveItem(arg2)
	if not self.db.DeleteItem then return end
	for _, item in ipairs(items) do
        if arg2 == item[2] then
            local found, bag, slot = self:HasItem(item[1])
            local binding = self:GetTooltipItemInfo(nil, bag, slot)
            if found and C_VanityCollection.IsCollectionItemOwned(item[1]) and binding.isSoulbound then
                ClearCursor()
                PickupContainerItem(bag, slot)
                DeleteCursorItem()
            end
        end
	end
    if not self.InventoryFrame:IsVisible() then
	    self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    end
end

function PM:ReturnItemIDs()
    local list = {}
    for _, item in ipairs(items) do
        if self:HasItem(item[1]) or C_VanityCollection.IsCollectionItemOwned(item[1]) then
            tinsert(list, item[1])
        end
    end
    return list
end

local profSubList = {
    {13262, leftClick = {"Enchanting", "Left click to open disenchanting interface Right click to use disenchanting"}},
    {31252},
    {818},
    {1804, leftClick = {"Lockpicking", "Left click to open lockpicking interface Right click to use lockpicking"}},
    {1501804, leftClick = {"Lockpicking", "Lockpicking", "Left click to open lockpicking interface Right click to use lockpicking"}},
    {13977834},
}

-- returns a list of known spellIDs
function PM:ReturnSpellIDs()
    local list = {}
    for _, spell in ipairs(profSubList) do
        if CA_IsSpellKnown(spell[1]) then
            tinsert(list, spell)
        end
    end
    return list
end

PM.BrilliantGlass = {23117,23077,23079,21929,23112,23107}

function PM:PullGuildBankItems(list, number)
    local emptySlots = {}
    local function scanBag()
        for bagID = 0, 4 do
            for slotID = 1, GetContainerNumSlots(bagID) do
            local item = GetContainerItemInfo(bagID, slotID)
                if not item then
                    tinsert(emptySlots, {bagID,slotID})
                end
            end
        end
    end

    local function scanGuildBank(ID,bagID,slotID)
        local tab = GetCurrentGuildBankTab()
        if not tab then return end
        for c = 1, 112 do
        local link = GetGuildBankItemLink(tab, c)
            if link then
                local itemID = GetItemInfoFromHyperlink(link)
                    if itemID == ID and select(2,GetGuildBankItemInfo(tab, c)) >= number then
                        SplitGuildBankItem(tab, c, number)
                        PickupContainerItem(bagID,slotID)
                        return true
                    end
            elseif c == 112 then
                return true
            end
        end
    end
    scanBag()
    for num, ID in pairs(list) do
        local function nextItem()
            local task = tremove(emptySlots)
            while task do
                local complete = scanGuildBank(ID,task[1],task[2])
                if #list == num or complete then
                    return
                else
                    return nextItem()
                end
            end
        end
        nextItem()
    end
end

--========================================
-- Retrieve additional item info via the
-- item's tooltip
--========================================
local cTip = CreateFrame("GameTooltip","cTooltip",nil,"GameTooltipTemplate")
function PM:GetTooltipItemInfo(link, bag, slot)
    cTip:SetOwner(UIParent, "ANCHOR_NONE")

    -- set up return values
    local binds = {}

    -- generate item tooltip in hidden tooltip object
    if link then
        cTip:SetHyperlink(link)
    elseif bag and slot then
        cTip:SetBagItem(bag, slot)
    else
        return
    end

    for i = 1,cTip:NumLines() do
        local text = _G["cTooltipTextLeft"..i]:GetText()
        if text == "Realm Bound" then binds.isRealmbound = true end
        if text == ITEM_SOULBOUND then  binds.isSoulbound = true end
        if text == ITEM_BIND_ON_PICKUP then binds.isBoP = true end
        if text == ITEM_SPELL_KNOWN then binds.isKnown = true end
        if text == LOCKED then binds.isLocked = true end
        if text == "<Right Click to Open>" or text == "\"Right Click to Open\"" then binds.isUnlocked = true end
    end

    cTip:Hide()

    return binds
end
