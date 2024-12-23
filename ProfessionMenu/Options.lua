local PM = LibStub("AceAddon-3.0"):GetAddon("ProfessionMenu")
local WHITE = "|cffFFFFFF"

function PM:Options_Toggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide()
	else
		InterfaceOptionsFrame_OpenToCategory("ProfessionMenu")
	end
end

--Creates the options frame and all its assets
function PM:InitializeOptionsUI()
	local Options = {
		AddonName = "ProfessionMenu",
		TitleText = "Profession Menu",
		{
		Name = "Profession Menu Settings",
		Left = {
			{
				Type = "CheckButton",
				Name = "HideMenu",
				Lable = "Hide Standalone Button",
				OnClick = 	function()
					if self.db.HideMenu then
						self.standaloneButton:Show()
						self.db.HideMenu = false
					else
						self.standaloneButton:Hide()
						self.db.HideMenu = true
					end
				end
			},
			{
				Type = "CheckButton",
				Name = "ShowMenuOnHover",
				Lable = "Only Show Standalone Button on Hover",
				OnClick = function()
					self.db.ShowMenuOnHover = not self.db.ShowMenuOnHover
					self:SetFrameAlpha()
				end
			},
			{
				Type = "CheckButton",
				Name = "autoMenu",
				Lable = "Open menu on mouse over",
				OnClick = function() self.db.autoMenu = not self.db.autoMenu end
			},
			{
				Type = "CheckButton",
				Name = "hideRank",
				Lable = "Hide profession rank",
				OnClick = function() self.db.hideRank = not self.db.hideRank end
			},
			{
				Type = "CheckButton",
				Name = "hideMaxRank",
				Lable = "Hide profession max rank",
				OnClick = function() self.db.hideMaxRank = not self.db.hideMaxRank end
			},
			{
				Type = "CheckButton",
				Name = "showHerb",
				Lable = "Show Herbalism",
				OnClick = function() self.db.showHerb = not self.db.showHerb end
			},
			{
				Type = "CheckButton",
				Name = "selfCast",
				Lable = "Cast placeable items/spells on self",
				OnClick = function() self.db.selfCast = not self.db.selfCast end
			},
			{
				Type = "CheckButton",
				Name = "ShowOldTradeSkillUI",
				Lable = "Show old Blizzard Trade Skill UI",
				OnClick = function()
					self.db.ShowOldTradeSkillUI = not self.db.ShowOldTradeSkillUI
					if self.db.ShowOldTradeSkillUI then
						UIParent:UnregisterEvent("TRADE_SKILL_SHOW")
						self:RegisterEvent("TRADE_SKILL_SHOW")
					else
						self:UnregisterEvent("TRADE_SKILL_SHOW")
						UIParent:RegisterEvent("TRADE_SKILL_SHOW")
					end
				end
			},
		},
		Right = {
			{
				Type = "CheckButton",
				Name = "DeleteItem",
				Lable = "Delete vanity items after summoning",
				OnClick = function() self.db.DeleteItem = not self.db.DeleteItem end
			},
			{
				Type = "CheckButton",
				Name = "minimap",
				Lable = "Hide minimap icon",
				OnClick = function()
					self:ToggleMinimap()
				end
			},
			{
				Type = "Menu",
				Name = "txtSize",
				Lable = "Menu text size",
				Menu = {10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25}
			},
			{
				Type = "Slider",
				Name = "buttonScale",
				Lable = "Standalone Button Scale",
				MinMax = {0.25, 1.5},
				Step = 0.01,
				Size = {240,16},
				OnShow = function() self.options.buttonScale:SetValue(self.db.buttonScale or 1) end,
				OnValueChanged = function()
					self.db.buttonScale = self.options.buttonScale:GetValue()
					if self.standaloneButton then
						self.standaloneButton:SetScale(self.db.buttonScale)
					end
				end
			}
		}
		}
	}

	self.options = self:CreateOptionsPages(Options, ProfessionMenuDB)
	self.options.discordLink = CreateFrame("Button", "ProfessionMenuOptions_DiscordLink", ProfessionMenuOptionsFrame)
	self.options.discordLink:SetPoint("BOTTOMLEFT", 15, 15)
	self.options.discordLink.Lable = self.options.discordLink:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.discordLink.Lable:SetJustifyH("LEFT")
	self.options.discordLink.Lable:SetPoint("LEFT", self.options.discordLink, 0, 0)
	self.options.discordLink.Lable:SetText("For Help or suggestions come join us on Discord\nhttps://discord.gg/j7eebTK5Q3"..WHITE.." (Click to copy link)")
	self.options.discordLink:SetScript("OnClick", function()
		Internal_CopyToClipboard("https://discord.gg/j7eebTK5Q3")
		DEFAULT_CHAT_FRAME:AddMessage("Discord link copyed to clipboard")
	end)
	self.options.discordLink:SetSize(self.options.discordLink.Lable:GetStringWidth(), self.options.discordLink.Lable:GetStringHeight())
end