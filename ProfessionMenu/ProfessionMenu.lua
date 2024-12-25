local PM = LibStub("AceAddon-3.0"):NewAddon("ProfessionMenu", "AceTimer-3.0", "AceEvent-3.0", "SettingsCreator-1.0")
PROFESSIONMENU = PM
PM.defaultIcon = "Interface\\Icons\\achievement_guildperk_bountifulbags"
PM.dewdrop = LibStub("Dewdrop-2.0")
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"

--Set Savedvariables defaults
local DefaultSettings  = {
    ShowMenuOnHover = { false },
    HideMenu = { false },
    DeleteItem = { false },
    minimap = { false },
    txtSize = { 12 },
    autoMenu = { false },
    FilterList = { {false,false,false,false,false} },
    BagFilter = { {false,false,false,false,false} },
    ItemBlacklist = { { [9149] = true }},
    hideMaxRank = { false },
    hideRank = { false },
    showHerb = { false },
    ShowOldTradeSkillUI = { false },
    selfCast = { false },
    Gold = { 55000 },
    GoldFilter = { false }
}

function PM:OnInitialize()
    self.db = self:SetupDB("ProfessionMenuDB", DefaultSettings)
    --Enable the use of /PM or /PROFESSIONMENU to open the loot browser
    SLASH_PROFESSIONMENU1 = "/PROFESSIONMENU"
    SLASH_PROFESSIONMENU2 = "/PM"
    SlashCmdList["PROFESSIONMENU"] = function(msg)
        PM:SlashCommand(msg)
    end
end

function PM:OnEnable()
    self:InitializeOptionsUI()
    self:InitializeMinimap()
    self:InitializeStandaloneButton()
    self:InitializeInventoryUI()
    if self.db.ShowOldTradeSkillUI then
        UIParent:UnregisterEvent("TRADE_SKILL_SHOW")
        self:RegisterEvent("TRADE_SKILL_SHOW")
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
        self:OnInitialize()
        DEFAULT_CHAT_FRAME:AddMessage("Settings Reset")
    elseif msg == "options" then
        self:Options_Toggle()
    elseif msg == "macromenu" then
        self:DewdropRegister(GetMouseFocus(), nil, true)
    else
        self:ToggleMainFrame()
    end
end

function PM:UNIT_SPELLCAST_SUCCEEDED(event, arg1, arg2)
    if arg2 == "Pick Lock" and self.InventoryFrame:IsVisible() and self.InventoryFrame.profession == "Lockpicking" then
        Timer.After(.2, function() self:SearchBagsLockboxs() end)
    end
	self:RemoveItem(arg2)
end

function PM:TRADE_SKILL_SHOW()
    TradeSkillFrame_LoadUI()
	if TradeSkillFrame_Show then
		TradeSkillFrame_Show()
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