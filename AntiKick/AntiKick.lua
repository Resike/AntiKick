local AddonName, Addon = ...

local AntiKick = { }
Addon.AntiKick = AntiKick

local L = Addon.L

local defaultSettings = {
	["profiles"] = {
		["Default"] = {
			["Options"] = {
				["MinimumInterrupts"] = 3,
				["SuccessPercentage"] = 0.9,
				["ReactionTime"] = 100,
				["IgnorePing"] = 500,
			},
			["Casts"] = {

			},
			["Interrupts"] = {

			},
			["FlaggedPlayers"] = {

			},
		},
	},
	["profileKeys"] = {

	},
}

function AntiKick:UpgradeVariables(src, dst)
	if type(src) ~= "table" then
		return { }
	end

	if type(dst) ~= "table" then
		dst = { }
	end

	for k, v in pairs(src) do
		if type(v) == "table" then
			dst[k] = self:UpgradeVariables(v, dst[k])
		elseif type(v) ~= type(dst[k]) then
			dst[k] = v
		end
	end

	return dst
end

AntiKick.events = CreateFrame("Frame")
AntiKick.events:RegisterEvent("ADDON_LOADED")

AntiKick.events:SetScript("OnEvent", function(self, event, ...)
	--print(event)
	AntiKick[event](AntiKick, ...)
end)

function AntiKick:ADDON_LOADED(addon)
	if addon == AddonName then
		AntiKickDB = self:UpgradeVariables(defaultSettings, AntiKickDB)

		self.db = setmetatable(AntiKickDB, {__newindex = function(t, index, value)
			if type(value) == "table" then
				rawset(defaultSettings, index, value)
			end
			rawset(t, index, value)
		end})

		local name = GetUnitName("player")
		local realmName = GetRealmName()

		--local realmGUID = string.match(UnitGUID("player"), "^Player%-(%d+)")
		self.profileKey = name.." - "..realmName

		if not self.db["profileKeys"][self.profileKey] then
			self.db["profileKeys"][self.profileKey] = { }
			self.db["profileKeys"][self.profileKey]["Primary"] = "Default"
			self.db["profileKeys"][self.profileKey]["Secondary"] = "Default"
		end

		local specGroup = GetActiveSpecGroup()
		if specGroup == 1 then
			self.profile = self.db["profileKeys"][self.profileKey]["Primary"]
		elseif specGroup == 2 then
			self.profile = self.db["profileKeys"][self.profileKey]["Secondary"]
		end

		if not self.db.profiles[self.profile] then
			self.profile = "Default"
		end

		if not self.db.profiles[self.db["profileKeys"][self.profileKey]["Primary"]] then
			self.db["profileKeys"][self.profileKey]["Primary"] = "Default"
			--self.profile = "Default"
		end

		if not self.db.profiles[self.db["profileKeys"][self.profileKey]["Secondary"]] then
			self.db["profileKeys"][self.profileKey]["Secondary"] = "Default"
			--self.profile = "Default"
		end
		self.dbp = self.db.profiles[self.profile]

		self:ResetCastInfo()

		--self:ResetInterruptInfo()

		self:RegisterEvents()

		self:ReportFrameTweak()

		self.events:UnregisterEvent("ADDON_LOADED")
	end
end

function AntiKick:RegisterEvents()
	local events = {
		"COMBAT_LOG_EVENT_UNFILTERED",
		--"UNIT_SPELLCAST_START",
		--"UNIT_SPELLCAST_STOP",
		--"UNIT_SPELLCAST_SUCCEEDED",
		"UNIT_SPELLCAST_DELAYED",
		--"UNIT_SPELLCAST_FAILED",
		--"UNIT_SPELLCAST_INTERRUPTED",
		--"UNIT_SPELLCAST_CHANNEL_START",
		--"UNIT_SPELLCAST_CHANNEL_STOP",
		--"UNIT_SPELLCAST_CHANNEL_UPDATE",
		--"UNIT_SPELLCAST_CHANNEL_INTERRUPTED",
	}

	for i = 1, #events do
		local event = events[i]
		self.events:RegisterEvent(event)
	end
end

function AntiKick:ReportFrameTweak()
	ReportCheatingDialog:SetHeight(310 + 330)
	ReportCheatingDialogCommentFrame:SetHeight(100 + 330)
	ReportCheatingDialog.CommentFrame.EditBox:SetMultiLine(true)
	ReportCheatingDialog.CommentFrame.EditBox:SetMaxLetters(255 * 4)

	ReportCheatingDialog.CommentFrame.EditBox:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)

	ReportCheatingDialog.CommentFrame.EditBox:SetScript("OnTextChanged", function(self)
		if self:GetText() ~= "" then
			self:GetParent():GetParent().reportButton:Enable()
		else
			self:GetParent():GetParent().reportButton:Disable()
		end
		self:SetText(string.gsub(self:GetText(), "\n\n\n", "\n\n"))
	end)

	ReportCheatingDialog:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			self:SetMovable(true)
			self:StartMoving()
		end
	end)

	ReportCheatingDialog:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			self:StopMovingOrSizing()
			self:SetMovable(false)
		end
	end)

	ReportCheatingDialog.CommentFrame.EditBox:SetScript("OnEnterPressed", nil)

	ReportPlayerNameDialog:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			self:SetMovable(true)
			self:StartMoving()
		end
	end)

	ReportPlayerNameDialog:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			self:StopMovingOrSizing()
			self:SetMovable(false)
		end
	end)
end

function AntiKick:GetUnitFromGUID(GUID)
	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			local unit = "raid"..i
			if UnitGUID(unit) == GUID then
				return unit
			end
		end
	elseif IsInGroup() then
		if UnitGUID("player") == GUID then
			return "player"
		end

		for i = 1, GetNumGroupMembers() do
			local unit = "party"..i
			if UnitGUID(unit) == GUID then
				return unit
			end
		end
	elseif UnitGUID("player") == GUID then
		return "player"
	end
end

function AntiKick:AddCastInfo(unit, spellName, spellID, timeStamp, startTime, endTime)
	if not unit then
		return
	end

	local unitGUID = UnitGUID(unit)

	if not self.dbp["Casts"][unitGUID] then
		self.dbp["Casts"][unitGUID] = { }
	end

	local playerName
	local name, server = UnitFullName(unit)
	if server then
		playerName = name.."-"..server
	else
		playerName = name
	end

	self.dbp["Casts"][unitGUID] = {
		playerName = playerName,
		playerGUID = unitGUID,
		spellName = spellName,
		timeStamp = timeStamp,
		startCastTime = endTime - startTime,
		startTime = startTime,
		endTime = endTime,
		spellID = spellID,
	}
end

function AntiKick:UpdateCastInfo(unit, spellName, spellID, startTime, endTime)
	if not unit then
		return
	end

	local unitGUID = UnitGUID(unit)

	if not self.dbp["Casts"][unitGUID] then
		return
	end

	if self.dbp["Casts"][unitGUID].spellID == spellID then
		self.dbp["Casts"][unitGUID].endTime = endTime
	end
end

function AntiKick:RemoveCastInfo(unit, spellID)
	if not unit then
		return
	end

	local unitGUID = UnitGUID(unit)

	if self.dbp["Casts"][unitGUID] and self.dbp["Casts"][unitGUID].spellID and self.dbp["Casts"][unitGUID].spellID == spellID then
		self.dbp["Casts"][unitGUID] = nil
	end
end

function AntiKick:SaveInterruptInfo(unitGUID, casterName, spellName, spellID, interrupterName, interruptSpellName, interruptSpellID, castStart, interruptTime, castTime, reactionTime, interruptedCastPercentage)
	if not self.dbp["Interrupts"][unitGUID] then
		self.dbp["Interrupts"][unitGUID] = { }
	end

	self.dbp["Interrupts"][unitGUID][interruptTime] = {
		casterName = casterName,
		castSpellName = spellName,
		castspellID = spellID,
		interrupterName = interrupterName,
		interruptSpellName = interruptSpellName,
		interruptSpellID = interruptSpellID,
		interruptedCastPercentage = interruptedCastPercentage,
		castStart = castStart,
		interruptTime = interruptTime,
		castTime = castTime,
		reactionTime = reactionTime
	}
end

function AntiKick:ResetCastInfo()
	self.dbp["Casts"] = { }
end

function AntiKick:ResetInterruptInfo()
	self.dbp["Interrupts"] = { }
end

function AntiKick:COMBAT_LOG_EVENT_UNFILTERED(timeStamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
	if eventType == "SPELL_CAST_START" then
		if not CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_FRIENDLY_UNITS) and not CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_ME) then
			return
		end

		local spellID, spellName, spellSchool = ...

		local unit = self:GetUnitFromGUID(sourceGUID)

		if unit and not UnitIsCharmed(unit) then
			local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)

			if not name or not startTime or not endTime then
				return
			end

			self:AddCastInfo(unit, name, spellID, timeStamp, startTime, endTime)
		end
	elseif eventType == "SPELL_CAST_SUCCESS" then
		if not CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_FRIENDLY_UNITS) and not CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_ME) then
			return
		end
		local spellID, spellName, spellSchool = ...

		local unit = self:GetUnitFromGUID(sourceGUID)

		if unit and not UnitIsCharmed(unit) then
			local name, subText, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit)

			if name and startTime and endTime then
				self:AddCastInfo(unit, name, spellID, timeStamp, startTime, endTime)
			else
				self:RemoveCastInfo(unit, spellID)
			end
		end
	elseif eventType == "SPELL_CAST_FAILED" then
		if not CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_FRIENDLY_UNITS) and not CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_ME) then
			return
		end

		local spellID, spellName, spellSchool = ...

		local unit = self:GetUnitFromGUID(sourceGUID)

		self:RemoveCastInfo(unit, spellID)
	elseif eventType == "SPELL_INTERRUPT" then
		local spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool = ...

		if not self.dbp["Casts"][destGUID] then
			--print("Missing cast.")
			return
		end

		local castStart = self.dbp["Casts"][destGUID].timeStamp
		local castTime = self.dbp["Casts"][destGUID].endTime - self.dbp["Casts"][destGUID].startTime
		local reactionTime = math.floor(((timeStamp - self.dbp["Casts"][destGUID].timeStamp) * 1000) + 0.5)
		local interruptedCastPercentage = (reactionTime / castTime) * 100

		if reactionTime >= castTime then
			--print("Cast time is smaller then the raction time!", castTime, reactionTime)
			return
		end

		if castStart >= timeStamp then
			--print("Cast start time is bigger then the interrupt time!", castStart, timeStamp)
			return
		end
		print(sourceName, GetSpellLink(spellID), destName, GetSpellLink(extraSpellID), "Cast time: "..self.dbp["Casts"][destGUID].startCastTime.."ms", "Pushback time: "..castTime - self.dbp["Casts"][destGUID].startCastTime, "Delayed cast time: "..castTime.."ms", "Reaction time: "..reactionTime.."ms", "Interrupted cast percentage: "..string.format("%.2f", interruptedCastPercentage).."%")

		self:SaveInterruptInfo(sourceGUID, destName, extraSpellName, extraSpellID, sourceName, spellName, spellID, castStart, timeStamp, castTime, reactionTime, interruptedCastPercentage)

		local unit = self:GetUnitFromGUID(sourceGUID)

		self:RemoveCastInfo(unit, spellID)
	end
end

--[=[function AntiKick:UNIT_SPELLCAST_START(unit, spellName, _, cast, spellID)
	--[[local down, up, lagHome, lagWorld = GetNetStats()

	if lagWorld > self.dbp["Options"]["IgnorePing"] then
		return
	end]]

	if not UnitInParty(destName) and unit ~= "player" then
		return
	end

	local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)

	if not name or not startTime or not endTime or startTime >= endTime then
		return
	end

	--print(unit, name, spellID, startTime, endTime)
	self:AddCastInfo(unit, name, spellID, time(), startTime, endTime)

	--print("UNIT_SPELLCAST_START", unit, spellName, "["..cast.."/"..castID.."]", spellID)
end]=]

function AntiKick:UNIT_SPELLCAST_DELAYED(unit, spellName, _, cast, spellID)
	if not UnitInParty(UnitName(unit)) and unit ~= "player" then
		return
	end

	local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)

	if name and startTime and endTime then
		if unit and not UnitIsCharmed(unit) then
			--print(self.dbp["Casts"][UnitGUID(unit)].endTime - self.dbp["Casts"][UnitGUID(unit)].startTime)
			--local time = self.dbp["Casts"][UnitGUID(unit)].endTime
			self:UpdateCastInfo(unit, name, spellID, startTime, endTime)
			--print(UnitName(unit), name, "delay:", self.dbp["Casts"][UnitGUID(unit)].endTime - time, "ms")
		end
	else
		local name, subText, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit)

		if not name or not startTime or not endTime then
			return
		end

		if unit and not UnitIsCharmed(unit) then
			--print(self.dbp["Casts"][UnitGUID(unit)].endTime - self.dbp["Casts"][UnitGUID(unit)].startTime)
			--local time = self.dbp["Casts"][UnitGUID(unit)].endTime
			self:UpdateCastInfo(unit, name, spellID, startTime, endTime)
			--print(UnitName(unit), name, "delay:", self.dbp["Casts"][UnitGUID(unit)].endTime - time, "ms")
		end
	end

	--local unit = self:GetUnitFromGUID(UnitGUID(unit))

	if unit and not UnitIsCharmed(unit) then
		--print(self.dbp["Casts"][UnitGUID(unit)].endTime - self.dbp["Casts"][UnitGUID(unit)].startTime)
		--local time = self.dbp["Casts"][UnitGUID(unit)].endTime
		self:UpdateCastInfo(unit, name, spellID, startTime, endTime)
		--print(UnitName(unit), name, "delay:", self.dbp["Casts"][UnitGUID(unit)].endTime - time, "ms")
	end
end

--[[function AntiKick:UNIT_SPELLCAST_SUCCEEDED(unit, spellName, _, cast, spellID)
	--print("UNIT_SPELLCAST_SUCCEEDED", unit, spellName, castID, spellID)
	self:RemoveCastInfo(unit, spellID)
end

function AntiKick:UNIT_SPELLCAST_STOP(unit, spellName, _, cast, spellID)
	--print("UNIT_SPELLCAST_STOP", unit, spellName, castID, spellID)
	self:RemoveCastInfo(unit, spellID)
end

function AntiKick:UNIT_SPELLCAST_FAILED(unit, spellName, _, cast, spellID)
	--print("UNIT_SPELLCAST_SUCCEEDED", unit, spellName, castID, spellID)
	self:RemoveCastInfo(unit, spellID)
end

function AntiKick:UNIT_SPELLCAST_INTERRUPTED(unit, spellName, _, cast, spellID)
	self:RemoveCastInfo(unit, spellID)
	--print("UNIT_SPELLCAST_INTERRUPTED", unit, spellName, _, castID, spellID)
	--print(debugprofilestop(), GetTime(), self.dbp["Casts"][UnitGUID(unit)].spellName, self.dbp["Casts"][UnitGUID(unit)].startTime, self.dbp["Casts"][UnitGUID(unit)].endTime)
end]]

--[[ReportCheatingDialog:HookScript("OnShow", function(self, ...)
	print(self.target, ...)
end)

hooksecurefunc("HelpFrame_ShowReportCheatingDialog", function(self)
	print(self)
end)]]
