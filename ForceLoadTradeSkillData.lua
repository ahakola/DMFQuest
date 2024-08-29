--[[----------------------------------------------------------------------------
	Accessing tradeskill levels without the UI
	By p3lim on 2023.04.25 17:11 UTC
	https://github.com/Stanzilla/WoWUIBugs/issues/424

	In the good old days we could simply request skill levels for the player's
	profession(s) using GetNumSkillLines() and GetSkillLineInfo(index), and is
	still the current method on classic realms.

	The way to get this information now is by iterating over
	C_TradeSkillUI.GetAllProfessionTradeSkillLines() and using
	C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineID) to get the skill
	levels.

	However this requires the tradeskill data to be valid, otherwise the skill
	level values are all 0. To validate this data we need to call
	C_TradeSkillUI.OpenTradeSkill(skillLineID), which requires a hardware event
	and is disruptive as it force shows the tradeskill UI.

	Once C_TradeSkillUI.OpenTradeSkill() has been called atleast once per
	character session, the player can freely unlearn every profession and learn
	something else, even /reload the game, and the data is still valid for all 
	current and future professions. This means there's a flag being set, per
	character session.

	My proposal is one of the following, in order of most preferable first:

	1.	let C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineID) request
		the data by itself
	2.	implement C_TradeSkillUI.RequestData(), which would validify this data
		without requiring a hardware event, and without being disruptive (e.g.
		it would trigger a different event than TRADE_SKILL_SHOW)
	3.	add an optional argument to the existing API, e.g.
		C_TradeSkillUI.OpenTradeSkill(skillLineID[, dontOpen]), passing the new
		arg as a parameter to the TRADE_SKILL_SHOW event, which the UIParent
		event handler should respect (and addons would have to too, which is why
		this is least preferable)

	----------------------------------------------------------------------------

	https://github.com/Stanzilla/WoWUIBugs/issues/424#issuecomment-1522140660
	My current workaround, which anyone is free to copy:
----------------------------------------------------------------------------]]--

-- in case other addons copies this, make sure it never loads multiple times unless there is a
-- newer version of it, in which case we disable it and load anyways
local version = 4
if _G['ForceLoadTradeSkillData'] then
	if _G['ForceLoadTradeSkillData'].version < version then
		_G['ForceLoadTradeSkillData']:UnregisterAllEvents()
	else
		return
	end
end

local hack = CreateFrame('Frame', 'ForceLoadTradeSkillData')
hack.version = version
hack:SetPropagateKeyboardInput(true) -- make sure we don't own the keyboard
hack:RegisterEvent('PLAYER_LOGIN')
hack:SetScript('OnEvent', function(self, event)
	if event == 'PLAYER_LOGIN' or event == 'SKILL_LINES_CHANGED' then
		self:UnregisterEvent(event)

		local professionID = self:GetAnyProfessionID()
		if not professionID then
			-- player has no professions, wait for them to learn one
			self:RegisterEvent('SKILL_LINES_CHANGED')
		elseif not self:HasProfessionData(professionID) then
			-- player has profession but the session has no data, listen for key event
			self.professionID = professionID
			self:SetScript('OnKeyDown', self.OnKeyDown)
		end
	elseif event == 'TRADE_SKILL_SHOW' then
		if not (C_TradeSkillUI.IsTradeSkillLinked() or C_TradeSkillUI.IsTradeSkillGuild()) then
			-- we've triggered the tradeskill UI, close it again and bail out
			C_TradeSkillUI.CloseTradeSkill()
			self:UnregisterEvent(event)
			UIParent:RegisterEvent(event)

			-- unmute sounds
			UnmuteSoundFile(SOUNDKIT.UI_PROFESSIONS_WINDOW_OPEN)
			UnmuteSoundFile(SOUNDKIT.UI_PROFESSIONS_WINDOW_CLOSE)
		end
	end
end)

function hack:OnKeyDown()
	-- unregister ourselves first to avoid duplicate queries
	self:SetScript('OnKeyDown', nil)

	-- be silent
	MuteSoundFile(SOUNDKIT.UI_PROFESSIONS_WINDOW_OPEN)
	MuteSoundFile(SOUNDKIT.UI_PROFESSIONS_WINDOW_CLOSE)

	-- listen for tradeskill UI opening then query it
	UIParent:UnregisterEvent('TRADE_SKILL_SHOW')
	self:RegisterEvent('TRADE_SKILL_SHOW')
	C_TradeSkillUI.OpenTradeSkill(self.professionID)
end

function hack:GetAnyProfessionID()
	-- any profession except archaeology is valid for requesting data
	for index, professionIndex in next, {GetProfessions()} do
		if index ~= 3 and professionIndex then
			local _, _, _, _, _, _, professionID = GetProfessionInfo(professionIndex)
			if professionID then
				return professionID
			end
		end
	end
end

function hack:HasProfessionData(professionID)
	local skillInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(professionID)
	return skillInfo and skillInfo.maxSkillLevel and skillInfo.maxSkillLevel > 0
end

--[[
-- in case other addons copies this, make sure it never loads multiple times unless there is a
-- newer version of it, in which case we disable it and load anyways
local version = 1
if _G['ForceLoadTradeSkillData'] then
	if _G['ForceLoadTradeSkillData'].version < version then
		_G['ForceLoadTradeSkillData']:UnregisterAllEvents()
	else
		return
	end
end

local hack = CreateFrame('Frame', 'ForceLoadTradeSkillData')
hack.version = version
hack:SetPropagateKeyboardInput(true) -- make sure we don't own the keyboard
hack:RegisterEvent('PLAYER_LOGIN')
hack:SetScript('OnEvent', function(self, event)
	if event == 'PLAYER_LOGIN' then
		local professionID = self:GetAnyProfessionID()
		if not professionID then
			-- player has no professions, wait for them to learn one
			self:RegisterEvent('SKILL_LINES_CHANGED')
		elseif not self:HasProfessionData(professionID) then
			-- player has profession but the session has no data, listen for key event
			self.professionID = professionID
			self:SetScript('OnKeyDown', self.OnKeyDown)
		end
	elseif event == 'TRADE_SKILL_SHOW' then
		if not (C_TradeSkillUI.IsTradeSkillLinked() or C_TradeSkillUI.IsTradeSkillGuild()) then
			-- we've triggered the tradeskill UI, close it again and bail out
			C_TradeSkillUI.CloseTradeSkill()
			self:UnregisterEvent(event)
		end
	elseif event == 'SKILL_LINES_CHANGED' then
		if self:GetAnyProfessionID() then
			-- player has learned a profession, listen for key event
			self:SetScript('OnKeyDown', self.OnKeyDown)
			self:UnregisterEvent(event)
		end
	end
end)

function hack:OnKeyDown()
	-- unregister ourselves first to avoid duplicate queries
	self:SetScript('OnKeyDown', nil)

	-- listen for tradeskill UI opening then query it
	self:RegisterEvent('TRADE_SKILL_SHOW')
	C_TradeSkillUI.OpenTradeSkill(self.professionID)
end

function hack:GetAnyProfessionID()
	-- any profession except archaeology is valid for requesting data
	for index, professionIndex in next, {GetProfessions()} do
		if index ~= 3 and professionIndex then
			local _, _, _, _, _, _, professionID = GetProfessionInfo(professionIndex)
			if professionID then
				return professionID
			end
		end
	end
end

function hack:HasProfessionData(professionID)
	local skillInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(professionID)
	return skillInfo and skillInfo.maxSkillLevel and skillInfo.maxSkillLevel > 0
end
]]