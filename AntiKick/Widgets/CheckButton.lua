local AddonName, Addon = ...

local CheckButton = Addon.AntiKick

local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local GameFontDisable = GameFontDisable
local GameFontHighlight = GameFontHighlight
local GameFontNormal = GameFontNormal

function CheckButton:CreateCheckButton(parent)
	local frame = CreateFrame("CheckButton", nil, parent)
	frame:SetSize(20, 20)
	frame:SetNormalFontObject(GameFontHighlight)
	frame:SetDisabledFontObject(GameFontDisable)
	frame:SetHighlightFontObject(GameFontNormal)
	frame:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	frame:SetCheckedTexture("Interface\\Buttons\\UI-Common-MouseHilight")
	frame:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")

	frame.text = frame:CreateFontString(nil, "Overlay")
	frame.text:SetFontObject(GameFontHighlight)
	frame.text:SetJustifyH("Left")
	frame.text:SetJustifyV("Middle")
	frame.text:SetWordWrap(false)
	frame.text:SetPoint("Left", frame, "Right", 5, 0)
	frame.text:SetText("CheckButton")

	frame:SetFontString(frame.text)
	frame:SetHitRectInsets(0, -frame:GetWidth() + 5 - frame.text:GetStringWidth(), 0, 0)

	--[[hooksecurefunc(frame.text, "SetText", function(self)
		frame:SetHitRectInsets(0, -frame:GetWidth() + 5 - frame.text:GetStringWidth(), 0, 0)
	end)]]

	return frame
end

function CheckButton:CreateCheckButtonIcon(parent)
	local frame = CreateFrame("CheckButton", nil, parent)
	frame:SetSize(100, 32)
	frame:SetNormalFontObject(GameFontHighlight)
	frame:SetHighlightFontObject(GameFontNormal)
	frame:SetDisabledFontObject(GameFontNormal)

	frame.icon = frame:CreateTexture(nil, "Artwork")
	frame.icon:SetSize(24, 24)
	frame.icon:SetPoint("TopLeft", 4, -4)

	frame.text = frame:CreateFontString(nil, "Overlay")
	frame.text:SetFontObject(GameFontNormal)
	frame.text:SetPoint("TopLeft", 36, -4)
	frame.text:SetPoint("BottomRight", -4, 4)
	frame.text:SetJustifyV("Middle")
	frame.text:SetJustifyH("Left")
	frame.text:SetText("CheckButton")

	frame:SetFontString(frame.text)

	--[[hooksecurefunc(frame.text, "SetText", function(self)
		frame:SetHitRectInsets(0, -frame:GetWidth() + 5 - frame.text:GetStringWidth(), 0, 0)
	end)]]

	return frame
end
