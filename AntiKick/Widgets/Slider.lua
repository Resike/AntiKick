local AddonName, Addon = ...

local Slider = Addon.AntiKick

local tonumber = tonumber

local CreateFrame = CreateFrame
local GameFontHighlightSmall = GameFontHighlightSmall
local GameFontNormal = GameFontNormal

local InterfaceOptionsFrame = InterfaceOptionsFrame

function Slider:CreateSlider(parent)
	local frame = CreateFrame("Slider", nil, parent)
	frame:SetSize(200, 17)
	frame:EnableMouseWheel(true)
	frame:SetHitRectInsets(0, 0, -14, -15)
	frame:SetMinMaxValues(0, 100)
	frame:SetValue(50)
	frame:SetValueStep(1)
	frame:SetHitRectInsets(0, 0, 0, 0)
	frame:SetObeyStepOnDrag(true)
	frame:EnableMouseWheel(true)
	frame:SetOrientation("Horizontal")
	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
		edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
		tile = true,
		edgeSize = 8,
		tileSize = 8,
		insets = {left = 3, right = 3, top = 6, bottom = 6}
	})
	frame:SetBackdropBorderColor(0.7, 0.7, 0.7, 1.0)

	frame:SetScript("OnEnter", function(self)
		self:SetBackdropBorderColor(1, 1, 1, 1)
	end)
	frame:SetScript("OnLeave", function(self)
		self:SetBackdropBorderColor(0.7, 0.7, 0.7, 1.0)
	end)

	frame:SetScript("OnMouseWheel", function(self, delta)
		--if IsAltKeyDown() then
			if delta > 0 then
				self:SetValue(self:GetValue() + self:GetValueStep())
			else
				self:SetValue(self:GetValue() - self:GetValueStep())
			end
		--end
	end)

	frame:SetScript("OnValueChanged", function(self, value)
		frame.value:SetText(value)
	end)

	frame.min = frame:CreateFontString(nil, "Overlay")
	frame.min:SetFontObject(GameFontHighlightSmall)
	frame.min:SetSize(0, 14)
	frame.min:SetWordWrap(false)
	frame.min:SetPoint("TopLeft", frame, "BottomLeft", 0, -1)
	local min, max = frame:GetMinMaxValues()
	frame.min:SetText(min)

	frame.max = frame:CreateFontString(nil, "Overlay")
	frame.max:SetFontObject(GameFontHighlightSmall)
	frame.max:SetSize(0, 14)
	frame.max:SetWordWrap(false)
	frame.max:SetPoint("TopRight", frame, "BottomRight", 0, -1)
	frame.max:SetText(max)

	frame.title = frame:CreateFontString(nil, "Overlay")
	frame.title:SetFontObject(GameFontNormal)
	frame.title:SetSize(0, 14)
	frame.title:SetWordWrap(false)
	frame.title:SetPoint("Bottom", frame, "Top")
	frame.title:SetText("Slider")

	frame.thumb = frame:CreateTexture(nil, "Artwork")
	frame.thumb:SetSize(32, 32)
	frame.thumb:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

	frame:SetThumbTexture(frame.thumb)

	frame.value = CreateFrame("EditBox", nil, frame)
	frame.value:EnableMouseWheel(true)
	frame.value:SetAutoFocus(false)
	frame.value:SetNumeric(false)
	frame.value:SetJustifyH("Center")
	frame.value:SetFontObject(GameFontHighlightSmall)
	frame.value:SetSize(50, 14)
	frame.value:SetPoint("Top", frame, "Bottom", 0, -1)
	frame.value:SetTextInsets(4, 4, 0, 0)
	frame.value:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
		tile = true,
		edgeSize = 1,
		tileSize = 5
	})
	frame.value:SetBackdropColor(0, 0, 0, 1)
	frame.value:SetBackdropBorderColor(0.2, 0.2, 0.2, 1.0)
	frame.value:SetText(frame:GetValue())

	frame.value:SetScript("OnShow", function(self)
		self:SetText("")
		self:SetText(frame:GetValue())
	end)

	if InterfaceOptionsFrame then
		InterfaceOptionsFrame:HookScript("OnShow", function(self)
			frame.value:SetText("")
			frame.value:SetText(frame:GetValue())
		end)
	end

	frame.value:SetScript("OnEnter", function(self)
		self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1.0)
	end)
	frame.value:SetScript("OnLeave", function(self)
		self:SetBackdropBorderColor(0.2, 0.2, 0.2, 1.0)
	end)

	frame.value:SetScript("OnMouseWheel", function(self, delta)
		--if IsAltKeyDown() then
			if delta > 0 then
				frame:SetValue(frame:GetValue() + frame:GetValueStep())
			else
				frame:SetValue(frame:GetValue() - frame:GetValueStep())
			end
		--end
	end)

	frame.value:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)
	frame.value:SetScript("OnEnterPressed", function(self)
		local value = tonumber(self:GetText())
		if value then
			local min, max = frame:GetMinMaxValues()
			if value >= min and value <= max then
				frame:SetValue(value)
			elseif value < min then
				frame:SetValue(min)
			elseif value > max then
				frame:SetValue(max)
			end
			frame.value:SetText(frame:GetValue())
		else
			frame:SetValue(frame:GetValue())
		end
		self:ClearFocus()
	end)

	frame.value:SetScript("OnEditFocusLost", function(self)
		self:HighlightText(0, 0)
	end)
	frame.value:SetScript("OnEditFocusGained", function(self)
		self:HighlightText(0, -1)
	end)

	--[[frame.plus = CreateFrame("Button", nil, frame)
	frame.plus:SetSize(18, 18)
	frame.plus:RegisterForClicks("AnyUp")
	frame.plus:SetPoint("Left", frame.value, "Right", 0, 0)
	frame.plus:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
	frame.plus:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
	frame.plus:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIcon-BlinkHilight")
	frame.plus:SetScript("OnClick", function(self)
		frame:SetValue(frame:GetValue() + frame:GetValueStep())
	end)

	frame.minus = CreateFrame("Button", nil, frame)
	frame.minus:SetSize(18, 18)
	frame.minus:RegisterForClicks("AnyUp")
	frame.minus:SetPoint("Right", frame.value, "Left", 0, 0)
	frame.minus:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
	frame.minus:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
	frame.minus:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIcon-BlinkHilight")
	frame.minus:SetScript("OnClick", function(self)
		frame:SetValue(frame:GetValue() - frame:GetValueStep())
	end)]]

	return frame
end
