-------------------------------------------------------------------------------
-- DMFQuest
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
local L = ns.L -- Localization table
local B = ns.B -- Localized Zone Names table

local db, firstRunDone, pinIt, ticker, panel
local skillCap = PROFESSION_RANKS[#PROFESSION_RANKS][1] or 75
local hx = 0.36846119165421
local hy = 0.35865038633347

local f = CreateFrame("Frame", ADDON_NAME.."Frame", _G.UIParent)
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")

local turnInItems = { -- Quests and Quest items
	[29443] = 71635, --Imbued Crystal
	[29464] = 71716, --Soothsayer's Runes
	[29446] = 71638, --Ornate Weapon
	[29451] = 71715, --A Treatise on Strategy
	[29444] = 71636, --Monstrous Egg
	[29445] = 71637, --Mysterious Grimoire
	[29457] = 71952, --Captured Insignia
	[29456] = 71951, --Banner of the Fallen
	[29458] = 71953, --Fallen Adventurer's Journal
	[33354] = 105891 -- Moonfang's Pelt
}

local ProfIDs = {
	[794] = { -- Archaeology
				["quest"] = 29507,
				["currency"] = {
					[393] = 15 -- Fossil Archaeology Fragment
				}
			},
	[171] = { -- Alchemy
				["quest"] = 29506,
				["items"] = {
					[1645] = 5, -- Moonberry Juice
					[19299] = 5 -- Fizzy Faire Drink
				}
			},
	[164] = { -- Blacksmithing
				["quest"] = 29508
			},
	[185] = { -- Cooking
				["quest"] = 29509,
				["items"] = {
					[30817] = 5 -- Simple Flour
				}
			},
	[333] = { -- Enchanting
				["quest"] = 29510
			},
	[202] = { -- Engineering
				["quest"] = 29511
			},
	[129] = { -- FirstAid
				["quest"] = 29512
			},
	[356] = { -- Fishing
				["quest"] = 29513
			},
	[182] = { -- Herbalism
				["quest"] = 29514
			},
	[773] = { -- Inscription
				["quest"] = 29515,
				["items"] = {
					[39354] = 5 -- Light Parchment
				}
			},
	[755] = { -- Jewelcrafting
				["quest"] = 29516
			},
	[165] = { -- Leatherworking
				["quest"] = 29517,
				["items"] = {
					[6529] = 10, -- Shiny Bauble
					[2320] = 5, -- Coarse Thread
					[6260] = 5 -- Blue Dye
				}
			},
	[186] = { -- Mining
				["quest"] = 29518
			},
	[393] = { -- Skinning
				["quest"] = 29519
			},
	[197] = { -- Tailoring
				["quest"] = 29520,
				["items"] = {
					[2320] = 1, -- Coarse Thread
					[6260] = 1, -- Blue Dye
					[2604] = 1 -- Red Dye
				}
			}
}

local PRIMARY, SECONDARY, ARCHAEOLOGY, FISHING, COOKING, FIRSTAID = 1, 2, 3, 4, 5, 6
local ProfData = {
	[PRIMARY] = {},
	[SECONDARY] = {},
	[ARCHAEOLOGY] = {},
	[FISHING] = {},
	[COOKING] = {},
	[FIRSTAID] = {}
}


-------------------------------------------------------------------------------
-- DMFQuest Debug
-------------------------------------------------------------------------------
--@debug@
local DEBUG = true
--@end-debug@

local function Debug(text, ...)
	if text then
		if text:match("%%[dfqsx%d%.]") then
			(DEBUG_CHAT_FRAME or ChatFrame3):AddMessage("|cffff9999"..ADDON_NAME..":|r " .. format(text, ...))
		else
			(DEBUG_CHAT_FRAME or ChatFrame3):AddMessage("|cffff9999"..ADDON_NAME..":|r " .. strjoin(" ", text, tostringall(...)))
		end
	end
end

function f:Print(text, ...)
	if text then
		if text:match("%%[dfqs%d%.]") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00".. ADDON_NAME ..":|r " .. format(text, ...))
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00".. ADDON_NAME ..":|r " .. strjoin(" ", text, tostringall(...)))
		end
	end
end


-------------------------------------------------------------------------------
-- DMFQuest Functions
-------------------------------------------------------------------------------
function f:CreateUI() -- Creates UI elements
	local function _buttonFactory() -- Create Item Buttons
		local button = CreateFrame("Button", nil, f)
		button:SetSize(32, 32)

		button:SetScript("OnEnter", function(self)
			self.texture:SetVertexColor(0.75, 0.75, 0.75)
		end)

		button:SetScript("OnLeave", function(self)
			self.texture:SetVertexColor(1, 1, 1)
		end)

		local icon = button:CreateTexture()
		icon:SetAllPoints()
		button.texture = icon

		return button
	end

	local buttonCount = 0
	for _ in pairs(turnInItems) do
		buttonCount = buttonCount + 1
	end

	local frameWidth = (buttonCount * 32) or 320
	self:SetSize(frameWidth, 140)
	--self:SetPoint("CENTER", _G.UIParent, "CENTER")
	self:SetPoint("BOTTOMLEFT", _G.UIParent, db.XPos, db.YPos)
	self:SetFrameStrata("DIALOG")
	self:EnableMouse(true)
	self:SetMovable(true)

	local title_bg = self:CreateTexture(nil, "BACKGROUND")
	title_bg:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-Title-Background]])
	title_bg:SetPoint("TOPLEFT")
	title_bg:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", 0, -20)

	local dialog_bg = self:CreateTexture(nil, "BACKGROUND")
	dialog_bg:SetTexture([[Interface\Tooltips\UI-Tooltip-Background]])
	dialog_bg:SetVertexColor(0, 0, 0, 0.75)
	dialog_bg:SetPoint("TOPLEFT", 0, -20)
	dialog_bg:SetPoint("BOTTOMRIGHT")

	local title = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOPLEFT", 32, -5)
	title:SetPoint("TOPRIGHT", -32, -5)
	title:SetText(ADDON_NAME)

	self.title = title

	local drag_frame = CreateFrame("Frame", nil, f)
	drag_frame:SetPoint("TOPLEFT", title)
	drag_frame:SetPoint("BOTTOMRIGHT", title)
	drag_frame:EnableMouse(true)

	drag_frame:SetScript("OnMouseDown", function(self, button)
		f:StartMoving()
	end)

	drag_frame:SetScript("OnMouseUp", function(self, button)
		f:StopMovingOrSizing()

		local x, y = f:GetLeft(), f:GetBottom()

		db.XPos = x -- Save these to settings DB
		db.YPos = y

		f:ClearAllPoints()
		f:SetPoint("BOTTOMLEFT", db.XPos, db.YPos) -- Make sure the frame is relative to BOTTOMLEFT

		if InterfaceOptionsFrame:IsShown() then
			panel.Refresh()
		end
	end)

	local close_button = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close_button:SetSize(32, 32)
	close_button:SetPoint("TOPRIGHT", 6, 6)

	self.Strings = self.Strings or {}
	self.Lines = self.Lines or {}
	for i = 1, 10 do -- 7th is for Pet Battles, 8th is for Death Metal Knight and 9th is for Test Your Strenght and 10 is for Faded Treasure Map
		self.Strings[i] = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		if i == 1 then
			self.Strings[i]:SetPoint("TOP", f, "TOP", 0, -22)
		else
			self.Strings[i]:SetPoint("TOP", self.Strings[i-1], "BOTTOM", 0, -4)
		end
		self.Strings[i]:SetText(i)

		self.Lines[i] = self:CreateTexture()
		self.Lines[i]:SetColorTexture(0.75, 0.75, 0.75, 0.5)
		self.Lines[i]:SetSize(250, 1.2) -- (250, 1) for real, but hax to fix case where sometimes the scaling makes one of the lines disappear...
		self.Lines[i]:SetPoint("BOTTOM", self.Strings[i], 0, -2)
	end

	self.Buttons = self.Buttons or {}
	for i = 1, buttonCount do
		self.Buttons[i] = _buttonFactory()
		if i == 1 then
			self.Buttons[i]:SetPoint("BOTTOMLEFT")
		else
			self.Buttons[i]:SetPoint("LEFT", self.Buttons[i-1], "RIGHT")
		end
		self.Buttons[i].texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	end

	f:Hide()

	self.CreateUI = nil
end

function f:CheckDB() -- Check SavedVariables are okay and if not, replace them with defaults
	if type(DMFQConfig) ~= "table" then DMFQConfig = {} end
	if type(DMFQConfig.items) ~= "table" then DMFQConfig.items = {} end
	if type(DMFQConfig.XPos) ~= "number" then DMFQConfig.XPos = 275 end
	if type(DMFQConfig.YPos) ~= "number" then DMFQConfig.YPos = 275 end
	if type(DMFQConfig.AutoBuy) ~= "boolean" then DMFQConfig.AutoBuy = true end
	if type(DMFQConfig.HideLow) ~= "boolean" then DMFQConfig.HideLow = false end
	if type(DMFQConfig.PetBattle) ~= "boolean" then DMFQConfig.PetBattle = false end
	if type(DMFQConfig.HideMax) ~= "boolean" then DMFQConfig.HideMax = false end
	if type(DMFQConfig.ShowItemRewards) ~= "boolean" then DMFQConfig.ShowItemRewards = false end
	if type(DMFQConfig.UseTimeOffset) ~= "boolean" then DMFQConfig.UseTimeOffset = false end
end

function f:CheckDMF() -- Check if DMF is available
	local timeData = C_DateAndTime.GetCurrentCalendarTime() -- C_Calendar.GetDate()
	local hour, day, month, year = timeData.hour, timeData.monthDay, timeData.month, timeData.year
	local result, openMonth, openYear
	if CalendarFrame and CalendarFrame:IsShown() then -- Get current open month in calendar view
		--openMonth, openYear = CalendarGetMonth()
		local monthInfo = C_Calendar.GetMonthInfo()
		openMonth, openYear = monthInfo.month, monthInfo.year
	end

	if db.UseTimeOffset then -- Try to fix OC-servers timeoffset for the starting time.
		local daysInMonth = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
		local realmHours, realmMinutes = GetGameTime()
		local localTime = date('*t')
		local serverTimeOffset = realmHours - localTime.hour
		if timeData.monthDay > localTime.day then
			serverTimeOffset = serverTimeOffset + 24
		elseif timeData.monthDay < localTime.day then
			serverTimeOffset = serverTimeOffset - 24
		end

		hour = hour - serverTimeOffset
		if DEBUG then Debug("- Time offset:", serverTimeOffset) end -- Debug

		-- Check if we went to another date with the offset
		if hour < 0 then
			day = day - 1
			hour = hour + 24
		elseif hour > 23 then
			day = day + 1
			hour = hour - 24
		end
		if day <= 0 then
			month = month - 1
			day = daysInMonth[month] or 31
		elseif (daysInMonth[month] and day > daysInMonth[month]) then
			month = month + 1
			day = 1
		end
		if month <= 0 then
			year = year - 1
			month = 12
		elseif month > 12 then
			year = year + 1
			month = 1
		end
	end

	if not month then
		if DEBUG then Debug("- No C_DateAndTime data") end -- Debug
		return false
	end

	C_Calendar.SetAbsMonth(month, year)
	if DEBUG then day = 8 end -- Debug

	for i = 1, C_Calendar.GetNumDayEvents(0, day) do
		local holidayData = C_Calendar.GetHolidayInfo(0, day, i)
		local texture = holidayData.texture
		--if texture == "calendar_darkmoonfaireterokkar" then
		if texture == 235448 or texture == 235447 or texture == 235446 then -- DMF begin, go on, end
			--return true
			result = true
			break
		end
	end

	if openMonth and openYear then -- Restore previously open month in calendar view
		C_Calendar.SetAbsMonth(openMonth, openYear)
	end

	--return false
	return result
end

local errorCount = 0
function f:CheckPortalZone() -- Check if Player is near the DMF Portal or nearby Shopping area
	local function distance(x, y, px, py) -- Calculate the distance between point A and point B
		local dist = sqrt((x*100-px*100)^2+(y*100-py*100)^2) or 0
		dist = math.floor(dist+0.5)
		return dist
	end

	local function tickerCallback() -- Use this callback to get self to CheckPortalZone when fired by ticker
		if DEBUG then Debug("-- Tick Tock End", errorCount, ticker, ticker["_cancelled"]) end -- Debug
		ticker:Cancel()

		if errorCount < 12 then -- If we have tried 12 times (once every 5secs for 1min), then give up
			f:CheckPortalZone()
		end
	end

	--local px, py = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player"):GetXY()
	local uiMapID = C_Map.GetBestMapForUnit("player")
	local px, py = 0, 0
	if not uiMapID or type(uiMapID) ~= "number" then
		if (type(ticker) == "table" and ticker["_cancelled"]) or ticker == nil then -- Throttle starting new timers
			errorCount = errorCount + 1
			ticker = C_Timer.NewTicker(5, tickerCallback)
			if DEBUG then Debug("-- Tick Tock Start", errorCount, ticker, ticker["_cancelled"]) end -- Debug
		end
	else
		errorCount = 0
		local map = C_Map.GetPlayerMapPosition(uiMapID, "player")
		if map then
			px, py = map:GetXY()
		end
	end
	--[[local px, py

	if WorldMapFrame:IsShown() then
		local viewing = GetCurrentMapAreaID()
		SetMapToCurrentZone()
		px, py = GetPlayerMapPosition("player")
		SetMapByID(viewing)
	else
		SetMapToCurrentZone()
		px, py = GetPlayerMapPosition("player")
	end]]

	if self:CheckDMF() then
		self.title:SetText(format("%s - %s%s|r", ADDON_NAME, GREEN_FONT_COLOR_CODE, L.DMFAvailable))
	else
		self.title:SetText(format("%s", ADDON_NAME))
	end

	if pinIt then
		f.title:SetText(format("%s - %s", f.title:GetText(), L.Pinned))
	end

	if UnitFactionGroup("player") == "Alliance" then
		if (GetRealZoneText() == B["Elwynn Forest"] and GetSubZoneText() == B["Goldshire"]) or
			(GetRealZoneText() == B["Elwynn Forest"] and GetSubZoneText() == B["Lion's Pride Inn"]) or
			(GetRealZoneText() == B["Lion's Pride Inn"] and GetSubZoneText() == "") then
			-- @ Portal Zone or shopping near
			if DEBUG then Debug("-- Alliance @ Zone") end -- Debug
			errorCount = 0

			if self:CheckDMF() then -- @ Zone and DMF available
				eventFrame:RegisterEvent("BAG_UPDATE")
				eventFrame:RegisterEvent("QUEST_ACCEPTED")
				eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
				eventFrame:RegisterEvent("MERCHANT_SHOW")
				eventFrame:RegisterEvent("MERCHANT_UPDATE")
				eventFrame:RegisterEvent("MERCHANT_FILTER_ITEM_UPDATE")
				eventFrame:RegisterEvent("QUEST_DETAIL")

				self:UpdateItems()
				self:UpdateQuests()

				if not self:IsShown() then
					self:Show()
				end
			end

			return true
		else -- Not @ Zone
			if self:IsShown() and not pinIt then -- If showing, hide
				eventFrame:UnregisterEvent("BAG_UPDATE")
				eventFrame:UnregisterEvent("QUEST_ACCEPTED")
				eventFrame:UnregisterEvent("QUEST_LOG_UPDATE")
				--eventFrame:UnregisterEvent("MERCHANT_SHOW")
				eventFrame:UnregisterEvent("QUEST_DETAIL")

				self:Hide()
			end

			return false
		end
	elseif UnitFactionGroup("player") == "Horde" then
		if (GetRealZoneText() == B["Mulgore"] and GetSubZoneText() == "" and distance(hx, hy, px, py) <= 5) or
			(GetRealZoneText() == B["Thunder Bluff"] and GetSubZoneText() == B["Thunder Bluff"]) or
			(GetRealZoneText() == B["Thunder Bluff"] and GetSubZoneText() == B["The Cat and the Shaman"]) or
			(GetRealZoneText() == B["The Cat and the Shaman"] and GetSubZoneText() == "") then
			-- @ Portal Zone or shopping near
			if DEBUG then Debug("-- Horde @ Zone", distance(hx, hy, px, py)) end -- Debug
			errorCount = 0

			if (type(ticker) == "table" and ticker["_cancelled"]) or ticker == nil then
				if DEBUG then Debug("- Start Ticker by Portal") end -- Debug

				ticker = C_Timer.NewTicker(5, tickerCallback)
			end

			if self:CheckDMF() then -- @ Zone and DMF available
				eventFrame:RegisterEvent("BAG_UPDATE")
				eventFrame:RegisterEvent("QUEST_ACCEPTED")
				eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
				eventFrame:RegisterEvent("MERCHANT_SHOW")
				eventFrame:RegisterEvent("MERCHANT_UPDATE")
				eventFrame:RegisterEvent("MERCHANT_FILTER_ITEM_UPDATE")
				eventFrame:RegisterEvent("QUEST_DETAIL")

				self:UpdateItems()
				self:UpdateQuests()

				if not self:IsShown() then
					self:Show()
				end
			end

			return true
		elseif (GetRealZoneText() == B["Mulgore"] and GetSubZoneText() == "") then
			-- Not @ Portal Zone, but might be close?
			if DEBUG then Debug("-- Horde !@ Zone", distance(hx, hy, px, py)) end -- Debug

			if (type(ticker) == "table" and ticker["_cancelled"]) or ticker == nil then
				if DEBUG then Debug("- Start Ticker by Zone") end -- Debug

				ticker = C_Timer.NewTicker(5, tickerCallback)
			end

			if self:IsShown() and not pinIt then -- If showing, hide
				eventFrame:UnregisterEvent("BAG_UPDATE")
				eventFrame:UnregisterEvent("QUEST_ACCEPTED")
				eventFrame:UnregisterEvent("QUEST_LOG_UPDATE")
				--eventFrame:UnregisterEvent("MERCHANT_SHOW")
				eventFrame:UnregisterEvent("QUEST_DETAIL")

				self:Hide()
			end

			return false
		else -- Not even close
			if type(ticker) == "table" and not ticker["_cancelled"] then
				if DEBUG then Debug("- Cancel Ticker by Zone") end -- Debug

				ticker:Cancel()
			end

			if self:IsShown() and not pinIt then -- If showing, hide
				eventFrame:UnregisterEvent("BAG_UPDATE")
				eventFrame:UnregisterEvent("QUEST_ACCEPTED")
				eventFrame:UnregisterEvent("QUEST_LOG_UPDATE")
				--eventFrame:UnregisterEvent("MERCHANT_SHOW")
				eventFrame:UnregisterEvent("QUEST_DETAIL")

				self:Hide()
			end

			return false
		end
	end

	return false -- For those Unfactioned Pandaren
end

local ticketName
function f:UpdateItems() -- Keep track of turnInItems
	local function findQuest(id) --Is Player on Quest?
		--[[
		local i = 1
		while GetQuestLogTitle(i) do
			local _, _, _, _, _, _, _, questID = GetQuestLogTitle(i)
			if questID == id then
				return true
			end
			i = i + 1
		end

		return false
		]]
		return C_QuestLog.IsOnQuest(id)
	end

	local function getSlot(id) --Returns location of an item in your backbags
		local bag, slot = 0, 0
		for bag = 0, NUM_BAG_SLOTS do
			for slot = 1, GetContainerNumSlots(bag) do
				if GetContainerItemID(bag, slot) == id then
					return bag, slot
				end
			end
		end
	end

	rewardsTable = {
		[71635] = 10, --Imbued Crystal
		[71636] = 10, --Monstrous Egg
		[71637] = 10, --Mysterious Grimoire
		[71638] = 10, --Ornate Weapon
		[71715] = 15, --A Treatise on Strategy
		[71716] = 10, --Soothsayer's Runes
		[71951] = 5, --Banner of the Fallen
		[71952] = 5, --Captured Insignia
		[71953] = 5, --Fallen Adventurer's Journal
		[105891] = 10 -- Moonfang's Pelt
	}
	local function showTip(frame, normalText, newbieText) -- Show Newbie Tooltip
		--GameTooltip_AddNewbieTip(frame, normalText, 1, 1, 1, newbieText);
		-- GameTooltip_AddNewbieTip deprecated in 8.2.5
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
		if db.ShowItemRewards then
			local count = newbieText ~= nil and rewardsTable[newbieText] or "?"
			GameTooltip_SetTitle(GameTooltip, normalText .. "\n\n" .. GARRISON_MISSION_REWARD_HEADER .. " |T134481:16:16:0:0:32:32:2:30:2:30|t " .. count .. " " .. ticketName)
		else
			GameTooltip_SetTitle(GameTooltip, normalText)
		end
	end

	local function hideTip() -- Hide Newbie Tooltip
		GameTooltip:Hide();
	end

	if (not self) or self.CreateUI ~= nil then return end -- Don't go further too early to avoid errors

	if not ticketName then
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(515) -- Darkmoon Prize Ticket
		ticketName = currencyInfo.name
	end

	local i = 1
	for questID, itemID in pairs(turnInItems) do
		if questID and itemID then
			self.Buttons[i].texture:SetTexture(GetItemIcon(itemID) or 134400) -- itemIcon or ?-icon

			if C_QuestLog.IsQuestFlaggedCompleted(questID) then -- Quest done
				self.Buttons[i]:SetScript("OnClick", function(self) return end)
				self.Buttons[i]:SetScript("OnEnter", function(self)
					self.texture:SetVertexColor(0.75, 1, 0.75)
					showTip(self, L.QuestDone)
				end)
				self.Buttons[i]:SetScript("OnLeave", function(self)
					self.texture:SetVertexColor(0, 1, 0)
					hideTip()
				end)
				self.Buttons[i].texture:SetVertexColor(0, 1, 0)
			elseif findQuest(questID) then -- On quest
				self.Buttons[i]:SetScript("OnClick", function(self) return end)
				self.Buttons[i]:SetScript("OnEnter", function(self)
					self.texture:SetVertexColor(0.75, 1, 1)
					showTip(self, L.QuestReady, itemID)
					end)
				self.Buttons[i]:SetScript("OnLeave", function(self)
					self.texture:SetVertexColor(0, 1, 1)
					hideTip()
				end)
				self.Buttons[i].texture:SetVertexColor(0, 1, 1)
			elseif GetItemCount(itemID) == 0 then -- No item
				self.Buttons[i]:SetScript("OnClick", function(self) return end)
				self.Buttons[i]:SetScript("OnEnter", function(self)
					self.texture:SetVertexColor(0.75, 0.75, 0.75)
					--showTip(self, L.QuestNoItem)
					local link = ITEM_QUALITY_COLORS[3].hex.."["..f:GetItemName(itemID).."]|r" -- Rare Blue Color [Item name]
					showTip(self, format(L.QuestNoItem, link), itemID)
				end)
				self.Buttons[i]:SetScript("OnLeave", function(self)
					self.texture:SetVertexColor(0.3, 0.3, 0.3)
					hideTip()
				end)
				self.Buttons[i].texture:SetVertexColor(0.3, 0.3, 0.3)
			else -- Item, no quest
				self.Buttons[i]:SetScript("OnClick", function(self)
					if not InCombatLockdown() then
						UseContainerItem(getSlot(itemID))
					end
				end)
				self.Buttons[i]:SetScript("OnEnter", function(self)
					self.texture:SetVertexColor(0.75, 0.75, 0.75)
					showTip(self, L.QuestReadyToAccept, itemID)
				end)
				self.Buttons[i]:SetScript("OnLeave", function(self)
					self.texture:SetVertexColor(1, 1, 1)
				end)
				self.Buttons[i].texture:SetVertexColor(1, 1, 1)
			end
		end

		i = i + 1
	end

	if DEBUG then Debug("- Update Items") end -- Debug
end

function f:UpdateProfession(which, id) -- Keep track of Player Professions
	local profession = ProfData[which]

	if id then
		-- The player knows this profession!
		local name, icon, skillLevel, maxSkillLevel, _, _, skillLine = GetProfessionInfo(id)

		-- Update the profession data
		profession.name = name
		profession.icon = icon
		profession.skillLevel = skillLevel
		profession.maxSkillLevel = maxSkillLevel
		profession.id = skillLine
	else
		-- The player does not know this profession.
		-- Clear the profession data
		profession.name = nil
		profession.icon = nil
		profession.skillLevel = nil
		profession.maxSkillLevel = nil
		profession.id = nil
	end

	if DEBUG then Debug("- Update Profession:", which, profession.name) end -- Debug
end

function f:UpdateQuests() -- Keep track of Professions Quests status and item counts
	local function Resize()
		local height = 20 + 32 + 2 -- Title, Buttons, Top Marginal

		for i = 1, #self.Strings do
			if self.Strings[i]:GetText() ~= nil then
				height = height + self.Strings[i]:GetHeight() + 4 -- String + Marginal
			end
		end

		height = floor(height + 0.5)

		if height < floor(20 + 32 + 4 + self.Strings[1]:GetHeight()) then -- Title, Buttons, Marginals and String 1
			height = floor(20 + 32 + 4 + self.Strings[1]:GetHeight())
		end

		f:SetHeight(height)

		f:ClearAllPoints()
		f:SetPoint("BOTTOMLEFT", db.XPos, db.YPos)

		if DEBUG then Debug("-- Set Height:", height) end -- Debug
	end

	if (not self) or self.CreateUI ~= nil then return end -- https://www.curseforge.com/wow/addons/dmfquest?comment=48

	for i = 1, #ProfData do
		local profession = ProfData[i]

		if profession.id then -- Profession
			local questData = ProfIDs[profession.id]

			self.Lines[i]:Show()

			if db.HideMax and profession.skillLevel == profession.maxSkillLevel then -- Hide maxed professions
				self.Strings[i]:SetText(nil)
				self.Lines[i]:Hide()
			elseif C_QuestLog.IsQuestFlaggedCompleted(questData.quest) then -- Quest done
				self.Strings[i]:SetText(format("|T%s:0|t %s - %d/%d\n%s%s|r", profession.icon, profession.name, profession.skillLevel, profession.maxSkillLevel, GREEN_FONT_COLOR_CODE, L.QuestDone))
			--elseif profession.skillLevel >= 75 then -- Quest not done, enough skill to do one
			elseif profession.skillLevel >= 1 then -- Quest not done, enough skill to do one
				if (profession.maxSkillLevel - profession.skillLevel) < 5 and profession.maxSkillLevel < skillCap then -- Danger to waste skillpoints by capping
					self.Strings[i]:SetText(format("|T%s:0|t %s - %s%d/%d|r", profession.icon, profession.name, ORANGE_FONT_COLOR_CODE, profession.skillLevel, profession.maxSkillLevel))
				else -- No need to worry about capping skill
					self.Strings[i]:SetText(format("|T%s:0|t %s - %d/%d", profession.icon, profession.name, profession.skillLevel, profession.maxSkillLevel))
				end

				if profession.id == 794 then
					for id, amount in pairs(questData.currency) do
						--local name, current = GetCurrencyInfo(id)
						local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(id)
						--[[
							name					string
							isHeader				boolean
							isHeaderExpanded		boolean
							isTypeUnused			boolean
							isShowInBackpack		boolean
							quantity				number
							iconFileID				number
							maxQuantity				number
							canEarnPerWeek			boolean
							quantityEarnedThisWeek	number
							isTradeable				boolean
							quality					ItemQuality
							maxWeeklyQuantity		number
							discovered				boolean
						]]
					
						--if current < amount then
						if currencyInfo.quantity < amount then
							--self.Strings[i]:SetText(format("%s\n%s %s%d/%d|r", self.Strings[i]:GetText(), name, RED_FONT_COLOR_CODE, current, amount))
							self.Strings[i]:SetText(format("%s\n%s %s%d/%d|r", self.Strings[i]:GetText(), currencyInfo.name, RED_FONT_COLOR_CODE, currencyInfo.quantity, amount))
						else
							--self.Strings[i]:SetText(format("%s\n%s %s%d/%d|r", self.Strings[i]:GetText(), name, GREEN_FONT_COLOR_CODE, current, amount))
							self.Strings[i]:SetText(format("%s\n%s %s%d/%d|r", self.Strings[i]:GetText(), currencyInfo.name, GREEN_FONT_COLOR_CODE, currencyInfo.quantity, amount))
						end
					end
				elseif questData.items and next(questData.items) then
					for id, amount in pairs(questData.items) do
						local name = self:GetItemName(id)
						local current = GetItemCount(id)

						if name then
							if current < amount then
								self.Strings[i]:SetText(format("%s\n%s %s%d/%d|r", self.Strings[i]:GetText(), name, RED_FONT_COLOR_CODE, current, amount))
							else
								self.Strings[i]:SetText(format("%s\n%s %s%d/%d|r", self.Strings[i]:GetText(), name, GREEN_FONT_COLOR_CODE, current, amount))
							end
						else -- Fired before everything is cached, try again later
							if DEBUG then Debug("-- No GetItemInfo, rebouncing:", id) end -- Debug

							C_Timer.After(2, self.UpdateQuests)
							return nil
						end
					end
				else
					self.Strings[i]:SetText(format("%s\n%s%s|r", self.Strings[i]:GetText(), GREEN_FONT_COLOR_CODE, L.NoItemsNeeded))
				end
			else -- Skill under 75
				if db.HideLow then
					self.Strings[i]:SetText(nil)
					self.Lines[i]:Hide()
				else
					self.Strings[i]:SetText(format("|T%s:0|t %s - %s%d/%d|r\n%s%s|r", profession.icon, profession.name, RED_FONT_COLOR_CODE, profession.skillLevel, profession.maxSkillLevel, RED_FONT_COLOR_CODE, L.SkillTooLow))
				end
			end

		else -- No profession
			self.Strings[i]:SetText(nil)
			self.Lines[i]:Hide()
		end
	end

	if db.PetBattle then
		self.Strings[7]:Show()
		self.Lines[7]:Show()
		local PetBattleIcon = 631719 -- 319458
		local PBQuest1Done = C_QuestLog.IsQuestFlaggedCompleted(32175) -- Jeremy Feasel - Darkmoon Pet Battle!
		local PBQuest2Done = C_QuestLog.IsQuestFlaggedCompleted(36471) -- Christoph VonFeasel - A New Darkmoon Challenger!
		local PBQuestCounter = 0
		if PBQuest1Done then PBQuestCounter = PBQuestCounter + 1 end
		if PBQuest2Done then PBQuestCounter = PBQuestCounter + 1 end
		self.Strings[7]:SetFormattedText("|T%s:0|t %s\n%s%d/2|r %s", PetBattleIcon, SHOW_PET_BATTLES_ON_MAP_TEXT, PBQuestCounter == 2 and GREEN_FONT_COLOR_CODE or PBQuestCounter == 1 and ORANGE_FONT_COLOR_CODE or RED_FONT_COLOR_CODE, PBQuestCounter, string.format(L.PetBattlesDone, SHOW_PET_BATTLES_ON_MAP_TEXT, L.Done))
	else
		self.Strings[7]:SetText(nil)
		self.Lines[7]:Hide()
	end

	if db.DeathMetalKnight then
		self.Strings[8]:Show()
		self.Lines[8]:Show()
		local DeathMetalKnightIcon = 236362
		local DMKQuestDone = C_QuestLog.IsQuestFlaggedCompleted(47767) -- Death Metal Knight
		self.Strings[8]:SetFormattedText("|T%s:0|t %s\n%s%s|r", DeathMetalKnightIcon, L.DeathMetalKnight, DMKQuestDone and GREEN_FONT_COLOR_CODE or RED_FONT_COLOR_CODE, DMKQuestDone and L.QuestDone or L.QuestNotDone)
	else
		self.Strings[8]:SetText(nil)
		self.Lines[8]:Hide()
	end

	if db.TestYourStrength then
		self.Strings[9]:Show()
		self.Lines[9]:Show()
		local TestYourStrengthIcon = 136101
		local TYSQuestDone = C_QuestLog.IsQuestFlaggedCompleted(29433) -- Test Your Strenght
		local TYSProgress, _, _, TYSCount, TYSCap = GetQuestObjectiveInfo(29433, 1, false)

		self.Strings[9]:SetFormattedText("|T%s:0|t %s\n%s%s|r", TestYourStrengthIcon, L.TestYourStrength, TYSQuestDone and GREEN_FONT_COLOR_CODE or TYSCount == TYSCap and ORANGE_FONT_COLOR_CODE or RED_FONT_COLOR_CODE, TYSQuestDone and L.QuestDone or TYSProgress or L.QuestNotDone)
	else
		self.Strings[9]:SetText(nil)
		self.Lines[9]:Hide()
	end

	if db.FadedTreasureMap then
		self.Strings[10]:Show()
		self.Lines[10]:Show()
		local FadedTreasureMapIcon = 237388
		local FTMName = self:GetItemName(126930) or "n/a"
		local FTMQuestDone = C_QuestLog.IsQuestFlaggedCompleted(38934) -- Silas' Secret Stash
		self.Strings[10]:SetFormattedText("|T%s:0|t %s\n%s%s|r", FadedTreasureMapIcon, FTMName, FTMQuestDone and GREEN_FONT_COLOR_CODE or RED_FONT_COLOR_CODE, FTMQuestDone and L.QuestDone or L.QuestNotDone)
	else
		self.Strings[10]:SetText(nil)
		self.Lines[10]:Hide()
	end

	if self.Strings[1]:GetText() == nil and self.Strings[2]:GetText() == nil and self.Strings[3]:GetText() == nil and
	self.Strings[4]:GetText() == nil and self.Strings[5]:GetText() == nil and self.Strings[6]:GetText() == nil then
		self.Strings[1]:SetText(format("%s%s|r", RED_FONT_COLOR_CODE, L.NoProfessions))
	end

	for i = 2, #self.Strings do -- First one should be always filled, anchor others to previous filled String
		local j = i - 1
		while j > 0 do
			if self.Strings[j]:GetText() ~= nil then -- Found previous String with text, attach to it and break while-loop
				self.Strings[i]:SetPoint("TOP", self.Strings[j], "BOTTOM", 0, -4)
				break
			end
			j = j - 1
		end
	end

	if DEBUG then Debug("- Update Quests") end -- Debug

	Resize()
end

function f:BuyItems() -- Automaticly buy quest items for players professions
	local function getID(itemLink)
		local id = tonumber(strmatch(itemLink, "item:(%d+)"))

		return id
	end

	if not db.AutoBuy then return end

	if DEBUG then Debug("- Buy Items") end

	local totalCost = 0

	for i = 1, #ProfData do
		local profession = ProfData[i]

		--if profession.id and profession.id ~= 794 and profession.skillLevel >= 75 then
		if profession.id and profession.id ~= 794 and profession.skillLevel >= 1 then
			-- Profession is found (and enough skill) but it is not Archaeology (they use currency instead of item)

			local questData = ProfIDs[profession.id]

			--if not C_QuestLog.IsQuestFlaggedCompleted(questData.quest) and questData.items and next(questData.items) then
			if not C_QuestLog.IsQuestFlaggedCompleted(questData.quest) and questData.items and type(questData.items) == "table" then
				-- Profession quest not completed and requires items

				for id, amount in pairs(questData.items) do
					local needed = amount - GetItemCount(id)

					for j = 1, GetMerchantNumItems() do
						local maxStack = GetMerchantItemMaxStack(j)
						local iName, _, price, stackSize, numAvailable = GetMerchantItemInfo(j)
						local link = GetMerchantItemLink(j)

						if DEBUG and link == nil then Debug("- nil link %d %s", tonumber(j), tostring(iName)) end

						if link and getID(link) == id then -- Found item we need, buying it

							if numAvailable ~= -1 then -- -1 -> infinite amount available
								needed = math.min(needed, numAvailable)
							end

							-- If we need more than maxStack, buy maxStack if available and can afford it
							while needed > maxStack and (numAvailable >= maxStack or numAvailable == -1) and GetMoney() >= (price/stackSize * maxStack) do
								BuyMerchantItem(j, floor(maxStack))
								needed = needed - maxStack

								totalCost = totalCost + (price/stackSize * maxStack)

								self:Print(L.AutoBuy, maxStack, self:GetItemName(id))
							end

							-- Buy what we need if available and can afford it
							if needed > 0 and (numAvailable >= needed or numAvailable == -1) and GetMoney() >= (price/stackSize * needed) then
								BuyMerchantItem(j, floor(needed))

								totalCost = totalCost + (price/stackSize * needed)

								self:Print(L.AutoBuy, needed, self:GetItemName(id))
							end
						end
					end
				end
			end
		end
	end

	if totalCost > 0 then -- Total
		self:Print("- - - - - - - - - - - - - - -")
		self:Print(L.Total, GetCoinText(totalCost," "))
	end
end

function f:GetItemName(id, force) -- Returns items name from db if available, if not try to get it from server
	if db.items[id] and db.items[id] ~= nil and not force then
		return db.items[id]
	else -- Item not in local DB or forced cache
		local name = GetItemInfo(id)

		if name then
			db.items[id] = name
			return name
		end

		return nil
	end
end

SLASH_DMFQUEST1 = "/dmfquest"
SLASH_DMFQUEST2 = "/dmfq"

SlashCmdList.DMFQUEST = function(arg)
	local arg = arg:trim()
	if arg and arg ~= "" then -- arg
		if arg == "config" then
			if not InterfaceOptionsFrame:IsShown() then
				-- Open Config
				f:Print(L.OpenConfig)
				InterfaceOptionsFrame_OpenToCategory(ADDON_NAME)
			end
		elseif arg == "pin" then
			-- Change Pin status
			pinIt = not pinIt
			f:Print(L.PinningChanged, pinIt)
			f:CheckPortalZone()

			if not f:IsShown() then -- Show Frame if not visible
				f:Show()
			end
		elseif arg == "resetdb" then
			-- Reset DB and reload UI
			wipe(db)
			ReloadUI()
		elseif arg == "offset" then
			local timeData = C_DateAndTime.GetCurrentCalendarTime()
			local realmHours, realmMinutes = GetGameTime()
			local localTime = date('*t')
			local serverTimeOffset = realmHours - localTime.hour
			if timeData.monthDay > localTime.day then
				serverTimeOffset = serverTimeOffset + 24
			elseif timeData.monthDay < localTime.day then
				serverTimeOffset = serverTimeOffset - 24
			end

			f:Print("Time offset:", serverTimeOffset < 0 and serverTimeOffset or "+"..serverTimeOffset, tostring(db.UseTimeOffset))
		elseif arg == "checkzone" then
			local check = f:CheckPortalZone()
			f:Print("Zone Check:", tostring(check))
		else
			-- Error
			f:Print(L.Syntax)
		end
	else -- No arg
		if f:IsShown() then
			eventFrame:UnregisterEvent("BAG_UPDATE")
			eventFrame:UnregisterEvent("QUEST_ACCEPTED")
			eventFrame:UnregisterEvent("QUEST_LOG_UPDATE")
			--eventFrame:UnregisterEvent("MERCHANT_SHOW")

			f:Hide()
			f:Print(L.Hiding)
			pinIt = false
		else
			eventFrame:RegisterEvent("BAG_UPDATE")
			eventFrame:RegisterEvent("QUEST_ACCEPTED")
			eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
			eventFrame:RegisterEvent("MERCHANT_SHOW")
			eventFrame:RegisterEvent("MERCHANT_UPDATE")
			eventFrame:RegisterEvent("MERCHANT_FILTER_ITEM_UPDATE")

			f:Show()
			f:Print(L.Showing)
			--pinIt = true
		end
	end
end


-------------------------------------------------------------------------------
-- DMFQuest Event Handler
-------------------------------------------------------------------------------
eventFrame:SetScript("OnEvent", function(self, event, ...)
	if DEBUG and self[event] then Debug(event, ...) end -- Debug

	return self[event] and self[event](self, event, ...)
end)

function eventFrame:ADDON_LOADED(_, addon)
	if addon ~= ADDON_NAME then return end
	self:UnregisterEvent("ADDON_LOADED")

	f:CheckDB()

	db = DMFQConfig

	if IsLoggedIn() then
		self:RegisterEvent("SKILL_LINES_CHANGED") -- This is fired before PLAYER_LOGIN so it has to be Registered here
		self:SKILL_LINES_CHANGED()
		self:PLAYER_LOGIN()
	else
		self:RegisterEvent("SKILL_LINES_CHANGED") -- This is fired before PLAYER_LOGIN so it has to be Registered here
		self:RegisterEvent("PLAYER_LOGIN")
	end

	self.ADDON_LOADED = nil
end

function eventFrame:PLAYER_LOGIN()
	self:UnregisterEvent("PLAYER_LOGIN")

	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("ZONE_CHANGED_INDOORS")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("QUEST_LOG_UPDATE") -- Will fire after reload ui or on normal login

	-- Check DB items and try to Pre-cache these if not found
	local _ = f:GetItemName(1645, true) -- Moonberry Juice
	_ = f:GetItemName(30817, true) -- Simple Flour
	_ = f:GetItemName(39354, true) -- Light Parchment
	_ = f:GetItemName(6529, true) -- Shiny Bauble
	_ = f:GetItemName(2320, true) -- Coarse Thread
	_ = f:GetItemName(6260, true) -- Blue Dye
	_ = f:GetItemName(2604, true) -- Red Dye
	_ = f:GetItemName(126930, true) -- Faded Treasure Map

	for _, itemID in pairs(turnInItems) do
		_ = f:GetItemName(itemID)
	end

	f:CreateUI()

	if db.XPos or db.YPos then
		f:ClearAllPoints()
		f:SetPoint("BOTTOMLEFT", db.XPos, db.YPos)
	end

	self.PLAYER_LOGIN = nil
end

do -- CheckPortalZone throttling
	local throttling

	local function DelayedUpdate()
		throttling = nil

		f:CheckPortalZone()
	end

	local function ThrottleUpdate()
		if not throttling then
			if DEBUG then Debug("- Throttling Check Portal Zone...") end -- Debug

			C_Timer.After(0.5, DelayedUpdate)
			throttling = true
		end
	end

	eventFrame.ZONE_CHANGED_NEW_AREA = ThrottleUpdate
	eventFrame.ZONE_CHANGED = ThrottleUpdate
	eventFrame.ZONE_CHANGED_INDOORS = ThrottleUpdate
	eventFrame.PLAYER_ENTERING_WORLD = ThrottleUpdate
end

do -- UpdateItems and UpdateQuests throttling
	local throttling

	local function DelayedUpdateItems()
		throttling = nil

		f:UpdateItems()
		f:UpdateQuests()
	end

	local function ThrottleUpdateItems()
		if not throttling then
			if DEBUG then Debug("- Throttling Items and Quests Update...") end -- Debug

			C_Timer.After(0.5, DelayedUpdateItems)
			throttling = true
		end
	end

	eventFrame.BAG_UPDATE = ThrottleUpdateItems
	eventFrame.QUEST_ACCEPTED = ThrottleUpdateItems
end

function eventFrame:QUEST_LOG_UPDATE()
	if not firstRunDone then
		if DEBUG then Debug("- Query for Server data") end -- Debug

		self:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST") -- Fired when Calendar data is available
		C_Calendar.OpenCalendar() -- Requests calendar information from the server. Does not open the calendar frame.
		-- Triggers CALENDAR_UPDATE_EVENT_LIST when your query has finished processing on the server and new calendar information is available.

		firstRunDone = true -- Don't do this more than once
	end

	f:UpdateItems()
	f:UpdateQuests()
end

function eventFrame:CALENDAR_UPDATE_EVENT_LIST() -- Check if DMF is available and notify Player in ChatFrame on login
	if not firstRunDone then return end

	self:UnregisterEvent("CALENDAR_UPDATE_EVENT_LIST")

	if f:CheckDMF() then
		f:Print(format(GREEN_FONT_COLOR_CODE.."=========================|r"))
		f:Print(format(L.DMFWarning, GREEN_FONT_COLOR_CODE))
		f:Print(format(GREEN_FONT_COLOR_CODE.."=========================|r"))
	else
		--self:Hide()
	end

	self.CALENDAR_UPDATE_EVENT_LIST = nil
end

function eventFrame:SKILL_LINES_CHANGED()
	local primary, secondary, archaeology, fishing, cooking, firstAid = GetProfessions()
	f:UpdateProfession(PRIMARY, primary)
	f:UpdateProfession(SECONDARY, secondary)
	f:UpdateProfession(ARCHAEOLOGY, archaeology)
	f:UpdateProfession(FISHING, fishing)
	f:UpdateProfession(COOKING, cooking)
	--f:UpdateProfession(FIRSTAID, firstAid)

	if firstRunDone then -- This is first time fired before PLAYER_LOGIN so we need some kind of safetynet
		f:UpdateQuests()
	end
end

--[[function eventFrame:MERCHANT_SHOW()
	-- Buy items only during DMF and when Frame is visible, except when it is DMF and you are on quest A Fizzy Fusion (Alchemy)
	--f:Print("CheckDMF: %s, IsShown: %s, GetQuestLogIndexByID: %d", tostring(f:CheckDMF()), tostring(f:IsShown()), tonumber(GetQuestLogIndexByID(29506)))
	--if not self:CheckDMF() or not self:IsShown() and not (self:CheckDMF() and GetQuestLogIndexByID(29506) > 0) then
	--	return
	--end
	--
	--self:BuyItems()

	if f:CheckDMF() and (f:IsShown() or GetQuestLogIndexByID(29506) > 0) then
		f:BuyItems()
	end
end]]

do -- MERCHANT throttling
	local throttling

	local function DelayedBuyItems()
		throttling = nil

		--if f:CheckDMF() and (f:IsShown() or GetQuestLogIndexByID(29506) > 0) then
		if f:CheckDMF() and (f:IsShown() or (C_QuestLog.GetLogIndexForQuestID(29506) and C_QuestLog.GetLogIndexForQuestID(29506) > 0)) then -- 29506 = A Fizzy Fusion
			f:BuyItems()
		end
	end

	local function ThrottleBuyItems()
		if not throttling then
			if DEBUG then Debug("- Throttling Buy Items...") end -- Debug

			C_Timer.After(1, DelayedBuyItems)
			throttling = true
		end
	end

	eventFrame.MERCHANT_SHOW = ThrottleBuyItems
	eventFrame.MERCHANT_UPDATE = ThrottleBuyItems
	eventFrame.MERCHANT_FILTER_ITEM_UPDATE = ThrottleBuyItems
end

function eventFrame:QUEST_DETAIL()
	if not QuestFrame:IsVisible() then return end

	--self:UnregisterEvent("QUEST_PROGRESS")

	local openID = GetQuestID()
	for questID, _ in pairs(turnInItems) do -- Don't auto-accept any other quests than turn-in items
		if questID == openID then
			AcceptQuest()
			return
		end
	end
end


-------------------------------------------------------------------------------
-- DMFQuest Config
-------------------------------------------------------------------------------
panel = CreateFrame("Frame", ADDON_NAME.."Options", InterfaceOptionsFramePanelContainer)
panel.name = ADDON_NAME
InterfaceOptions_AddCategory(panel)
panel:Hide()

panel:SetScript("OnShow", function()
	local function CreatePanel(name, labelText)
		local panelBackdrop = {
			bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tile = true, tileSize = 16,
			edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
			insets = { left = 5, right = 5, top = 5, bottom = 5 }
		}

		local frame = CreateFrame("Frame", name, panel, BackdropTemplateMixin and "BackdropTemplate")
		frame:SetBackdrop(panelBackdrop)
		frame:SetBackdropColor(0.06, 0.06, 0.06, 0.4)
		frame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

		local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		label:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 4, 0)
		label:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -4, 0)
		label:SetJustifyH("LEFT")
		label:SetText(labelText)
		frame.labelText = label

		frame:SetSize(floor(InterfaceOptionsFramePanelContainer:GetWidth() - 32), 50)

		return frame
	end

	local function MakeSlider(name)
		local Slider = CreateFrame("Slider", name, panel, "OptionsSliderTemplate")
		Slider:SetWidth(200)

		Slider.low = _G[Slider:GetName().."Low"]
		Slider.low:SetPoint("TOPLEFT", Slider, "BOTTOMLEFT", 0, 0)
		Slider.low:SetFontObject(GameFontNormalSmall)
		Slider.low:Hide()

		Slider.high = _G[Slider:GetName().."High"]
		Slider.high:SetPoint("TOPRIGHT", Slider, "BOTTOMRIGHT", 0, 0)
		Slider.high:SetFontObject(GameFontNormalSmall)
		Slider.high:Hide()

		Slider.value = Slider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		Slider.value:SetPoint("BOTTOMRIGHT", Slider, "TOPRIGHT")

		Slider.text = _G[Slider:GetName().."Text"]
		Slider.text:SetFontObject(GameFontNormal)
		Slider.text:ClearAllPoints()
		Slider.text:SetPoint("BOTTOMLEFT", Slider, "TOPLEFT")
		Slider.text:SetPoint("BOTTOMRIGHT", Slider.value, "BOTTOMLEFT", -4, 0)
		Slider.text:SetJustifyH("LEFT")

		return Slider
	end

	local function MakeButton(name, tooltipText)
		local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
		button:GetFontString():SetPoint("CENTER", -1, 0)
		button:SetMotionScriptsWhileDisabled(true)
		button:RegisterForClicks("AnyUp")
		button:SetText(name)
		button.tooltipText = tooltipText

		return button
	end

	--------------------------------------------------------------------

	local Title = panel:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormalLarge")
	Title:SetPoint("TOPLEFT", 16, -16)
	Title:SetText(ADDON_NAME.." "..GetAddOnMetadata(ADDON_NAME, "Version"))

	local SubText = panel:CreateFontString("$parentSubText", "ARTWORK", "GameFontHighlightSmall")
	SubText:SetPoint("TOPLEFT", Title, "BOTTOMLEFT", 0, -8)
	SubText:SetPoint("RIGHT", -32, 0)
	SubText:SetHeight(32)
	SubText:SetJustifyH("LEFT")
	SubText:SetJustifyV("TOP")
	SubText:SetText(GetAddOnMetadata(ADDON_NAME, "Notes"))

	--------------------------------------------------------------------

	local SPanel = CreatePanel("$parentSPanel", format(L.Pos, L.Frame))
	SPanel:SetPoint("BOTTOMLEFT", 16, 16)

	local XSlider = MakeSlider("$parentXSlider")
	XSlider:SetMinMaxValues(0, floor(GetScreenWidth() + 0.5))
	XSlider.minValue, XSlider.maxValue = XSlider:GetMinMaxValues()
	XSlider:SetValueStep(1)
	XSlider.low:SetText(XSlider.minValue)
	XSlider.low:Show()
	XSlider.high:SetText(XSlider.maxValue)
	XSlider.high:Show()
	XSlider.text:SetText(format(L.Pos, "X-"))
	XSlider.tooltipText = format(L.Pos_Tip, "X")
	XSlider:SetPoint("TOPLEFT", SPanel, (12 + 22), -floor(12 + XSlider.text:GetHeight() + 0.5)) -- X: Margin + width of a button, Y: Give room for Text and Value
	XSlider:SetScript("OnValueChanged", function(self, value)
		if DEBUG then Debug("C: X", value) end

		self.value:SetText(floor(value + 0.5))

		if floor(value + f:GetWidth() + 0.5) > floor(GetScreenWidth() + 0.5) then
			value = floor(GetScreenWidth() - f:GetWidth() + 0.5)
		end
		db.XPos = floor(value + 0.5)

		f:ClearAllPoints()
		f:SetPoint("BOTTOMLEFT", db.XPos, db.YPos)
	end)


	local YSlider = MakeSlider("$parentYSlider")
	YSlider:SetMinMaxValues(0, floor(GetScreenHeight() + 0.5))
	YSlider.minValue, YSlider.maxValue = YSlider:GetMinMaxValues()
	YSlider:SetValueStep(1)
	YSlider.low:SetText(YSlider.minValue)
	YSlider.low:Show()
	YSlider.high:SetText(YSlider.maxValue)
	YSlider.high:Show()
	YSlider.text:SetText(format(L.Pos, "Y-"))
	YSlider.tooltipText = format(L.Pos_Tip, "Y")
	YSlider:SetPoint("TOPRIGHT", SPanel, -(12 + 22), -floor(12 + YSlider.text:GetHeight() + 0.5)) -- X: Margin + width of a button, Y: Give room for Text and Value
	YSlider:SetScript("OnValueChanged", function(self, value)
		if DEBUG then Debug("C: Y", value) end

		self.value:SetText(floor(value + 0.5))

		if floor(value + f:GetHeight() + 0.5) > floor(GetScreenHeight() + 0.5) then
			value = floor(GetScreenHeight() - f:GetHeight() + 0.5)
		end
		db.YPos = floor(value+0.5)

		f:ClearAllPoints()
		f:SetPoint("BOTTOMLEFT", db.XPos, db.YPos)
	end)

	local Xm = MakeButton("-", L.NudgeLeft)
	Xm:SetPoint("RIGHT", XSlider, "LEFT")
	Xm:SetWidth(Xm:GetHeight())
	Xm:SetScript("OnClick", function(self, button)
		--PlaySound("gsTitleOptionOK")
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)

		db.XPos = floor(db.XPos - 1)

		f:ClearAllPoints()
		f:SetPoint("BOTTOMLEFT", db.XPos, db.YPos)

		XSlider:SetValue(db.XPos)

		if DEBUG then Debug("C: X-") end
	end)

	local Xp = MakeButton("+", L.NudgeRight)
	Xp:SetPoint("LEFT", XSlider, "RIGHT")
	Xp:SetWidth(Xp:GetHeight())
	Xp:SetScript("OnClick", function(self, button)
		--PlaySound("gsTitleOptionOK")
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)

		db.XPos = floor(db.XPos + 1)

		f:ClearAllPoints()
		f:SetPoint("BOTTOMLEFT", db.XPos, db.YPos)

		XSlider:SetValue(db.XPos)

		if DEBUG then Debug("C: X+") end
	end)

	local Ym = MakeButton("-", L.NudgeDown)
	Ym:SetPoint("RIGHT", YSlider, "LEFT")
	Ym:SetWidth(Ym:GetHeight())
	Ym:SetScript("OnClick", function(self, button)
		--PlaySound("gsTitleOptionOK")
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)

		db.YPos = floor(db.YPos - 1)

		f:ClearAllPoints()
		f:SetPoint("BOTTOMLEFT", db.XPos, db.YPos)

		YSlider:SetValue(db.YPos)

		if DEBUG then Debug("C: Y-") end
	end)

	local Yp = MakeButton("+", L.NudgeUp)
	Yp:SetPoint("LEFT", YSlider, "RIGHT")
	Yp:SetWidth(Yp:GetHeight())
	Yp:SetScript("OnClick", function(self, button)
		--PlaySound("gsTitleOptionOK")
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)

		db.YPos = floor(db.YPos + 1)

		f:ClearAllPoints()
		f:SetPoint("BOTTOMLEFT", db.XPos, db.YPos)

		YSlider:SetValue(db.YPos)

		if DEBUG then Debug("C: Y+") end
	end)

	local ResetPos = MakeButton(L.Reset, L.Reset_Tip)
	ResetPos:SetPoint("CENTER", SPanel, 0, 9)
	ResetPos:SetWidth(ResetPos:GetFontString():GetStringWidth() + 24)
	ResetPos:SetScript("OnClick", function(self, button)
		--PlaySound("gsTitleOptionOK")
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)

		db.XPos = 275
		db.YPos = 275

		f:ClearAllPoints()
		f:SetPoint("BOTTOMLEFT", db.XPos, db.YPos)

		XSlider:SetValue(db.XPos)
		YSlider:SetValue(db.YPos)

		if DEBUG then Debug("C: Reset") end
	end)

	local SSubText = SPanel:CreateFontString("$parentSubText", "ARTWORK", "GameFontHighlightSmall")
	SSubText:SetPoint("TOPLEFT", XSlider.low, "BOTTOMLEFT", -22, -8) -- X reducing the width of a button
	SSubText:SetJustifyH("LEFT")
	SSubText:SetJustifyV("TOP")
	SSubText:SetText(L.Pos_Desc)

	SPanel:SetHeight(floor(XSlider:GetHeight() + XSlider.low:GetHeight() + XSlider.text:GetHeight() + SSubText:GetHeight() + 36 + 0.5))

	--------------------------------------------------------------------

	local CPanel = CreatePanel("$parentConfigPanel", L.Config)
	CPanel:SetPoint("TOPLEFT", SubText, "BOTTOMLEFT", 0, -12)
	CPanel:SetPoint("BOTTOMLEFT", SPanel, "TOPLEFT", 0, 28)

	--------------------------------------------------------------------

	local AutoBuyCheckBox = CreateFrame("CheckButton", "$parentAutoBuyCheckBox", panel, "InterfaceOptionsCheckButtonTemplate")
	AutoBuyCheckBox:SetPoint("TOPLEFT", CPanel, 8, -8)
	AutoBuyCheckBox.Text:SetText(NORMAL_FONT_COLOR_CODE .. L.Enable .. FONT_COLOR_CODE_CLOSE)
	AutoBuyCheckBox.tooltipText = L.Enable_Tip
	AutoBuyCheckBox:SetScript("OnClick", function(this)
		local checked = not not this:GetChecked()
		--PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		db.AutoBuy = checked

		if DEBUG then Debug("C: AutoBuy", db.AutoBuy, checked) end
	end)

	local ABSubText = CPanel:CreateFontString("$parentSubText", "ARTWORK", "GameFontHighlightSmall")
	ABSubText:SetPoint("TOPLEFT", AutoBuyCheckBox, "BOTTOMLEFT", 4, -8)
	ABSubText:SetJustifyH("LEFT")
	ABSubText:SetJustifyV("TOP")
	ABSubText:SetText(L.Enable_Desc)

	--------------------------------------------------------------------

	--[[
		https://www.wowhead.com/news=318875/darkmoon-faire-november-2020-skill-requirement-removed-from-profession-quests
		---------------------------------------------------------------------------------
		In the Shadowlands pre-patch, the 75 skill requirement has been removed from
		Darkmoon Faire profession quests. You now only need to know a minimum of level 1,
		and completing the quest still adds points to the highest expansion's profession
		level known.
		---------------------------------------------------------------------------------
	]]--

	--[[local LowSkillCheckBox = CreateFrame("CheckButton", "$parentLowSkillCheckBox", panel, "InterfaceOptionsCheckButtonTemplate")
	LowSkillCheckBox:SetPoint("TOPLEFT", ABSubText, -4, -26)
	LowSkillCheckBox.Text:SetText(NORMAL_FONT_COLOR_CODE .. L.HideLow .. FONT_COLOR_CODE_CLOSE)
	LowSkillCheckBox.tooltipText = L.HideLow_Tip
	LowSkillCheckBox:SetScript("OnClick", function(this)
		local checked = not not this:GetChecked()
		--PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		db.HideLow = checked

		f:UpdateQuests()

		if DEBUG then Debug("C: HideLow", db.HideLow, checked) end
	end)

	local HLSubText = CPanel:CreateFontString("$parentSubText2", "ARTWORK", "GameFontHighlightSmall")
	HLSubText:SetPoint("TOPLEFT", LowSkillCheckBox, "BOTTOMLEFT", 4, -8)
	HLSubText:SetJustifyH("LEFT")
	HLSubText:SetJustifyV("TOP")
	HLSubText:SetText(L.HideLow_Desc)
	]]

	local HighSkillCheckBox = CreateFrame("CheckButton", "$parentHighSkillCheckBox", panel, "InterfaceOptionsCheckButtonTemplate")
	--HighSkillCheckBox:SetPoint("TOPLEFT", HLSubText, -4, -26)
	HighSkillCheckBox:SetPoint("TOPLEFT", ABSubText, -4, -26)
	HighSkillCheckBox.Text:SetText(NORMAL_FONT_COLOR_CODE .. L.HideHigh .. FONT_COLOR_CODE_CLOSE)
	HighSkillCheckBox.tooltipText = L.HideMax_Tip
	HighSkillCheckBox:SetScript("OnClick", function(this)
		local checked = not not this:GetChecked()
		--PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		db.HideMax = checked

		f:UpdateQuests()

		if DEBUG then Debug("C: HideMax", db.HideMax, checked) end
	end)

	local HMSubText = CPanel:CreateFontString("$parentSubText3", "ARTWORK", "GameFontHighlightSmall")
	HMSubText:SetPoint("TOPLEFT", HighSkillCheckBox, "BOTTOMLEFT", 4, -8)
	HMSubText:SetJustifyH("LEFT")
	HMSubText:SetJustifyV("TOP")
	HMSubText:SetText(L.HideMax_Desc)

	--------------------------------------------------------------------

	local PetBattleCheckBox = CreateFrame("CheckButton", "$parentPetBattleCheckBox", panel, "InterfaceOptionsCheckButtonTemplate")
	PetBattleCheckBox:SetPoint("TOPLEFT", HMSubText, -4, -26)
	PetBattleCheckBox.Text:SetText(NORMAL_FONT_COLOR_CODE .. L.EnablePetBattle .. FONT_COLOR_CODE_CLOSE)
	PetBattleCheckBox.tooltipText = L.PetBattle_Tip
	PetBattleCheckBox:SetScript("OnClick", function(this)
		local checked = not not this:GetChecked()
		--PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		db.PetBattle = checked

		f:UpdateQuests()

		if DEBUG then Debug("C: PetBattle", db.PetBattle, checked) end
	end)

	local DeathMetalKnightChechBox = CreateFrame("CheckButton", "$parentDeathMetalKnightChechBox", panel, "InterfaceOptionsCheckButtonTemplate")
	--DeathMetalKnightChechBox:SetPoint("TOPLEFT", PetBattleCheckBox, "BOTTOMLEFT", 0, -8)
	DeathMetalKnightChechBox:SetPoint("TOPLEFT", HMSubText, -4 + CPanel:GetWidth() / 2, -26)
	DeathMetalKnightChechBox.Text:SetText(NORMAL_FONT_COLOR_CODE .. L.EnableDeathMetalKnight .. FONT_COLOR_CODE_CLOSE)
	DeathMetalKnightChechBox.tooltipText = L.DeathMetalKnight_Tip
	DeathMetalKnightChechBox:SetScript("OnClick", function(this)
		local checked = not not this:GetChecked()
		--PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		db.DeathMetalKnight = checked

		f:UpdateQuests()

		if DEBUG then Debug("C: DeathMetalKnight", db.DeathMetalKnight, checked) end
	end)

	local TestYourStrengthCheckBox = CreateFrame("CheckButton", "$parentTestYourStrengthChechBox", panel, "InterfaceOptionsCheckButtonTemplate")
	--TestYourStrengthCheckBox:SetPoint("TOPLEFT", DeathMetalKnightChechBox, "BOTTOMLEFT", 0, -8)
	TestYourStrengthCheckBox:SetPoint("TOPLEFT", PetBattleCheckBox, "BOTTOMLEFT", 0, -8)
	TestYourStrengthCheckBox.Text:SetText(NORMAL_FONT_COLOR_CODE .. L.EnableTestYourStrength .. FONT_COLOR_CODE_CLOSE)
	TestYourStrengthCheckBox.tooltipText = L.TestYourStrength_Tip
	TestYourStrengthCheckBox:SetScript("OnClick", function(this)
		local checked = not not this:GetChecked()
		--PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		db.TestYourStrength = checked

		f:UpdateQuests()

		if DEBUG then Debug("C: TestYourStrength", db.TestYourStrength, checked) end
	end)

	local FadedTreasureMapCheckBox = CreateFrame("CheckButton", "$parentFadedTreasureMapChechBox", panel, "InterfaceOptionsCheckButtonTemplate")
	--FadedTreasureMapCheckBox:SetPoint("TOPLEFT", TestYourStrengthCheckBox, "BOTTOMLEFT", 0, -8)
	FadedTreasureMapCheckBox:SetPoint("TOPLEFT", DeathMetalKnightChechBox, "BOTTOMLEFT", 0, -8)
	FadedTreasureMapCheckBox.Text:SetText(NORMAL_FONT_COLOR_CODE .. L.EnableFadedTreasureMap .. FONT_COLOR_CODE_CLOSE)
	FadedTreasureMapCheckBox.tooltipText = L.FadedTreasureMap_Tip
	FadedTreasureMapCheckBox:SetScript("OnClick", function(this)
		local checked = not not this:GetChecked()
		--PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		db.FadedTreasureMap = checked

		f:UpdateQuests()

		if DEBUG then Debug("C: FadedTreasureMap", db.FadedTreasureMap, checked) end
	end)

	local DMFSubText = CPanel:CreateFontString("$parentSubText4", "ARTWORK", "GameFontHighlightSmall")
	--DMFSubText:SetPoint("TOPLEFT", FadedTreasureMapCheckBox, "BOTTOMLEFT", 4, -8)
	DMFSubText:SetPoint("TOPLEFT", TestYourStrengthCheckBox, "BOTTOMLEFT", 4, -8)
	DMFSubText:SetJustifyH("LEFT")
	DMFSubText:SetJustifyV("TOP")
	DMFSubText:SetText(L.Misc_Desc)

	--------------------------------------------------------------------

	local ShowItemRewardsCheckBox = CreateFrame("CheckButton", "$parentShowItemRewardsCheckBox", panel, "InterfaceOptionsCheckButtonTemplate")
	ShowItemRewardsCheckBox:SetPoint("TOPLEFT", DMFSubText, -4, -26)
	ShowItemRewardsCheckBox.Text:SetText(NORMAL_FONT_COLOR_CODE .. L.EnableShowItemRewards .. FONT_COLOR_CODE_CLOSE)
	ShowItemRewardsCheckBox.tooltipText = L.ShowItemRewards_Tip
	ShowItemRewardsCheckBox:SetScript("OnClick", function(this)
		local checked = not not this:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		db.ShowItemRewards = checked

		if DEBUG then Debug("C: ShowItemRewards", db.ShowItemRewards, checked) end
	end)

	local ShowItemRewardsSubText = CPanel:CreateFontString("$parentSubText5", "ARTWORK", "GameFontHighlightSmall")
	ShowItemRewardsSubText:SetPoint("TOPLEFT", ShowItemRewardsCheckBox, "BOTTOMLEFT", 4, -8)
	ShowItemRewardsSubText:SetJustifyH("LEFT")
	ShowItemRewardsSubText:SetJustifyV("TOP")
	ShowItemRewardsSubText:SetText(L.ShowItemRewards_Desc)

	local UseTimeOffsetCheckBox = CreateFrame("CheckButton", "$parentUseTimeOffset", panel, "InterfaceOptionsCheckButtonTemplate")
	UseTimeOffsetCheckBox:SetPoint("TOPLEFT", ShowItemRewardsSubText, -4, -26)
	UseTimeOffsetCheckBox.Text:SetText(NORMAL_FONT_COLOR_CODE .. L.EnableUseTimeOffset .. FONT_COLOR_CODE_CLOSE)
	UseTimeOffsetCheckBox.tooltipText = L.UseTimeOffset_Tip
	UseTimeOffsetCheckBox:SetScript("OnClick", function(this)
		local checked = not not this:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		db.UseTimeOffset = checked

		if DEBUG then Debug("C: UseTimeOffset", db.UseTimeOffset, checked) end
	end)

	local UseTimeOffsetSubText = CPanel:CreateFontString("$parentSubText6", "ARTWORK", "GameFontHighlightSmall")
	UseTimeOffsetSubText:SetPoint("TOPLEFT", UseTimeOffsetCheckBox, "BOTTOMLEFT", 4, -8)
	UseTimeOffsetSubText:SetJustifyH("LEFT")
	UseTimeOffsetSubText:SetJustifyV("TOP")
	UseTimeOffsetSubText:SetText(L.UseTimeOffset_Desc)

	--------------------------------------------------------------------

	function panel:Refresh()
		AutoBuyCheckBox:SetChecked(db.AutoBuy)
		--LowSkillCheckBox:SetChecked(db.HideLow)
		HighSkillCheckBox:SetChecked(db.HideMax)

		PetBattleCheckBox:SetChecked(db.PetBattle)
		DeathMetalKnightChechBox:SetChecked(db.DeathMetalKnight)
		TestYourStrengthCheckBox:SetChecked(db.TestYourStrength)
		FadedTreasureMapCheckBox:SetChecked(db.FadedTreasureMap)

		ShowItemRewardsCheckBox:SetChecked(db.ShowItemRewards)
		UseTimeOffsetCheckBox:SetChecked(db.UseTimeOffset)
		
		XSlider:SetValue(db.XPos)
		YSlider:SetValue(db.YPos)

	end

	panel:Refresh()
	panel:SetScript("OnShow", nil)
end)


-------------------------------------------------------------------------------
--EOF
