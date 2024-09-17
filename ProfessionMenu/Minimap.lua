local PM = LibStub("AceAddon-3.0"):GetAddon("ProfessionMenu")
local icon = LibStub('LibDBIcon-1.0')


local minimap = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject("ProfessionMenu", {
    type = 'data source',
    text = "ProfessionMenu",
    icon = PM.defaultIcon
})

function minimap.OnClick(self, button)
    GameTooltip:Hide()
    if not PM.db.autoMenu then
        PM:DewdropRegister(self)
    end
end

function minimap.OnLeave()
    GameTooltip:Hide()
end

function minimap.OnEnter(button)
    PM:OnEnter(button)
end

function PM:ToggleMinimap()
    self.db.minimap = not self.db.minimap
    if self.db.minimap then
      icon:Hide('ProfessionMenu')
    else
      icon:Show('ProfessionMenu')
    end
end

function PM:InitializeMinimap()
    if icon then
        self.minimap = {hide = self.db.minimap}
        icon:Register('ProfessionMenu', minimap, self.minimap)
    end
    minimap.icon = self.defaultIcon
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