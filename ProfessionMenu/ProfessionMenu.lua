ProfessionMenu = LibStub("AceAddon-3.0"):NewAddon("ProfessionMenu", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
local PM = LibStub("AceAddon-3.0"):GetAddon("ProfessionMenu")
local addonName = ...
local professionbutton, mainframe
local dewdrop = AceLibrary("Dewdrop-2.0")
local defIcon = "Interface\\Icons\\achievement_guildperk_bountifulbags"
local icon = LibStub('LibDBIcon-1.0')
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"

PROFESSIONMENU_MINIMAP = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject(addonName, {
    type = 'data source',
    text = "ProfessionMenu",
    icon = defIcon,
  })
local minimap = PROFESSIONMENU_MINIMAP


--Set Savedvariables defaults
local DefaultSettings  = {
    { TableName = "ShowMenuOnHover", false, Frame = "ProfessionMenuFrame",CheckBox = "ProfessionMenuOptions_ShowOnHover" },
    { TableName = "HideMenu", false, Frame = "ProfessionMenuFrame", CheckBox = "ProfessionMenuOptions_HideMenu"},
    { TableName = "DeleteItem", false, CheckBox = "ProfessionMenuOptions_DeleteMenu"},
    { TableName = "minimap", false, CheckBox = "ProfessionMenuOptions_HideMinimap"},
    { TableName = "txtSize", 12},
    { TableName = "autoMenu", false, CheckBox = "ProfessionMenuOptions_AutoMenu"},
    { TableName = "FilterList", {false,false,false,false} },
    { TableName = "BagFilter", {false,false,false,false,false} },
    { TableName = "ItemBlacklist", { [9149] = true }},
    { TableName = "hideMaxRank", false, CheckBox = "ProfessionMenuOptions_HideMaxRank"},
    { TableName = "hideRank", false, CheckBox = "ProfessionMenuOptions_HideRank"}
}

--[[ TableName = Name of the saved setting
CheckBox = Global name of the checkbox if it has one and first numbered table entry is the boolean
Text = Global name of where the text and first numbered table entry is the default text 
Frame = Frame or button etc you want hidden/shown at start based on condition ]]
local function setupSettings(db)
    for _,v in ipairs(DefaultSettings) do
        if db[v.TableName] == nil then
            if #v > 1 then
                db[v.TableName] = {}
                for _, n in ipairs(v) do
                    tinsert(db[v.TableName], n)
                end
            else
                db[v.TableName] = v[1]
            end
        end

        if v.CheckBox then
            _G[v.CheckBox]:SetChecked(db[v.TableName])
        end
        if v.Text then
            _G[v.Text]:SetText(db[v.TableName])
        end
        if v.Frame then
            if db[v.TableName] then _G[v.Frame]:Hide() else _G[v.Frame]:Show() end
        end
    end
end

local profList = {
    {
        51304, -- Grand Master 450
        28596, -- Master 375
        11611, -- Artisan 300
        3464, -- Expert 225
        3101, -- Journeyman 150
        2259, -- Apprentice 75
    }, --ALCHEMY
    {
        51300, -- Grand Master 450
        29844, -- Master 375
        9785, -- Artisan 300
        3538, -- Expert 225
        3100, -- Journeyman 150
        2018, -- Apprentice 75
    }, --BLACKSMITHING
    {
        51313, -- Grand Master 450
        28029, -- Mater 375
        13920, -- Artisan 300
        7413, -- Expert 225
        7412, -- Journeyman 150
        7411, -- Apprentice 75
        frame = {"ProfessionMenuExtractFrame", "Enchanting", "Right click to open disenchanting frame"}
    }, --ENCHANTING
    {
        51306, -- Grand Master 450
        30350, -- Master 375
        12656, -- Artisan 300
        4038, -- Expert 225
        4037, -- Journeyman 150
        4036, -- Apprentice 75
    }, --ENGINEERING
    {
        45363, -- Grand Master 450
        45361, -- Master 375
        45360, -- Artisan 300
        45359, -- Expert 225
        45358, -- Journeyman 150
        45357, -- Apprentice 75
    }, --INSCRIPTION
    {
        51311, -- Grand Master 450
        28897, -- Master 375
        28895, -- Artisan 300
        28894, -- Expert 225
        25230, -- Journeyman 150
        25229, -- Apprentice 75
    }, --JEWELCRAFTING 
    {
        51302, -- Grand Master 450
        32549, -- Master 375
        10662, -- Artisan 300
        3811, -- Expert 225
        3104, -- Journeyman 150
        2108, -- Apprentice 75
    }, --LEATHERWORKING
    {2656}, --SMELTING
    {
        51309, -- Grand Master 450
        26790, -- Master 375
        12180, -- Artisan 300
        3910, -- Expert 225
        3909, -- Journeyman 150
        3908, -- Apprentice 75
    }, --TAILORING
    {
        51296, -- Grand Master 450
        33359, -- Master 375
        18260, -- Artisan 300
        3413, -- Expert 225
        3102, -- Journeyman 150
        2550, -- Apprentice 75
    }, --COOKING
    {
        45542, -- Grand Master 450
        27028, -- Expert 375
        10846, -- Artisan 300
        7924, -- Expert 225
        3274, -- Journeyman 150
        3273, -- Apprentice 75
    }, --FIRSTAID
    {13977860}, --WOODCUTTING
}

local profSubList = {
    13262,
    31252,
    818,
}
function PM:UNIT_SPELLCAST_SUCCEEDED(event, arg1, arg2)
	PM:RemoveItem(arg2)
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

local items = {
    {1777028, "Summon Thermal Anvil"}, -- thermal anvil
    {1904514, "Summon Sanguine Workbench"}, -- sanguine workbench vanity
    {1904515},
}

-- deletes item from players inventory if value 2 in the items table is set
function PM:RemoveItem(arg2)
	if not PM.db.DeleteItem then return end
	for _, item in ipairs(items) do
        if arg2 == item[2] then
            local found, bag, slot = PM:HasItem(item[1])
            if found and C_VanityCollection.IsCollectionItemOwned(item[1]) and PM:IsSoulbound(bag, slot) then
                PickupContainerItem(bag, slot)
                DeleteCursorItem()
            end
        end
	end
	PM:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

local function returnItemIDs()
    local list = {}
    for _, item in ipairs(items) do
        if PM:HasItem(item[1]) or C_VanityCollection.IsCollectionItemOwned(item[1]) then
            tinsert(list, item[1])
        end
    end
    return list
end

-- returns a list of known spellIDs
local function returnSpellIDs()
    local list = {}
    for _, spellID in ipairs(profSubList) do
        if CA_IsSpellKnown(spellID) then
            tinsert(list, spellID)
        end
    end
    return list
end

-- add altar summon button via dewdrop secure
local function addItem(itemID)
        local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
        local startTime, duration = GetItemCooldown(itemID)
		local cooldown = math.ceil(((duration - (GetTime() - startTime))/60))
		local text = name
		if cooldown > 0 then
		text = name.." |cFF00FFFF("..cooldown.." ".. "mins" .. ")"
		end
		local secure = {
		type1 = 'item',
		item = name
		}
        dewdrop:AddLine(
                'text', text,
                'icon', icon,
                'secure', secure,
                'func', function() if not PM:HasItem(itemID) then RequestDeliverVanityCollectionItem(itemID) else if PM.db.DeleteItem then PM:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED") end dewdrop:Close() end end,
                'textHeight', PM.db.txtSize,
                'textWidth', PM.db.txtSize
        )
end

--for a adding a divider to dew drop menus 
function PM:AddDividerLine(maxLenght)
    local text = WHITE.."----------------------------------------------------------------------------------------------------"
    dewdrop:AddLine(
        'text' , text:sub(1, maxLenght),
        'textHeight', PM.db.txtSize,
        'textWidth', PM.db.txtSize,
        'isTitle', true,
        "notCheckable", true
    )
    return true
end

function PM:GetProfessions()
    local function getProfessionRanks(compName)
        for skillIndex = 1, GetNumSkillLines() do
            local name, _, _, rank, _, _, maxRank, _, _, _, _, _, _ = GetSkillLineInfo(skillIndex)
            if compName:match(name) then
                return rank, maxRank
            end
        end
    end

     for _, prof in ipairs(profList) do
        for _, spellID in ipairs(prof) do
            if CA_IsSpellKnown(spellID) then
                local name, _, icon = GetSpellInfo(spellID)
                local rank, maxRank = getProfessionRanks(name)
                if not PM.db.hideRank and PM.db.hideMaxRank then
                    name = name .. " |cFF00FFFF("..rank..")"
                end
                if not PM.db.hideMaxRank and PM.db.hideRank then
                    name = name .. " |cFF00FFFF("..maxRank..")"
                end
                if not PM.db.hideMaxRank and not PM.db.hideRank then
                    name = name .. " |cFF00FFFF("..rank.."/"..maxRank..")"
                end
                local secure = {
                    type1 = 'spell',
                    spell = spellID
                    }
                local openFrame, tooltipTitle, tooltipText
                if prof.frame then
                    openFrame = true
                    tooltipTitle = prof.frame[2]
                    tooltipText = prof.frame[3]
                end
                dewdrop:AddLine(
                        'text', name,
                        'icon', icon,
                        'secure', secure,
                        'closeWhenClicked', true,
                        'funcRight', function() PM:InventoryFrame_Open(openFrame) end,
                        'textHeight', PM.db.txtSize,
                        'textWidth', PM.db.txtSize,
                        'tooltipTitle', tooltipTitle,
                        'tooltipText', tooltipText
                )
            end
        end
    end
end

--sets up the drop down menu for specs
local function ProfessionMenu_DewdropRegister(self)
    if dewdrop:IsOpen(self) then dewdrop:Close() return end
    dewdrop:Register(self,
        'point', function(parent)
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value)
            dewdrop:AddLine(
                'text', "|cffffff00Professions",
                'textHeight', PM.db.txtSize,
                'textWidth', PM.db.txtSize,
                'isTitle', true,
                'notCheckable', true
            )
            PM:GetProfessions()
            local divider

            local SummonItems = returnItemIDs()

            if #SummonItems > 0 then
                if not divider then divider = PM:AddDividerLine(35) end
                for _, itemID in ipairs(SummonItems) do
                    addItem(itemID)
                end
            end

            if CA_IsSpellKnown(750750) then
                if not divider then divider = PM:AddDividerLine(35) end
                local name, _, icon = GetSpellInfo(750750)
                local secure = { type1 = 'spell', spell = name }
                dewdrop:AddLine( 'text', name, 'icon', icon, 'secure', secure, 'closeWhenClicked', true, 'textHeight', PM.db.txtSize, 'textWidth', PM.db.txtSize)
            end

            local spellIDs = returnSpellIDs()
            if #spellIDs > 0 then
                PM:AddDividerLine(35)
                for _, spellID in ipairs(spellIDs) do
                    local name, _, icon = GetSpellInfo(spellID)
                    local secure = { type1 = 'spell', spell = spellID }
                    dewdrop:AddLine( 'text', name, 'icon', icon,'secure', secure, 'closeWhenClicked', true, 'textHeight', PM.db.txtSize, 'textWidth', PM.db.txtSize)    
                end
            end
            PM:AddDividerLine(35)
            if self.show then
                dewdrop:AddLine(
                    'text', "Unlock Frame",
                    'textHeight', PM.db.txtSize,
                    'textWidth', PM.db.txtSize,
                    'func', PM.UnlockFrame,
                    'notCheckable', true,
                    'closeWhenClicked', true
                )
            end
            dewdrop:AddLine(
				'text', "Options",
                'textHeight', PM.db.txtSize,
                'textWidth', PM.db.txtSize,
				'func', PM.Options_Toggle,
				'notCheckable', true,
                'closeWhenClicked', true
			)
            dewdrop:AddLine(
				'text', "Close Menu",
                'textR', 0,
                'textG', 1,
                'textB', 1,
                'textHeight', PM.db.txtSize,
                'textWidth', PM.db.txtSize,
				'closeWhenClicked', true,
				'notCheckable', true
			)
		end,
		'dontHook', true
	)
    dewdrop:Open(self)
    local hook
    if not hook then
        WorldFrame:HookScript("OnEnter", function()
            if dewdrop:IsOpen(self) then
                dewdrop:Close()
            end
        end)
        hook = true
    end

    GameTooltip:Hide()
end

local function toggleMainButton(toggle)
    if PM.db.ShowMenuOnHover then
        if toggle == "show" then
            ProfessionMenuFrame_Menu:Show()
            ProfessionMenuFrame.icon:Show()
            ProfessionMenuFrame.Text:Show()
        else
            ProfessionMenuFrame_Menu:Hide()
            ProfessionMenuFrame.icon:Hide()
            ProfessionMenuFrame.Text:Hide()
        end
    end
end

-- Used to show highlight as a frame mover
local unlocked = false
function PM:UnlockFrame()
    if unlocked then
        ProfessionMenuFrame_Menu:Show()
        ProfessionMenuFrame.Highlight:Hide()
        unlocked = false
        GameTooltip:Hide()
    else
        ProfessionMenuFrame_Menu:Hide()
        ProfessionMenuFrame.Highlight:Show()
        unlocked = true
    end
end

--Creates the main interface
	mainframe = CreateFrame("Button", "ProfessionMenuFrame", UIParent, nil)
    mainframe:SetSize(70,70)
    mainframe:EnableMouse(true)
    
    mainframe:RegisterForDrag("LeftButton")
    mainframe:SetScript("OnDragStart", function(self) mainframe:StartMoving() end)
    mainframe:SetScript("OnDragStop", function(self)
        mainframe:StopMovingOrSizing()
        PM.db.menuPos = {mainframe:GetPoint()}
        PM.db.menuPos[2] = "UIParent"
    end)
    mainframe:SetMovable(true)
    mainframe:RegisterForClicks("RightButtonDown")
    mainframe:SetScript("OnClick", function(self, btnclick) if unlocked then PM:UnlockFrame() end end)
    mainframe.icon = mainframe:CreateTexture(nil, "ARTWORK")
    mainframe.icon:SetSize(55,55)
    mainframe.icon:SetPoint("CENTER", mainframe,"CENTER",0,0)
    mainframe.icon:SetTexture(defIcon)
    mainframe.Text = mainframe:CreateFontString()
    mainframe.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)
    mainframe.Text:SetFontObject(GameFontNormal)
    mainframe.Text:SetText("|cffffffffProf\nMenu")
    mainframe.Text:SetPoint("CENTER", mainframe.icon, "CENTER", 0, 0)
    mainframe.Highlight = mainframe:CreateTexture(nil, "OVERLAY")
    mainframe.Highlight:SetSize(70,70)
    mainframe.Highlight:SetPoint("CENTER", mainframe, 0, 0)
    mainframe.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
    mainframe.Highlight:Hide()
    mainframe:Hide()
    mainframe:SetScript("OnEnter", function(self) 
        if unlocked then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine("Left click to drag")
            GameTooltip:AddLine("Right click to lock frame")
            GameTooltip:Show()
        else
            toggleMainButton("show")
        end
    end)
    mainframe:SetScript("OnLeave", function() GameTooltip:Hide() end)

	professionbutton = CreateFrame("Button", "ProfessionMenuFrame_Menu", ProfessionMenuFrame)
    professionbutton:SetSize(70,70)
    professionbutton:SetPoint("BOTTOM", ProfessionMenuFrame, "BOTTOM", 0, 2)
    professionbutton:RegisterForClicks("LeftButtonDown", "RightButtonDown")
    professionbutton:Show()
    professionbutton:SetScript("OnClick", function(self, btnclick) if not PM.db.autoMenu then ProfessionMenu_DewdropRegister(self) end end)
    professionbutton.show = true
    professionbutton:SetScript("OnEnter", function(self)
        if PM.db.autoMenu then
            ProfessionMenu_DewdropRegister(self)
        end
        if not dewdrop:IsOpen() then
        PM:OnEnter(self)
        end
        mainframe.Highlight:Show()
        toggleMainButton("show")
    end)
    professionbutton:SetScript("OnLeave", function()
        mainframe.Highlight:Hide()
        GameTooltip:Hide()
        toggleMainButton("hide")
    end)

InterfaceOptionsFrame:HookScript("OnShow", function()
    if InterfaceOptionsFrame and ProfessionMenuOptionsFrame:IsVisible() then
		PM:OpenOptions()
    end
end)

function PM:OnInitialize()
    if not ProfessionMenuDB then ProfessionMenuDB = {} end
    PM.db = ProfessionMenuDB
    setupSettings(PM.db)
end

-- toggle the main button frame
local function toggleMainFrame()
    if ProfessionMenuFrame:IsVisible() then
        ProfessionMenuFrame:Hide()
    else
        ProfessionMenuFrame:Show()
    end
end

--[[
SlashCommand(msg):
msg - takes the argument for the /mysticextended command so that the appropriate action can be performed
If someone types /mysticextended, bring up the options box
]]
local function SlashCommand(msg)
    if msg == "reset" then
        ProfessionMenuDB = nil
        PM:OnInitialize()
        DEFAULT_CHAT_FRAME:AddMessage("Settings Reset")
    elseif msg == "options" then
        PM:Options_Toggle()
    else
        toggleMainFrame()
    end
end

function PM:OnEnable()
    if icon then
        PM.map = {hide = PM.db.minimap}
        icon:Register('ProfessionMenu', minimap, PM.map)
    end

    if PM.db.menuPos then
        local pos = PM.db.menuPos
        mainframe:ClearAllPoints()
        mainframe:SetPoint(pos[1], pos[2], pos[3], pos[4], pos[5])
    else
        mainframe:ClearAllPoints()
        mainframe:SetPoint("CENTER", UIParent)
    end

    toggleMainButton("hide")
    --Enable the use of /me or /mysticextended to open the loot browser
    SLASH_PROFESSIONMENU1 = "/PROFESSIONMENU"
    SLASH_PROFESSIONMENU2 = "/PM"
    SlashCmdList["PROFESSIONMENU"] = function(msg)
        SlashCommand(msg)
    end
    PM:RegisterEvent("ADDON_LOADED")
    
    --Add the ProfessionMenu Extract Frame to the special frames tables to enable closing wih the ESC key
	tinsert(UISpecialFrames, "ProfessionMenuExtractFrame")
end

local function GetTipAnchor(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
    local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
    return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
end

function minimap.OnClick(self, button)
    GameTooltip:Hide()
    if not PM.db.autoMenu then
        ProfessionMenu_DewdropRegister(self)
    end
end

function minimap.OnLeave()
    GameTooltip:Hide()
end

function PM:OnEnter(self)
    if PM.db.autoMenu then
        ProfessionMenu_DewdropRegister(self)
    else
        GameTooltip:SetOwner(self, 'ANCHOR_NONE')
        GameTooltip:SetPoint(GetTipAnchor(self))
        GameTooltip:ClearLines()
        GameTooltip:AddLine("ProfessionMenu")
        GameTooltip:Show()
    end
end

function minimap.OnEnter(self)
    PM:OnEnter(self)
end

function PM:ToggleMinimap()
    local hide = not PM.db.minimap
    PM.db.minimap = hide
    if hide then
      icon:Hide('ProfessionMenu')
    else
      icon:Show('ProfessionMenu')
    end
end

function PM:UpdateButtonText(i)
    local scrollFrame = HelpMenuFrameRightInsetItemRestorePanel.RecoveryScroll.ScrollFrame
    local text = scrollFrame.buttons[i].SubText:GetText()
    if scrollFrame.buttons[i].item then
        local spellID = PM:GetRecipeData(scrollFrame.buttons[i].item.ItemEntry, "item")
        if spellID then
            if CA_IsSpellKnown(spellID) then
                scrollFrame.buttons[i].SubText:SetText(text.."  |cff1eff00(Known)")
            else
                scrollFrame.buttons[i].SubText:SetText(text.."  |cffff0000(Unknown)")
            end
        end
    end
end

function PM:InitializeTextUpdate()
    for i = 1, 11 do
        local updateItemButton = HelpMenuFrameRightInsetItemRestorePanel.RecoveryScroll.ScrollFrame.buttons[i]
        local updateItemButtonOld = updateItemButton.Update
            updateItemButton.Update = function(...)
                updateItemButtonOld(...)
                PM:UpdateButtonText(i)
            end
    end
end

function PM:GetRecipeData(recipeID, idType)
	for _,prof in pairs(TRADESKILL_RECIPES) do
		for _,cat in pairs(prof) do
		   for _,recipe in pairs(cat) do
			  if (idType == "spell" and recipeID == recipe.SpellEntry) or (idType == "item" and recipeID == recipe.RecipeItemEntry) then
				return recipe.SpellEntry
			  end
		   end
		end
	 end
end

function PM:ADDON_LOADED(event, arg1, arg2, arg3)
	-- setup for auction house window
	if event == "ADDON_LOADED" and arg1 == "Ascension_HelpUI" then
        PM:LoadTradeskillRecipes()
		PM:InitializeTextUpdate()
	end
end

function PM:LoadTradeskillRecipes()
	if TRADESKILL_RECIPES then return end
		TRADESKILL_RECIPES = {}
		TRADESKILL_CRAFTS = {}

		local fmtSubClass = "ITEM_SUBCLASS_%d_%d"
		local fmtTotem = "SPELL_TOTEM_%d"
		local fmtObject = "SPELL_FOCUS_OBJECT_%d"

		local content = C_ContentLoader:Load("TradeSkillRecipeData")

		local function GetToolName(toolID)
			return _G[format(fmtTotem, toolID)]
		end

		content:SetParser(function(_, data)
			if not TRADESKILL_RECIPES[data.SkillIndex] then
				TRADESKILL_RECIPES[data.SkillIndex] = {}
			end

			data.Category = _G[format(fmtSubClass, data.CreatedItemClass, data.CreatedItemSubClass)]

			if not TRADESKILL_RECIPES[data.SkillIndex][data.Category] then
				TRADESKILL_RECIPES[data.SkillIndex][data.Category] = {}
			end

			data.IsHighRisk = toboolean(data.IsHighRisk)

			-- reformat reagents
			data.Reagents = {}
			local reagents = data.ReagentData:SplitToTable(",")
			for _, reagentString in ipairs(reagents) do
				local item, count = reagentString:match("(%d*):(%d*)")
				item = tonumber(item)
				count = tonumber(count)
				if item and item ~= 0 and count and count ~= 0 then
					tinsert(data.Reagents, {item, count})
				end
			end

			if #data.Reagents > 0 then
				data.ReagentData = nil

				-- reformat tools (totems)
				data.Tools = data.TotemCategories:SplitToTable(",", GetToolName)
				data.TotemCategories = nil

				data.SpellFocusObject = _G[format(fmtObject, data.SpellFocusObject)]

				tinsert(TRADESKILL_RECIPES[data.SkillIndex][data.Category], data)
				if data.CreatedItemEntry > 0 then
					TRADESKILL_CRAFTS[data.CreatedItemEntry] = data
				end
			end
		end)

		content:Parse()
end