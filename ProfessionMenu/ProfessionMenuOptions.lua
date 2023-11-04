local PM = LibStub("AceAddon-3.0"):GetAddon("ProfessionMenu")

function PM:Options_Toggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide()
	else
		InterfaceOptionsFrame_OpenToCategory("ProfessionMenu")
	end
end

function PM:OpenOptions()
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	PM:DropDownInitialize()
	UIDropDownMenu_SetText(ProfessionMenuOptions_TxtSizeMenu, PM.db.txtSize)
end

--Creates the options frame and all its assets
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	local mainframe = {}
		mainframe.panel = CreateFrame("FRAME", "ProfessionMenuOptionsFrame", UIParent, nil)
    	local fstring = mainframe.panel:CreateFontString(mainframe, "OVERLAY", "GameFontNormal")
		fstring:SetText("Profession Menu Settings")
		fstring:SetPoint("TOPLEFT", 15, -15)
		mainframe.panel.name = "ProfessionMenu"
		InterfaceOptions_AddCategory(mainframe.panel)

	local hideMenu = CreateFrame("CheckButton", "ProfessionMenuOptions_HideMenu", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	hideMenu:SetPoint("TOPLEFT", 15, -60)
	hideMenu.Lable = hideMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideMenu.Lable:SetJustifyH("LEFT")
	hideMenu.Lable:SetPoint("LEFT", 30, 0)
	hideMenu.Lable:SetText("Hide Standalone Button")
	hideMenu:SetScript("OnClick", function() 
		if PM.db.HideMenu then
			ProfessionMenuFrame:Show()
			PM.db.HideMenu = false
		else
			ProfessionMenuFrame:Hide()
			PM.db.HideMenu = true
		end
	end)

	local hideHover = CreateFrame("CheckButton", "ProfessionMenuOptions_ShowOnHover", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	hideHover:SetPoint("TOPLEFT", 15, -95)
	hideHover.Lable = hideHover:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideHover.Lable:SetJustifyH("LEFT")
	hideHover.Lable:SetPoint("LEFT", 30, 0)
	hideHover.Lable:SetText("Only Show Standalone Button on Hover")
	hideHover:SetScript("OnClick", function()
		if PM.db.ShowMenuOnHover then
			ProfessionMenuFrame_Menu:Show()
            ProfessionMenuFrame.icon:Show()
			ProfessionMenuFrame.Text:Show()
			PM.db.ShowMenuOnHover = false
		else
			ProfessionMenuFrame_Menu:Hide()
            ProfessionMenuFrame.icon:Hide()
			ProfessionMenuFrame.Text:Hide()
			PM.db.ShowMenuOnHover = true
		end

	end)

	local hideMinimap = CreateFrame("CheckButton", "ProfessionMenuOptions_HideMinimap", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	hideMinimap:SetPoint("TOPLEFT", 15, -130)
	hideMinimap.Lable = hideMinimap:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideMinimap.Lable:SetJustifyH("LEFT")
	hideMinimap.Lable:SetPoint("LEFT", 30, 0)
	hideMinimap.Lable:SetText("Hide Minimap Icon")
	hideMinimap:SetScript("OnClick", function() PM:ToggleMinimap() end)

	local itemDel = CreateFrame("CheckButton", "ProfessionMenuOptions_DeleteMenu", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	itemDel:SetPoint("TOPLEFT", 15, -165)
	itemDel.Lable = itemDel:CreateFontString(nil , "BORDER", "GameFontNormal")
	itemDel.Lable:SetJustifyH("LEFT")
	itemDel.Lable:SetPoint("LEFT", 30, 0)
	itemDel.Lable:SetText("Delete vanity items after summoning")
	itemDel:SetScript("OnClick", function() PM.db.DeleteItem = not PM.db.DeleteItem end)

	local autoMenu = CreateFrame("CheckButton", "ProfessionMenuOptions_AutoMenu", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	autoMenu:SetPoint("TOPLEFT", 15, -200)
	autoMenu.Lable = autoMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	autoMenu.Lable:SetJustifyH("LEFT")
	autoMenu.Lable:SetPoint("LEFT", 30, 0)
	autoMenu.Lable:SetText("Show menu on hover")
	autoMenu:SetScript("OnClick", function() PM.db.autoMenu = not PM.db.autoMenu end)

	local hideRank = CreateFrame("CheckButton", "ProfessionMenuOptions_HideRank", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	hideRank:SetPoint("TOPLEFT", 15, -235)
	hideRank.Lable = hideRank:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideRank.Lable:SetJustifyH("LEFT")
	hideRank.Lable:SetPoint("LEFT", 30, 0)
	hideRank.Lable:SetText("Hide profession rank")
	hideRank:SetScript("OnClick", function() PM.db.hideRank = not PM.db.hideRank end)

	local hideMaxRank = CreateFrame("CheckButton", "ProfessionMenuOptions_HideMaxRank", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	hideMaxRank:SetPoint("TOPLEFT", 15, -270)
	hideMaxRank.Lable = hideMaxRank:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideMaxRank.Lable:SetJustifyH("LEFT")
	hideMaxRank.Lable:SetPoint("LEFT", 30, 0)
	hideMaxRank.Lable:SetText("Hide profession max rank")
	hideMaxRank:SetScript("OnClick", function() PM.db.hideMaxRank = not PM.db.hideMaxRank end)

	local showOldTradeUI = CreateFrame("CheckButton", "ProfessionMenuOptions_ShowOldTradeSkillUI", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	showOldTradeUI:SetPoint("TOPLEFT", 15, -305)
	showOldTradeUI.Lable = showOldTradeUI:CreateFontString(nil , "BORDER", "GameFontNormal")
	showOldTradeUI.Lable:SetJustifyH("LEFT")
	showOldTradeUI.Lable:SetPoint("LEFT", 30, 0)
	showOldTradeUI.Lable:SetText("Show old Blizzard Trade Skill UI")
	showOldTradeUI:SetScript("OnClick", function()
		PM.db.ShowOldTradeSkillUI = not PM.db.ShowOldTradeSkillUI
		if PM.db.ShowOldTradeSkillUI then
			UIParent:UnregisterEvent("TRADE_SKILL_SHOW")
			PM:RegisterEvent("TRADE_SKILL_SHOW")
		else
			PM:UnregisterEvent("TRADE_SKILL_SHOW")
			UIParent:RegisterEvent("TRADE_SKILL_SHOW")
		end
	end)

	local txtSize = CreateFrame("Button", "ProfessionMenuOptions_TxtSizeMenu", ProfessionMenuOptionsFrame, "UIDropDownMenuTemplate")
	txtSize:SetPoint("TOPLEFT", 15, -345)
	txtSize.Lable = txtSize:CreateFontString(nil , "BORDER", "GameFontNormal")
	txtSize.Lable:SetJustifyH("LEFT")
	txtSize.Lable:SetPoint("LEFT", txtSize, 190, 0)
	txtSize.Lable:SetText("Menu Text Size")

	local function options_Menu_Initialize()
		local info
		for i = 10, 25 do
					info = {
						text = i;
						func = function() 
							PM.db.txtSize = i 
							local thisID = this:GetID();
							UIDropDownMenu_SetSelectedID(ProfessionMenuOptions_TxtSizeMenu, thisID)
						end;
					};
						UIDropDownMenu_AddButton(info);
		end
	end

	function PM:DropDownInitialize()
		--Setup for Dropdown menus in the settings
		UIDropDownMenu_Initialize(ProfessionMenuOptions_TxtSizeMenu, options_Menu_Initialize)
		UIDropDownMenu_SetSelectedID(ProfessionMenuOptions_TxtSizeMenu)
		UIDropDownMenu_SetWidth(ProfessionMenuOptions_TxtSizeMenu, 150)
	end