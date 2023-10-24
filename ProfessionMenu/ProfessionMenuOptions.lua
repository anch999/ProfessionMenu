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
	hideMenu.Lable:SetText("Hide Main Menu")
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
	hideHover.Lable:SetText("Only Show Menu on Hover")
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
	itemDel:SetPoint("TOPLEFT", 15, -160)
	itemDel.Lable = itemDel:CreateFontString(nil , "BORDER", "GameFontNormal")
	itemDel.Lable:SetJustifyH("LEFT")
	itemDel.Lable:SetPoint("LEFT", 30, 0)
	itemDel.Lable:SetText("Delete anvil after summoning")
	itemDel:SetScript("OnClick", function() PM.db.DeleteItem = not PM.db.DeleteItem end)

