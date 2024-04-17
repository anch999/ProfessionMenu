local PM = LibStub("AceAddon-3.0"):GetAddon("ProfessionMenu")

--Round number
local function round(num, idp)
	local mult = 10 ^ (idp or 0)
	return math.floor(num * mult + 0.5) / mult
 end

function PM:Options_Toggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide()
	else
		InterfaceOptionsFrame_OpenToCategory("ProfessionMenu")
	end
end

function ProfessionMenu_OpenOptions()
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	ProfessionMenu_DropDownInitialize()
	UIDropDownMenu_SetText(ProfessionMenuOptions_TxtSizeMenu, PM.db.txtSize)
end

--Creates the options frame and all its assets

function PM:CreateOptionsUI()
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	self.options = { frame = {} }
	self.options.frame.panel = CreateFrame("FRAME", "ProfessionMenuOptionsFrame", UIParent, nil)
    local fstring = self.options.frame.panel:CreateFontString(self.options.frame, "OVERLAY", "GameFontNormal")
	fstring:SetText("Profession Menu Settings")
	fstring:SetPoint("TOPLEFT", 15, -15)
	self.options.frame.panel.name = "ProfessionMenu"
	InterfaceOptions_AddCategory(self.options.frame.panel)

	self.options.hideMenu = CreateFrame("CheckButton", "ProfessionMenuOptions_HideMenu", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.hideMenu:SetPoint("TOPLEFT", 15, -60)
	self.options.hideMenu.Lable = self.options.hideMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideMenu.Lable:SetJustifyH("LEFT")
	self.options.hideMenu.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideMenu.Lable:SetText("Hide Standalone Button")
	self.options.hideMenu:SetScript("OnClick", function() 
		if self.db.HideMenu then
			ProfessionMenuFrame:Show()
			self.db.HideMenu = false
		else
			ProfessionMenuFrame:Hide()
			self.db.HideMenu = true
		end
	end)

	self.options.hideHover = CreateFrame("CheckButton", "ProfessionMenuOptions_ShowOnHover", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.hideHover:SetPoint("TOPLEFT", 15, -95)
	self.options.hideHover.Lable = self.options.hideHover:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideHover.Lable:SetJustifyH("LEFT")
	self.options.hideHover.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideHover.Lable:SetText("Only Show Standalone Button on Hover")
	self.options.hideHover:SetScript("OnClick", function()
		if self.db.ShowMenuOnHover then
			ProfessionMenuFrame_Menu:Show()
            ProfessionMenuFrame.icon:Show()
			ProfessionMenuFrame.Text:Show()
			self.db.ShowMenuOnHover = false
		else
			ProfessionMenuFrame_Menu:Hide()
            ProfessionMenuFrame.icon:Hide()
			ProfessionMenuFrame.Text:Hide()
			self.db.ShowMenuOnHover = true
		end

	end)

	self.options.hideMinimap = CreateFrame("CheckButton", "ProfessionMenuOptions_HideMinimap", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.hideMinimap:SetPoint("TOPLEFT", 15, -130)
	self.options.hideMinimap.Lable = self.options.hideMinimap:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideMinimap.Lable:SetJustifyH("LEFT")
	self.options.hideMinimap.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideMinimap.Lable:SetText("Hide Minimap Icon")
	self.options.hideMinimap:SetScript("OnClick", function() self:ToggleMinimap() end)

	self.options.itemDel = CreateFrame("CheckButton", "ProfessionMenuOptions_DeleteMenu", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.itemDel:SetPoint("TOPLEFT", 15, -165)
	self.options.itemDel.Lable = self.options.itemDel:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.itemDel.Lable:SetJustifyH("LEFT")
	self.options.itemDel.Lable:SetPoint("LEFT", 30, 0)
	self.options.itemDel.Lable:SetText("Delete vanity items after summoning")
	self.options.itemDel:SetScript("OnClick", function() self.db.DeleteItem = not self.db.DeleteItem end)

	self.options.autoMenu = CreateFrame("CheckButton", "ProfessionMenuOptions_AutoMenu", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.autoMenu:SetPoint("TOPLEFT", 15, -200)
	self.options.autoMenu.Lable = self.options.autoMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.autoMenu.Lable:SetJustifyH("LEFT")
	self.options.autoMenu.Lable:SetPoint("LEFT", 30, 0)
	self.options.autoMenu.Lable:SetText("Show menu on hover")
	self.options.autoMenu:SetScript("OnClick", function() self.db.autoMenu = not self.db.autoMenu end)

	self.options.hideRank = CreateFrame("CheckButton", "ProfessionMenuOptions_HideRank", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.hideRank:SetPoint("TOPLEFT", 15, -235)
	self.options.hideRank.Lable = self.options.hideRank:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideRank.Lable:SetJustifyH("LEFT")
	self.options.hideRank.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideRank.Lable:SetText("Hide profession rank")
	self.options.hideRank:SetScript("OnClick", function() self.db.hideRank = not self.db.hideRank end)

	self.options.hideMaxRank = CreateFrame("CheckButton", "ProfessionMenuOptions_HideMaxRank", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.hideMaxRank:SetPoint("TOPLEFT", 15, -270)
	self.options.hideMaxRank.Lable = self.options.hideMaxRank:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideMaxRank.Lable:SetJustifyH("LEFT")
	self.options.hideMaxRank.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideMaxRank.Lable:SetText("Hide profession max rank")
	self.options.hideMaxRank:SetScript("OnClick", function() self.db.hideMaxRank = not self.db.hideMaxRank end)

	self.options.showHerb = CreateFrame("CheckButton", "ProfessionMenuOptions_ShowHerb", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.showHerb:SetPoint("TOPLEFT", 15, -305)
	self.options.showHerb.Lable = self.options.showHerb:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.showHerb.Lable:SetJustifyH("LEFT")
	self.options.showHerb.Lable:SetPoint("LEFT", 30, 0)
	self.options.showHerb.Lable:SetText("Show Herbalism")
	self.options.showHerb:SetScript("OnClick", function() self.db.showHerb = not self.db.showHerb end)

	self.options.showOldTradeUI = CreateFrame("CheckButton", "ProfessionMenuOptions_ShowOldTradeSkillUI", ProfessionMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.showOldTradeUI:SetPoint("TOPLEFT", 15, -335)
	self.options.showOldTradeUI.Lable = self.options.showOldTradeUI:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.showOldTradeUI.Lable:SetJustifyH("LEFT")
	self.options.showOldTradeUI.Lable:SetPoint("LEFT", 30, 0)
	self.options.showOldTradeUI.Lable:SetText("Show old Blizzard Trade Skill UI")
	self.options.showOldTradeUI:SetScript("OnClick", function()
		self.db.ShowOldTradeSkillUI = not self.db.ShowOldTradeSkillUI
		if self.db.ShowOldTradeSkillUI then
			UIParent:UnregisterEvent("TRADE_SKILL_SHOW")
			self:RegisterEvent("TRADE_SKILL_SHOW")
		else
			self:UnregisterEvent("TRADE_SKILL_SHOW")
			UIParent:RegisterEvent("TRADE_SKILL_SHOW")
		end
	end)

	self.options.txtSize = CreateFrame("Button", "ProfessionMenuOptions_TxtSizeMenu", ProfessionMenuOptionsFrame, "UIDropDownMenuTemplate")
	self.options.txtSize:SetPoint("TOPLEFT", 15, -370)
	self.options.txtSize.Lable = self.options.txtSize:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.txtSize.Lable:SetJustifyH("LEFT")
	self.options.txtSize.Lable:SetPoint("LEFT", self.options.txtSize, 190, 0)
	self.options.txtSize.Lable:SetText("Menu Text Size")

	self.options.buttonScale = CreateFrame("Slider", "ProfessionMenuOptionsButtonScale", ProfessionMenuOptionsFrame,"OptionsSliderTemplate")
	self.options.buttonScale:SetSize(240,16)
	self.options.buttonScale:SetPoint("TOPLEFT", 360,-60)
	self.options.buttonScale:SetMinMaxValues(0.25, 1.5)
	_G[self.options.buttonScale:GetName().."Text"]:SetText("Standalone Button Scale: ".." ("..round(self.options.buttonScale:GetValue(),2)..")")
	_G[self.options.buttonScale:GetName().."Low"]:SetText(0.25)
	_G[self.options.buttonScale:GetName().."High"]:SetText(1.5)
	self.options.buttonScale:SetValueStep(0.01)
	self.options.buttonScale:SetScript("OnShow", function() self.options.buttonScale:SetValue(self.db.buttonScale or 1) end)
    self.options.buttonScale:SetScript("OnValueChanged", function()
		_G[self.options.buttonScale:GetName().."Text"]:SetText("Standalone Button Scale: ".." ("..round(self.options.buttonScale:GetValue(),2)..")")
        self.db.buttonScale = self.options.buttonScale:GetValue()
		if ProfessionMenuFrame then
        	ProfessionMenuFrame:SetScale(self.db.buttonScale)
		end
    end)
end

PM:CreateOptionsUI()

	function ProfessionMenu_Options_Menu_Initialize()
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

	function ProfessionMenu_DropDownInitialize()
		--Setup for Dropdown menus in the settings
		UIDropDownMenu_Initialize(ProfessionMenuOptions_TxtSizeMenu, ProfessionMenu_Options_Menu_Initialize )
		UIDropDownMenu_SetSelectedID(ProfessionMenuOptions_TxtSizeMenu)
		UIDropDownMenu_SetWidth(ProfessionMenuOptions_TxtSizeMenu, 150)
	end