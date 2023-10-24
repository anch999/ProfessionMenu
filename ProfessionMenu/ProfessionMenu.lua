ProfessionMenu = LibStub("AceAddon-3.0"):NewAddon("ProfessionMenu", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
local PM = LibStub("AceAddon-3.0"):GetAddon("ProfessionMenu")
local addonName = ...
local professionbutton, mainframe
local dewdrop = AceLibrary("Dewdrop-2.0")
local defIcon = "Interface\\Icons\\achievement_guildperk_bountifulbags"
local icon = LibStub('LibDBIcon-1.0')
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"
local 
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
}

function PM:UNIT_SPELLCAST_SUCCEEDED(event, arg1, arg2)
	PM:RemoveItem(arg2)
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
    1777028, -- thermal anvil
}
-- deletes any mystic altars in the players inventory
function PM:RemoveItem(arg2)
	if arg2 ~= "Summon Thermal Anvil" or not PM.db.DeleteItem then return end
	for _, itemID in pairs(items) do
		local found, bag, slot = PM:HasItem(itemID)
		if found then
			PickupContainerItem(bag, slot)
			DeleteCursorItem()
		end
	end
	PM:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end


-- add altar summon button via dewdrop secure
function PM:AddItem(itemID)
	if not C_VanityCollection.IsCollectionItemOwned(itemID) then return end
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
                'textHeight', 12,
                'textWidth', 12
        )
end

--for a adding a divider to dew drop menus 
function PM:AddDividerLine(maxLenght)
    local text = WHITE.."----------------------------------------------------------------------------------------------------"
    dewdrop:AddLine(
        'text' , text:sub(1, maxLenght),
        'textHeight', 12,
        'textWidth', 12,
        'isTitle', true,
        "notCheckable", true
    )
end

--sets up the drop down menu for specs
local function ProfessionMenu_DewdropRegister(self, frame)
    dewdrop:Register(self,
        'point', function(parent)
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value)
            dewdrop:AddLine(
                'text', "|cffffff00Professions",
                'textHeight', 12,
                'textWidth', 12,
                'isTitle', true,
                'notCheckable', true
            )
            for _, prof in ipairs(profList) do
                for _, spellID in ipairs(prof) do
                    if CA_IsSpellKnown(spellID) then
                        local name, _, icon = GetSpellInfo(spellID)
                        local secure = {
                            type1 = 'spell',
                            spell = name
                            }
                        dewdrop:AddLine(
                                'text', name,
                                'icon', icon,
                                'secure', secure,
                                'closeWhenClicked', true,
                                'textHeight', 12,
                                'textWidth', 12
                        )
                    end
                end
            end
            if CA_IsSpellKnown(750750) or C_VanityCollection.IsCollectionItemOwned(1777028) then
                PM:AddDividerLine(35)
                if C_VanityCollection.IsCollectionItemOwned(1777028) then
                    PM:AddItem(1777028)
                end
                if CA_IsSpellKnown(750750) then
                    local name, _, icon = GetSpellInfo(750750)
                    local secure = {
                        type1 = 'spell',
                        spell = name
                        }
                    dewdrop:AddLine(
                            'text', name,
                            'icon', icon,
                            'secure', secure,
                            'closeWhenClicked', true,
                            'textHeight', 12,
                            'textWidth', 12
                    )
                end
            end
            PM:AddDividerLine(35)
            if frame == "ProfessionMenuFrame_Menu" then
                dewdrop:AddLine(
                    'text', "Unlock Frame",
                    'textHeight', 12,
                    'textWidth', 12,
                    'func', PM.UnlockFrame,
                    'notCheckable', true,
                    'closeWhenClicked', true
                )
            end
            dewdrop:AddLine(
				'text', "Options",
                'textHeight', 12,
                'textWidth', 12,
				'func', PM.Options_Toggle,
				'notCheckable', true,
                'closeWhenClicked', true
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
		end,
		'dontHook', true
	)
end

local function mainButton_OnClick(self, arg1)
    if dewdrop:IsOpen() then PM:OnEnter(self) dewdrop:Close() return end
    GameTooltip:Hide()
    ProfessionMenu_DewdropRegister(self, "ProfessionMenuFrame_Menu")
    dewdrop:Open(self)
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
    professionbutton:SetScript("OnClick", function(self, btnclick) mainButton_OnClick(self, btnclick) end)
    professionbutton:SetScript("OnEnter", function(self)
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
    if button == "LeftButton" then
        if dewdrop:IsOpen() then dewdrop:Close() return end
        ProfessionMenu_DewdropRegister(self)
        dewdrop:Open(self)
    end
end

function minimap.OnLeave()
    GameTooltip:Hide()
end

function PM:OnEnter(self)
    GameTooltip:SetOwner(self, 'ANCHOR_NONE')
    GameTooltip:SetPoint(GetTipAnchor(self))
    GameTooltip:ClearLines()
    GameTooltip:AddLine("ProfessionMenu")
    GameTooltip:Show()
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