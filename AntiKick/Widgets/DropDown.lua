local AddonName, Addon = ...

local DropDown = Addon.AntiKick

local table = table
local tinsert = tinsert
local type = type

local CreateFrame = CreateFrame
local GameFontDisable = GameFontDisable
local GameFontHighlight = GameFontHighlight
local GameFontHighlightSmall = GameFontHighlightSmall
local GameFontNormal = GameFontNormal

local DropDowns = { }

local function OnListEnter(self)
	self.menu:SetBackdropBorderColor(0.5, 0.5, 0.5, 1.0)
	self.text:SetVertexColor(1, 0.82, 0)
end

local function OnListLeave(self)
	self.menu:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
	self.text:SetVertexColor(1, 1, 1)
end

local function Fire(self, event, ...)
	return type(self[event]) == "function" and self[event](self, ...)
end

local function CloseDropDowns()
	for i = 1, #DropDowns do
		if DropDowns[i].menu:IsShown() then
			DropDowns[i].menu:Hide()
		end
	end
end

hooksecurefunc("CloseDropDownMenus", CloseDropDowns)
hooksecurefunc("ToggleDropDownMenu", CloseDropDowns)

function DropDown:CreateDropDown(parent, list, sorted)
	local frame = CreateFrame("Button", nil, parent)
	frame:SetSize(200, 26)
	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\White8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 14,
		insets = {left = 2, right = 2, top = 2, bottom = 2}
	})
	frame:SetBackdropColor(0, 0, 0, 1)
	frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
	frame:SetHitRectInsets(0, 0, 0, 0)

	frame:SetScript("OnEnter", function(self)
		self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1.0)
	end)
	frame:SetScript("OnLeave", function(self)
		self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
	end)

	frame:SetScript("OnShow", function(self)
		frame.menu:Hide()
	end)

	frame.list = list

	if sorted then
		table.sort(frame.list)
		frame.Sorted = true
	end

	frame.menu = CreateFrame("Frame", nil, frame)
	frame.menu:SetPoint("TopLeft", frame, "BottomLeft", 0, 2)
	frame.menu:SetSize(frame:GetWidth(), 20 * #frame.list + 10)
	frame.menu:SetBackdrop({
		bgFile = "Interface\\Buttons\\White8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 14,
		insets = {left = 2, right = 2, top = 2, bottom = 2}
	})
	frame.menu:SetBackdropColor(0, 0, 0, 1)
	frame.menu:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)

	frame.menu:SetScript("OnEnter", function(self)
		self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1.0)
	end)
	frame.menu:SetScript("OnLeave", function(self)
		self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
	end)

	--[[frame.menu:SetScript("OnShow", function(self)
		frame:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up")
		frame:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Disabled")
		frame:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down")
	end)
	frame.menu:SetScript("OnHide", function(self, button)
		frame:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
		frame:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
		frame:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	end)]]

	tinsert(DropDowns, frame)

	frame.menu:Hide()

	frame.title = frame:CreateFontString(nil, "Overlay")
	frame.title:SetFontObject(GameFontNormal)
	frame.title:SetJustifyV("Middle")
	frame.title:SetJustifyH("Left")
	frame.title:SetWordWrap(false)
	frame.title:SetSize(100, 20)
	frame.title:SetPoint("BottomLeft", frame, "TopLeft", 3, 0)
	frame.title:SetPoint("BottomRight", frame, "TopRight", -3, 0)

	frame.text = frame:CreateFontString(nil, "Overlay")
	frame.text:SetFontObject(GameFontHighlightSmall)
	frame.text:SetJustifyH("Left")
	frame.text:SetJustifyV("Middle")
	frame.text:SetWordWrap(false)
	frame.text:SetPoint("TOPLEFT", 8, -2)
	frame.text:SetPoint("BottomRight", -28, 2)
	frame:SetFontString(frame.text)

	local t = frame:CreateTexture(nil, "Artwork")
	t:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
	t:SetPoint("TopRight")
	t:SetPoint("BottomRight")
	t:SetSize(26, 26)
	frame:SetNormalTexture(t)

	local t = frame:CreateTexture(nil, "Artwork")
	t:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
	t:SetPoint("TopRight")
	t:SetPoint("BottomRight")
	t:SetSize(26, 26)
	frame:SetDisabledTexture(t)

	local t = frame:CreateTexture(nil, "Artwork")
	t:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	t:SetPoint("TopRight")
	t:SetPoint("BottomRight")
	t:SetSize(26, 26)
	frame:SetPushedTexture(t)

	local t = frame:CreateTexture(nil, "Artwork")
	t:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-BlinkHilight")
	t:SetBlendMode("ADD")
	t:SetPoint("TopRight")
	t:SetPoint("BottomRight")
	t:SetSize(26, 26)
	frame:SetHighlightTexture(t)

	if #frame.list == 0 then
		frame:Disable()
		frame.text:SetFontObject(GameFontDisable)
	end

	frame:SetScript("OnClick", function(self, button)
		if button == "LeftButton" then
			local isShown = frame.menu:IsShown()
			CloseDropDowns()
			if #frame.list > 0 then
				if isShown then
					frame.menu:Hide()
				else
					frame.menu:Show()
				end
			end
		end
	end)

	function frame:RefreshList(newlist)
		for i = 1, #frame.list do
			frame.menu[i]:Hide()
			frame.menu[i] = nil
		end

		frame.list = newlist

		if #frame.list == 0 then
			frame:Disable()
			frame.text:SetFontObject(GameFontDisable)
		else
			frame:Enable()
			frame.text:SetFontObject(GameFontHighlightSmall)
		end

		if frame.Sorted then
			table.sort(frame.list)
		end

		frame.menu:SetHeight(20 * #frame.list + 10)

		frame:CreateList()
	end

	function frame:CreateList()
		for i = 1, #self.list do
			self.menu[i] = CreateFrame("CheckButton", nil, self.menu)

			if i == 1 then
				self.menu[i]:SetPoint("TopLeft", self.menu, "TopLeft", 5, -5)
			else
				self.menu[i]:SetPoint("TopLeft", self.menu[i - 1], "BottomLeft", 0, 0)
			end

			self.menu[i]:SetSize(20, 20)
			self.menu[i]:SetHitRectInsets(0, -self:GetWidth() + 10 + self.menu[i]:GetWidth(), 0, 0)
			self.menu[i]:SetNormalFontObject(GameFontHighlightSmall)
			self.menu[i]:SetDisabledFontObject(GameFontDisable)
			self.menu[i]:SetHighlightFontObject(GameFontHighlightSmall)
			self.menu[i]:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
			self.menu[i]:SetCheckedTexture("Interface\\Buttons\\UI-Common-MouseHilight")
			self.menu[i]:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")

			self.menu[i].text = self.menu[i]:CreateFontString(nil, "Overlay")
			self.menu[i].text:SetFontObject(GameFontHighlightSmall)
			self.menu[i].text:SetJustifyH("Left")
			self.menu[i].text:SetJustifyV("Middle")
			self.menu[i].text:SetWordWrap(false)
			self.menu[i].text:SetPoint("Left", self.menu[i], "Right", 5, 0)
			self.menu[i].text:SetText(self.list[i])

			self.menu[i]:SetFontString(self.menu[i].text)

			self.menu[i].menu = self.menu

			self.menu[i]:SetScript("OnEnter", OnListEnter)
			self.menu[i]:SetScript("OnLeave", OnListLeave)

			self.menu[i]:SetScript("OnClick", function(self, button)
				if button == "LeftButton" then
					for j = 1, #frame.menu do
						local k = frame.menu[j]
						if k ~= self then
							k:SetChecked(false)
						else
							if not self:GetChecked() then
								self:SetChecked(true)
							end
						end
					end

					frame.selected = frame.list[i]
					frame.text:SetText(frame.selected)

					frame.Fire = Fire
					frame:Fire("OnValueChanged", i, frame.selected)

					frame.menu:Hide()
				end
			end)
		end
	end

	frame:CreateList()

	function frame:GetSelected()
		return self.selected
	end

	function frame:SetSelected(value)
		self.selected = value

		for i = 1, #self.list do
			if self.list[i] == value then
				self.menu[i]:SetChecked(true)
			else
				self.menu[i]:SetChecked(false)
			end
		end

		if value then
			self.text:SetText(value)
		else
			self.text:SetText("")
		end
	end

	return frame
end
