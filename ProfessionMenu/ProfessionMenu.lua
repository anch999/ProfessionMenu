local PM = LibStub("AceAddon-3.0"):NewAddon("ProfessionMenu", "AceTimer-3.0", "AceEvent-3.0")
PROFESSIONMENU = PM
local dewdrop = LibStub("Dewdrop-2.0")
local defIcon = "Interface\\Icons\\achievement_guildperk_bountifulbags"
local icon = LibStub('LibDBIcon-1.0')
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"

local minimap = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject("ProfessionMenu", {
    type = 'data source',
    text = "ProfessionMenu",
    icon = defIcon,
  })

--Set Savedvariables defaults
local DefaultSettings  = {
    ShowMenuOnHover = { false, ShowFrame = "ProfessionMenuFrame", CheckBox = "ProfessionMenuOptions_ShowOnHover" },
    HideMenu = { false, HideFrame = "ProfessionMenuFrame", CheckBox = "ProfessionMenuOptions_HideMenu"},
    DeleteItem = { false, CheckBox = "ProfessionMenuOptions_DeleteMenu"},
    minimap = { false, CheckBox = "ProfessionMenuOptions_HideMinimap"},
    txtSize = { 12 },
    autoMenu = { false, CheckBox = "ProfessionMenuOptions_AutoMenu"},
    FilterList = { {false,false,false,false,false} },
    BagFilter = { {false,false,false,false,false} },
    ItemBlacklist = { { [9149] = true }},
    hideMaxRank = { false, CheckBox = "ProfessionMenuOptions_HideMaxRank"},
    hideRank = { false, CheckBox = "ProfessionMenuOptions_HideRank"},
    showHerb = { false, CheckBox = "ProfessionMenuOptions_ShowHerb"},
    ShowOldTradeSkillUI = { false, CheckBox = "ProfessionMenuOptions_ShowOldTradeSkillUI"},
    selfCast = { false }
}

--[[ TableName = Name of the saved setting
CheckBox = Global name of the checkbox if it has one and first numbered table entry is the boolean
Text = Global name of where the text and first numbered table entry is the default text 
Frame = Frame or button etc you want hidden/shown at start based on condition ]]
local function setupSettings(db, defaultList)
    db = db or {}
    for table, v in pairs(defaultList) do
        if not db[table] and db[table] ~= false then
            if type(v) == "table" then
                db[table] = v[1]
            else
                db[table] = v
            end
        end
        if type(v) == "table" then
            if v.CheckBox and _G[v.CheckBox] then
                _G[v.CheckBox]:SetChecked(db[table])
            end
            if v.Text and _G[v.Text] then
                _G[v.Text]:SetText(db[table])
            end
            if v.ShowFrame and _G[v.Frame] then
                if db[table] then _G[v.Frame]:Show() else _G[v.Frame]:Hide() end
            end
            if v.HideFrame and _G[v.HideFrame] then
                if db[table] then _G[v.HideFrame]:Hide() else _G[v.HideFrame]:Show() end
            end
        end
    end
    return db
end

local profCooldowns = {
    ["Enchanting"] = {
        28027, -- Prismatic Sphere 
        28028, -- Void Sphere 
        979343, -- Transmute: Forbidding Dread Dust 
        979341, -- Transmute: Forbidding Nether Shard 
        979342, -- Transmute: Forbidding Twisted Dust 
        979344, -- Transmute: Forbidding Void Dust 
    },
    ["Alchemy"] = {
        29688, -- Transmute: Primal Might 
        32765, -- Transmute: Earthstorm Diamond 
        32766, -- Transmute: Skyfire Diamond 
        28566, -- Transmute: Primal Air to Fire 
        28567, -- Transmute: Primal Earth to Water 
        28568, -- Transmute: Primal Fire to Earth 
        28569, -- Transmute: Primal Water to Air 
    },
    ["Jewelcrafting"] = {
        47280, -- Brilliant Glass 
        979840, -- Transmute: Pure Void Metal 
        979838, -- Transmute: Pure Twisted Metal 
        979837, -- Transmute: Pure Nether Metal 
        979839, -- Transmute: Pure Dread Metal 
    },
    ["Leatherworking"] = {
        979331, -- Transmute: Full Grain Dread Leather 
        979329, -- Transmute: Full Grain Nether Leather 
        979330, -- Transmute: Full Grain Twisted Leather 
        979332, -- Transmute: Full Grain Void Leather 
    },
    ["Tailoring"] = {
        26751, -- Primal Mooncloth 
        36686, -- Shadowcloth 
        31373, -- Spellcloth 
        979327, -- Transmute: Reinforced Dread Thread 
        979325, -- Transmute: Reinforced Nether Thread 
        979326, -- Transmute: Reinforced Void Thread 
        979328, -- Transmute: Reinforced Twisted Thread 
    },
    ["Engineering"] = {
        979835, -- Transmute: Pure Dread Metal 
        979833, -- Transmute: Pure Nether Metal 
        979836, -- Transmute: Pure Void Metal 
        979834, -- Transmute: Pure Twisted Metal 
    },
    ["Mining"] = {
        979337, -- Transmute: Pure Nether Metal 
    },
}

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
        frame = {_G["PROFESSIONMENU"]["Extractframe"], "Enchanting", "Right click to open disenchanting frame"}
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
    {
    2656,
    main = 50310 -- mining spellid for rank info
    }, --SMELTING
    {2383, Name = "Herbalism", Show = "showHerb" }, --Herbalism
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
    1804,
    1501804,
    8200016,
}

function PM:OnEnable()
    if icon then
        self.map = {hide = self.db.minimap}
        icon:Register('ProfessionMenu', minimap, self.map)
    end

    if self.db.menuPos then
        self.standaloneButton:ClearAllPoints()
        self.standaloneButton:SetPoint(unpack(self.db.menuPos))
    else
        self.standaloneButton:ClearAllPoints()
        self.standaloneButton:SetPoint("CENTER", UIParent)
    end

    --self:RegisterEvent("ADDON_LOADED")
    if self.db.ShowOldTradeSkillUI then
        UIParent:UnregisterEvent("TRADE_SKILL_SHOW")
        self:RegisterEvent("TRADE_SKILL_SHOW")
    end

    ProfessionMenuFrame:SetScale(self.db.buttonScale or 1)
    --Add the ProfessionMenu Extract Frame to the special frames tables to enable closing wih the ESC key
	tinsert(UISpecialFrames, "ProfessionMenuExtractFrame")
end

function PM:OnInitialize()
     self.db = setupSettings(ProfessionMenuDB, DefaultSettings)
    --Enable the use of /PM or /PROFESSIONMENU to open the loot browser
    SLASH_PROFESSIONMENU1 = "/PROFESSIONMENU"
    SLASH_PROFESSIONMENU2 = "/PM"
    SlashCmdList["PROFESSIONMENU"] = function(msg)
        PM:SlashCommand(msg)
    end
end

function PM:UNIT_SPELLCAST_SUCCEEDED(event, arg1, arg2)
	self:RemoveItem(arg2)
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

-- add altar summon button via dewdrop secure
function PM:AddItem(itemID)
        local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
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
        dewdrop:AddLine(
                'text', text,
                'icon', icon,
                'secure', secure,
                'func', function() if not self:HasItem(itemID) then RequestDeliverVanityCollectionItem(itemID) else if self.db.DeleteItem then self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED") end dewdrop:Close() end end,
                'textHeight', self.db.txtSize,
                'textWidth', self.db.txtSize
        )
end

--for a adding a divider to dew drop menus 
function PM:AddDividerLine(maxLenght)
    local text = WHITE.."----------------------------------------------------------------------------------------------------"
    dewdrop:AddLine(
        'text' , text:sub(1, maxLenght),
        'textHeight', self.db.txtSize,
        'textWidth', self.db.txtSize,
        'isTitle', true,
        "notCheckable", true
    )
    return true
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

     for _, prof in ipairs(profList) do
        for _, spellID in ipairs(prof) do
            if IsSpellKnown(spellID) and ((prof.Show and self.db[prof.Show]) or not prof.Show) then
                local name, _, icon = GetSpellInfo(spellID)
                if prof.Name then
                    name = prof.Name
                end
                local profName = name
                if prof.main then
                    profName = GetSpellInfo(prof.main)
                end
                local rank, maxRank = getProfessionRanks(profName)
                if not self.db.hideRank and self.db.hideMaxRank then
                    name = name .. " |cFF00FFFF("..rank..")"
                end
                if not self.db.hideMaxRank and self.db.hideRank then
                    name = name .. " |cFF00FFFF("..maxRank..")"
                end
                if not self.db.hideMaxRank and not self.db.hideRank then
                    name = name .. " |cFF00FFFF("..rank.."/"..maxRank..")"
                end
                local selfCast = self.db.selfCast and "[@player] " or ""
                local secure = {
                  type1 = "macro",
                  macrotext = "/cast "..selfCast..name,
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
                        'funcRight', function() self:InventoryFrame_Open(openFrame) end,
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
    if dewdrop:IsOpen(button) then dewdrop:Close() return end
    dewdrop:Register(button,
        'point', function(parent)
            local point1, _, point2 = self:GetTipAnchor(button)
            return point1, point2
          end,
        'children', function(level, value)
            dewdrop:AddLine(
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
                dewdrop:AddLine( 'text', name, 'icon', icon, 'secure', secure, 'closeWhenClicked', true, 'textHeight', self.db.txtSize, 'textWidth', self.db.txtSize)
            end

            local spellIDs = self:ReturnSpellIDs()
            if #spellIDs > 0 then
                self:AddDividerLine(35)
                for _, spellID in ipairs(spellIDs) do
                    local name, _, icon = GetSpellInfo(spellID)
                    local selfCast = self.db.selfCast and "[@player] " or ""
                    local secure = {
                      type1 = "macro",
                      macrotext = "/cast "..selfCast..name,
                    }
                    dewdrop:AddLine( 'text', name, 'icon', icon,'secure', secure, 'closeWhenClicked', true, 'textHeight', self.db.txtSize, 'textWidth', self.db.txtSize)    
                end
            end
            self:AddDividerLine(35)
            if showUnlock then
                dewdrop:AddLine(
                    'text', "Unlock Frame",
                    'textHeight', self.db.txtSize,
                    'textWidth', self.db.txtSize,
                    'func', self.UnlockFrame,
                    'notCheckable', true,
                    'closeWhenClicked', true
                )
            end
            dewdrop:AddLine(
				'text', "Options",
                'textHeight', self.db.txtSize,
                'textWidth', self.db.txtSize,
				'func', self.Options_Toggle,
				'notCheckable', true,
                'closeWhenClicked', true
			)
            dewdrop:AddLine(
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
    dewdrop:Open(button)
    local hook
    if not hook then
        WorldFrame:HookScript("OnEnter", function()
            if dewdrop:IsOpen(button) then
                dewdrop:Close()
            end
        end)
        hook = true
    end

    GameTooltip:Hide()
end

function PM:ToggleMainButton(hide)
    if self.db.ShowMenuOnHover then
        if hide then
            self.standaloneButton.icon:Hide()
            self.standaloneButton.Text:Hide()
        else
            self.standaloneButton.icon:Show()
            self.standaloneButton.Text:Show()
        end
    end
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
    else
        self.standaloneButton:SetMovable(true)
        self.standaloneButton:RegisterForDrag("LeftButton")
        self.standaloneButton.Highlight:Show()
        self.standaloneButton.unlocked = true
    end
end

function PM:CreateUI()
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
    self.standaloneButton.icon:SetTexture(defIcon)
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
            self:ToggleMainButton()
            self.standaloneButton.Highlight:Show()
        end
    end)
    self.standaloneButton:SetScript("OnLeave", function()
        self.standaloneButton.Highlight:Hide()
        GameTooltip:Hide()
        self:ToggleMainButton(true)
    end)
end
PM:CreateUI()

InterfaceOptionsFrame:HookScript("OnShow", function()
    if InterfaceOptionsFrame and ProfessionMenuOptionsFrame:IsVisible() then
		ProfessionMenu_OpenOptions()
    end
end)

-- toggle the main button frame
function PM:ToggleMainFrame()
    if  self.standaloneButton:IsVisible() then
        self.standaloneButton:Hide()
    else
        self.standaloneButton:Show()
    end
end

--[[
PM:SlashCommand(msg):
msg - takes the argument for the /mysticextended command so that the appropriate action can be performed
If someone types /mysticextended, bring up the options box
]]
function PM:SlashCommand(msg)
    if msg == "reset" then
        ProfessionMenuDB = nil
        self.standaloneButton:ClearAllPoints()
        self.standaloneButton:SetPoint("CENTER", UIParent)
        PM:OnInitialize()
        DEFAULT_CHAT_FRAME:AddMessage("Settings Reset")
    elseif msg == "options" then
        PM:Options_Toggle()
    elseif msg == "macromenu" then
        PM:DewdropRegister(GetMouseFocus(), nil, true)
    else
        PM:ToggleMainFrame()
    end
end

function PM:TRADE_SKILL_SHOW()
    TradeSkillFrame_LoadUI()
	if TradeSkillFrame_Show then
		TradeSkillFrame_Show()
	end
end

function minimap.OnClick(self, button)
    GameTooltip:Hide()
    if not PM.db.autoMenu then
        PM:DewdropRegister(self)
    end
end

function minimap.OnLeave()
    GameTooltip:Hide()
end

function PM:OnEnter(button, show)
    if self.db.autoMenu and not UnitAffectingCombat("player") then
        self:DewdropRegister(button, show)
    else
        GameTooltip:SetOwner(button, 'ANCHOR_NONE')
        GameTooltip:SetPoint(self:GetTipAnchor(button))
        GameTooltip:ClearLines()
        GameTooltip:AddLine("ProfessionMenu")
        GameTooltip:Show()
    end
end

function minimap.OnEnter(button)
    PM:OnEnter(button)
end

function PM:ToggleMinimap()
    local hide = not self.db.minimap
    self.db.minimap = hide
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
        local spellID = self:GetRecipeData(scrollFrame.buttons[i].item.ItemEntry, "item")
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
                self:UpdateButtonText(i)
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
        self:LoadTradeskillRecipes()
		self:InitializeTextUpdate()
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