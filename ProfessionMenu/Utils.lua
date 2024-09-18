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

local cTip = CreateFrame("GameTooltip","cTooltip",nil,"GameTooltipTemplate")

function PM:IsSoulbound(bag, slot)
    cTip:SetOwner(UIParent, "ANCHOR_NONE")
    cTip:SetBagItem(bag, slot)
    cTip:Show()
    for i = 1,cTip:NumLines() do
        if(_G["cTooltipTextLeft"..i]:GetText()==ITEM_SOULBOUND) then
            return true
        end
    end
    cTip:Hide()
    return false
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
            if found and C_VanityCollection.IsCollectionItemOwned(item[1]) and self:IsSoulbound(bag, slot) then
                PickupContainerItem(bag, slot)
                DeleteCursorItem()
            end
        end
	end
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
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
    13262,
    31252,
    818,
    1804,
    1501804,
    13977834,
}

-- returns a list of known spellIDs
function PM:ReturnSpellIDs()
    local list = {}
    for _, spellID in ipairs(profSubList) do
        if CA_IsSpellKnown(spellID) then
            tinsert(list, spellID)
        end
    end
    return list
end