--[[----------------------------------------------------------------------------
	DMFQuest

	Reminder tool for Darkmoon Faire crafting quest materials

	Version 1.0:
	- 2013 - 2014
	- 5.1.0 - 6.0.3

	Version 2.0:
	- 2015 - 2024
	- 6.0.3 - 10.2.5

	Version 3.0:
	- 2024 -
	- 10.2.5 -
----------------------------------------------------------------------------]]--
	local ADDON_NAME, ns = ...
	local L = ns.L -- Localization table

	local db
	local isFramePinned = false

	local isRetail = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE)
	local isCataClassic = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_CATACLYSM_CLASSIC)

	-- GLOBALS: DMFQConfig, DEBUG_CHAT_FRAME

	-- GLOBALS: GREEN_FONT_COLOR, ORANGE_FONT_COLOR, RED_FONT_COLOR

	-- GLOBALS: BINDING_HEADER_DEBUG, CONFIRM_RESET_SETTINGS, GARRISON_MISSION_REWARD_HEADER, 
	-- GLOBALS: HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN,
	-- GLOBALS: HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP, MISCELLANEOUS, RESET_ALL_BUTTON_TEXT,
	-- GLOBALS: RESET_TO_DEFAULT, SHOW_PET_BATTLES_ON_MAP_TEXT, TIMEMANAGER_TOOLTIP_REALMTIME

	-- GLOBALS: C_AddOns, C_Calendar, C_Container, C_CurrencyInfo, C_DateAndTime, C_Map, C_MapExplorationInfo,
	-- GLOBALS: C_QuestLog, C_Timer, C_TradeSkillUI, C_UI

	-- GLOBALS: AcceptQuest, BuyMerchantItem, CalendarFrame, ChatFrame3, ChatFrame4, Constants, CreateFrame,
	-- GLOBALS: DEFAULT_CHAT_FRAME, Enum, format, GameTooltip, GetBuildInfo, GetCoinText, GetItemCount,
	-- GLOBALS: GetMerchantItemID, GetMerchantItemInfo, GetMerchantItemLink, GetMerchantItemMaxStack,
	-- GLOBALS: GetMerchantNumItems, GetMinimapZoneText, GetMoney, GetProfessionInfo, GetProfessions, GetQuestID,
	-- GLOBALS: GetQuestObjectiveInfo, InCombatLockdown, InterfaceOptionsFrame_OpenToCategory, ipairs, Item, math, next,
	-- GLOBALS: pairs, PlaySound, PROFESSION_RANKS, Settings, SOUNDKIT, string, strjoin, strsplit, strtrim, time,
	-- GLOBALS: tonumber, tostring, tostringall, type, UIParent, UnitPosition, unpack, wipe


--[[----------------------------------------------------------------------------
	Hard coded "data"
----------------------------------------------------------------------------]]--

	--[[------------------------------------------------------------------------
		https://www.wowhead.com/news=318875/darkmoon-faire-november-2020-skill-requirement-removed-from-profession-quests
		------------------------------------------------------------------------
		In the Shadowlands pre-patch, the 75 skill requirement has been removed
		from Darkmoon Faire profession quests. You now only need to know a
		minimum of level 1, and completing the quest still adds points to the
		highest expansion's profession level known.
	------------------------------------------------------------------------]]--
	local minimumSkillRequired = 1 -- This used to be 75
	local currentSkillCap = PROFESSION_RANKS[#PROFESSION_RANKS][1] or 75
	local dbDefaults = {
		-- Frame
		XPos = 275,
		YPos = 275,
		FrameLock = false,
		GrowDirection = 1, -- 0 = Down, 1 = Up
		FrameVertexColor = { 1, 1, 1 }, -- UI shade
		-- Features
		AutoBuy = true,
		HideLow = false,
		HideMax = false,
		-- Quests
		PetBattle = true,
		DeathMetalKnight = true,
		TestYourStrength = true,
		FadedTreasureMap = true,
		ShowItemRewards = true,
		-- Time Offset
		UseTimeOffset = false,
		TimeOffsetValue = 0,
		-- Development and Debug
		dbVersion = 1, -- In case we need to change things in the future
		debug = false, -- Debug output
		isPTR = false, -- Change some values on PTR only
	}

	-- Item Buttons
		local itemButtonOrder = { -- [order] = questItemId
			-- Dungeon
				71635, -- Imbued Crystal
				71636, -- Monstrous Egg
				71637, -- Mysterious Grimoire
				71638, -- Ornate Weapon
			-- Heroic Dungeon
				71715, -- A Treatise on Strategy
			-- Raid
				71716, -- Soothsayer's Runes
			-- PvP
				71951, -- Banner of the Fallen
				71952, -- Captured Insignia
				71953, -- Fallen Adventurer's Journal
			-- Killing Moonfang
				105891 -- Moonfang's Pelt
		}
		local buttonVertices = { -- SetVertexColor, rowIndex selected with button.itemStatus, 1-3 normal (onLeave), 4-6 highlight (onEnter)
			-- Quest Completed (1)
				{ 0, 1, 0, -- OnLeave
				.75, 1, .75 }, -- OnEnter
			-- On Quest (2)
				{ 0, 1, 1, -- OnLeave
				.75, 1, 1 }, -- OnEnter
			-- Item, but no Quest (3)
				{ 1, 1, 1, -- OnLeave
				.75, .75, .75 }, -- OnEnter
			-- No Item (4)
				{ .3, .3, .3, -- OnLeave
				.75, .75, .75 } -- OnEnter
		}

	-- Item Quests
		local turnInItems = { -- [questItemId] = questId
			-- Dungeon
				[71635] = 29443, -- Imbued Crystal
				[71636] = 29444, -- Monstrous Egg
				[71637] = 29445, -- Mysterious Grimoire
				[71638] = 29446, -- Ornate Weapon
			-- Heroic Dungeon
				[71715] = 29451, -- A Treatise on Strategy
			-- Raid
				[71716] = 29464, -- Soothsayer's Runes
			-- PvP
				[71951] = 29456, -- Banner of the Fallen
				[71952] = 29457, -- Captured Insignia
				[71953] = 29458, -- Fallen Adventurer's Journal
			-- Killing Moonfang
				[105891] = 33354 -- Moonfang's Pelt
		}
		local rewardsTable = { -- [questItemId] = # of [Darkmoon Prize Ticket] from completing the quest
			-- Dungeon
				[71635] = 10, -- Imbued Crystal
				[71636] = 10, -- Monstrous Egg
				[71637] = 10, -- Mysterious Grimoire
				[71638] = 10, -- Ornate Weapon
			-- Heroic Dungeon
				[71715] = 15, -- A Treatise on Strategy
			-- Raid
				[71716] = 10, -- Soothsayer's Runes
			-- PvP
				[71951] = 5, -- Banner of the Fallen
				[71952] = 5, -- Captured Insignia
				[71953] = 5, -- Fallen Adventurer's Journal
			-- Killing Moonfang
				[105891] = 10 -- Moonfang's Pelt
		}

	-- Portal Areas
		local subZoneAreaIDs = { -- uiMapIDs and their matching subZone areaIDs
			--[[
			-- https://wow.tools/dbc/?dbc=uimap
			-- https://wow.tools/dbc/?dbc=areatable
			[uiMapID] = {
				areaID,
				areaID,
				areaID
			}
			]]--

			-- Alliance
			[37] = {	-- Elwynn Forrest
				87,			-- Goldshire (Town)
				5637		-- Lion's Pride Inn (Inn)
			},
			-- Horde
			[7] = {		-- Mulgore
				-- These both return Mulgore for GetMinimapZoneText() and empty string for GetSubZoneText()
				-- Also the changing of GetMinimapZoneText() is kind of hit or miss depending on the direction you arrive to the Portal from
				404,		-- Bael'dun Digsite (SW from Portal)
				1638		-- Thunder Bluff (Next to the city, but not quite in it yet)
			},
			[88] = {	-- Thunder Bluff
				1638,		-- Thunder Bluff (Central Rise)
				1639,		-- Elder Rise (Eastern Rise)
				1640,		-- Spirit Rise (Northern Rise)
				1641,		-- Hunter Rise (Southern Rise)
				8614		-- The Cat and the Shaman (Inn)
			}
		}

	-- Professions
		local ProfData = {} -- Save information about our Professions here
		local ProfessionQuestData = {
			-- Primary Professions
				[171] = { -- Alchemy
							questId = 29506,
							questItems = {
								[1645] = 5, -- Moonberry Juice
								[19299] = 5 -- Fizzy Faire Drink
							}
						},
				[164] = { -- Blacksmithing
							questId = 29508
						},
				[333] = { -- Enchanting
							questId = 29510
						},
				[202] = { -- Engineering
							questId = 29511
						},
				[182] = { -- Herbalism
							questId = 29514
						},
				[773] = { -- Inscription
							questId = 29515,
							questItems = {
								[39354] = 5 -- Light Parchment
							}
						},
				[755] = { -- Jewelcrafting
							questId = 29516
						},
				[165] = { -- Leatherworking
							questId = 29517,
							questItems = {
								[6529] = 10, -- Shiny Bauble
								[2320] = 5, -- Coarse Thread
								[6260] = 5 -- Blue Dye
							}
						},
				[186] = { -- Mining
							questId = 29518
						},
				[393] = { -- Skinning
							questId = 29519
						},
				[197] = { -- Tailoring
							questId = 29520,
							questItems = {
								[2320] = 1, -- Coarse Thread
								[6260] = 1, -- Blue Dye
								[2604] = 1 -- Red Dye
							}
						},
			-- Secondary Professions
				[794] = { -- Archaeology
							questId = 29507,
							questCurrency = {
								[393] = 15 -- Fossil Archaeology Fragment
							}
						},
				[129] = { -- FirstAid
							questId = 29512
						},
				[356] = { -- Fishing
							questId = 29513
						},
				[185] = { -- Cooking
							questId = 29509,
							questItems = {
								[30817] = 5 -- Simple Flour
							}
						}
		}
		local ProfessionTradeSkillLines = {
			-- https://wowpedia.fandom.com/wiki/TradeSkillLineID
			-- https://wow.tools/dbc/?dbc=skillline
			-- [ProfId] = { Classic, TBC, Wrath, Cata, MoP, WoD, Legion, BfA, SL, DF }
			-- Primary Professions
				[171] = { -- Alchemy
					2485, 2484, 2483, 2482, 2481, 2480, 2479, 2478, 2750, 2823 
				},
				[164] = { -- Blacksmithing
					2477, 2476, 2475, 2474, 2473, 2472, 2454, 2437, 2751, 2822
				},
				[333] = { -- Enchanting
					2494, 2493, 2492, 2491, 2489, 2488, 2487, 2486, 2753, 2825
				},
				[202] = { -- Engineering
					2506, 2505, 2504, 2503, 2502, 2501, 2500, 2499, 2755, 2827
				},
				[182] = { -- Herbalism
					2556, 2555, 2554, 2553, 2552, 2551, 2550, 2549, 2760, 2832
				},
				[773] = { -- Inscription
					2514, 2513, 2512, 2511, 2510, 2509, 2508, 2507, 2756, 2828
				},
				[755] = { -- Jewelcrafting
					2524, 2523, 2522, 2521, 2520, 2519, 2518, 2517, 2757, 2829
				},
				[165] = { -- Leatherworking
					2532, 2531, 2530, 2529, 2528, 2527, 2526, 2525, 2758, 2830
				},
				[186] = { -- Mining
					2572, 2571, 2570, 2569, 2568, 2567, 2566, 2565, 2761, 2833
				},
				[393] = { -- Skinning
					2564, 2563, 2562, 2561, 2560, 2559, 2558, 2557, 2762, 2834
				},
				[197] = { -- Tailoring
					2540, 2539, 2538, 2537, 2536, 2535, 2534, 2533, 2759, 2831
				},
			-- Secondary Professions
				--[794] = { -- Archeology
				--}
				[185] = { -- Cooking
					2548, 2547, 2546, 2545, 2544, 2543, 2542, 2541, 2752, 2824
				},
				--[129] = { -- First Aid
				--}
				[356] = { -- Fishing
					2592, 2591, 2590, 2589, 2588, 2587, 2586, 2585, 2754, 2826
				}
		}

	-- Additional Quests and Activities
		local additionalQuests = {
			PetBattle = {
				Icon = 631719, -- 319458
				QuestIdTable = {
					32175, -- Jeremy Feasel - Darkmoon Pet Battle!
					36471 -- Christoph VonFeasel - A New Darkmoon Challenger!
				}
			},
			DeathMetalKnight = {
				Icon = 236362,
				QuestId = 47767 -- Death Metal Knight
			},
			TestYourStrength = {
				Icon = 136101,
				QuestId = 29433 -- Test Your Strenght
			},
			FadedTreasureMap = { -- One time Quest starting from Vendor bought item
				Icon = 237388,
				QuestId = 38934, -- Silas' Secret Stash
				StartItemId = 126930 -- Faded Treasure Map
			}
		}


--[[----------------------------------------------------------------------------
	Helper functions
----------------------------------------------------------------------------]]--
	local function Debug(text, ...)
		if (not db) or (not db.debug) then return end

		if text then
			if text:match("%%[dfqsx%d%.]") then
				(DEBUG_CHAT_FRAME or (ChatFrame3:IsShown() and ChatFrame3 or ChatFrame4)):AddMessage("|cffff9999"..ADDON_NAME..":|r " .. format(text, ...))
			else
				(DEBUG_CHAT_FRAME or (ChatFrame3:IsShown() and ChatFrame3 or ChatFrame4)):AddMessage("|cffff9999"..ADDON_NAME..":|r " .. strjoin(" ", text, tostringall(...)))
			end
		end
	end

	local function Print(text, ...)
		if text then
			if text:match("%%[dfqs%d%.]") then
				DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00".. ADDON_NAME ..":|r " .. format(text, ...))
			else
				DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00".. ADDON_NAME ..":|r " .. strjoin(" ", text, tostringall(...)))
			end
		end
	end

	local function initDB(db, defaults) -- This function copies values from one table into another:
		if type(db) ~= "table" then db = {} end
		if type(defaults) ~= "table" then return db end
		for k, v in pairs(defaults) do
			if type(v) == "table" then
				db[k] = initDB(db[k], v)
			elseif type(v) ~= type(db[k]) then
				db[k] = v
			end
		end
		return db
	end

	-- COLOUR MIXING THROUGH ADDITION IN CMYK SPACE
	-- Modified from https://stackoverflow.com/a/30079700
	local blendColors
	do
		local RGB_scale = 255
		local CMYK_scale = 100

		local function RGB_to_CMYK(r, g, b)
			if (r == 0) and (g == 0) and (b == 0) then -- black
				return 0, 0, 0, CMYK_scale
			end

			-- RGB [0,255] -> CMY [0,1]
			local c = 1 - r / RGB_scale
			local m = 1 - g / RGB_scale
			local y = 1 - b / RGB_scale

			-- extract out K [0,1]
			local min_CMY = math.min(c, m, y)
			c = (c - min_CMY)
			m = (m - min_CMY)
			y = (y - min_CMY)
			local k = min_CMY

			-- rescale to the range [0,CMYK_scale]
			return c * CMYK_scale, m * CMYK_scale, y * CMYK_scale, k * CMYK_scale
		end

		local function CMYK_to_RGB(c, m, y, k)
			-- CMYK [0,100] -> RGB [0,255]
			local r = RGB_scale * (1 - (c + k) / CMYK_scale)
			local g = RGB_scale * (1 - (m + k) / CMYK_scale)
			local b = RGB_scale * (1 - (y + k) / CMYK_scale)
			Debug("<- NewColor: %.2f, %.2f, %.2f", r, g, b)
			return r, g, b
		end

		function blendColors(list_of_colours)
			local C, M, Y, K = 0, 0, 0, 0

			for i = 1, #list_of_colours do
				local r, g, b, o = unpack(list_of_colours[i])
				local c, m, y, k = RGB_to_CMYK(r, g, b)
				C = C + o * c
				M = M + o * m
				Y = Y + o * y 
				K = K + o * k
				Debug("-> OldColor #%d: %.2f, %.2f, %.2f", i, r, g, b)
			end

			return CMYK_to_RGB(C, M, Y, K)
		end
	end


--[[----------------------------------------------------------------------------
	EventHandler
----------------------------------------------------------------------------]]--
	local f = CreateFrame("Frame", "DMFQuest", UIParent, "ResizeLayoutFrame") -- ResizeLayoutFrame
	f:SetScript("OnEvent", function(self, event, ...)
		Debug("===", event, tostringall(...))
		return self[event] and self[event](self, event, ...)
	end)
	f:RegisterEvent("ADDON_LOADED")

	-- Init
		function f:ADDON_LOADED(event, addOnName, containsBindings)
			if addOnName ~= ADDON_NAME then return end

			DMFQConfig = initDB(DMFQConfig, dbDefaults)
			db = DMFQConfig

			self.initDone = false
			self.startTime = 0
			self.endTime = 0
			self.addonTitle = strtrim(string.format("%s %s", ADDON_NAME, C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")))
			self:RegisterEvent("PLAYER_LOGIN")

			self:UnregisterEvent(event)
			self.ADDON_LOADED = nil
		end

		function f:PLAYER_LOGIN(event)
			self:CreateUI()
			self:ClearAllPoints()
			self:SetPoint((db.GrowDirection == 1) and "BOTTOMLEFT" or "TOPLEFT", UIParent, "BOTTOMLEFT", db.XPos, db.YPos) -- 0 = Down, 1 = Up

			self:RegisterEvent("PLAYER_ENTERING_WORLD")
			--self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
			self:RegisterEvent("QUEST_LOG_UPDATE")
			self:RegisterEvent("SKILL_LINES_CHANGED")
			self:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
			self:RegisterEvent("ZONE_CHANGED")
			self:RegisterEvent("ZONE_CHANGED_INDOORS")
			self:RegisterEvent("ZONE_CHANGED_NEW_AREA")

			self:UnregisterEvent(event)
			self.PLAYER_LOGIN = nil
		end

		local eventsAlreadyRegistered = false
		function f:PLAYER_ENTERING_WORLD(event, isInitialLogin, isReloadingUi) -- Fires when the player logs in, /reloads the UI or zones between map instances. Basically whenever the loading screen appears.
			if self:CheckForPortalZone() and self:CheckForDMF() then
				if (not eventsAlreadyRegistered) then
					eventsAlreadyRegistered = true
					self:RegisterEvent("BAG_UPDATE")
					--self:RegisterEvent("MERCHANT_FILTER_ITEM_UPDATE")
					self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
					self:RegisterEvent("MERCHANT_UPDATE")
					self:RegisterEvent("QUEST_ACCEPTED")
					self:RegisterEvent("QUEST_DETAIL")
					self:RegisterEvent("QUEST_REMOVED")
					self:RegisterEvent("QUEST_DATA_LOAD_RESULT")
				end

				if self.initDone then -- Limit calls to these during Login/ReloadUI
					self:UpdateItemButtons()
					self:UpdateTextLines()
				end

				if (not self:IsShown()) then
					Debug("!!! Showing !!!", self:CheckForPortalZone(), self:CheckForDMF())
					self:Show()
				end

				return
			elseif (eventsAlreadyRegistered) then
				eventsAlreadyRegistered = false
				self:UnregisterEvent("BAG_UPDATE")
				self:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
				self:UnregisterEvent("QUEST_ACCEPTED")
				self:UnregisterEvent("QUEST_DETAIL")
				self:UnregisterEvent("QUEST_REMOVED")
				self:UnregisterEvent("QUEST_DATA_LOAD_RESULT")
			end

			if (self:IsShown()) and (not isFramePinned) then
				Debug("!!! Hiding !!!", self:CheckForPortalZone(), self:CheckForDMF())
				self:Hide()
			end
		end

		function f:QUEST_LOG_UPDATE(event) -- Fires when the quest log updates. Fires also when the player logs in or /reloads the UI
			if (not self.initDone) then
				self:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST") -- Triggers when your query has finished processing on the server and new calendar information is available.
				C_Calendar.OpenCalendar() -- Requests calendar information from the server. Does not open the calendar frame.

				self:UpdateItemButtons()
				self:UpdateProfessions()
				self:UpdateTextLines()

				self.initDone = true -- Don't do this more than once
				-- We don't actually need this, since QUEST_ACCEPTED and QUEST_REMOVED covers same things with less firing overall
				self:UnregisterEvent(event)
				self.QUEST_LOG_UPDATE = nil
			end
		end

		function f:CALENDAR_UPDATE_EVENT_LIST(event) -- Fired when Calendar data is available
			self:UnregisterEvent(event)

			if self:CheckForDMF() then
				--C_Timer.After(1, function()
					Print(GREEN_FONT_COLOR:WrapTextInColorCode(L.ChatMessage_Login_DMFWarning))
				--end)
			end

			self.CALENDAR_UPDATE_EVENT_LIST = nil
		end

	-- Professions
		function f:SKILL_LINES_CHANGED(event) -- Only fires for major changes to the list, such as learning or unlearning a skill or raising one's level from Journeyman to Master. It doesn't fire for skill rank increases.
			if self.initDone then
				self:UpdateProfessions()
				self:UpdateTextLines()
			end		
		end

		f.TRADE_SKILL_LIST_UPDATE = f.SKILL_LINES_CHANGED

	-- Zones
		-- Call PLAYER_ENTERING_WORLD, because it does the exact thing we want to do when ZONE_CHANGED* events fire
		f.ZONE_CHANGED = f.PLAYER_ENTERING_WORLD			-- Fires when the player enters an outdoors subzone.
		f.ZONE_CHANGED_INDOORS = f.PLAYER_ENTERING_WORLD	-- Fires when the player enters an indoors subzone.
		f.ZONE_CHANGED_NEW_AREA = f.PLAYER_ENTERING_WORLD	-- Fires when the player enters a new zone.

	-- Merchant
		local lastShoppingTime = 0
		local shoppingSpreeLimit = 2  -- Don't let AutoBuy fire more than once per every 2 seconds
		do -- MERCHANT throttling
			local throttling

			local function DelayedBuyItems(...)
				throttling = nil

				if f:CheckForDMF() and (f:IsShown() or (C_QuestLog.GetLogIndexForQuestID(29506) and C_QuestLog.GetLogIndexForQuestID(29506) > 0)) then -- 29506 = A Fizzy Fusion
					local timeDifference = GetTime() - lastShoppingTime
					if timeDifference > shoppingSpreeLimit then
						f:AutoBuyItems()
					else
						Debug(" !!! Block AutoBuy !!!", timeDifference)
					end
				end
				--f:UpdateTextLines() -- This shouldn't be needed, because this gets taken care of by the bags portion
			end

			local function ThrottleBuyItems(...)
				if (not throttling) then
					Debug("-- Merchant: Throttling Buy Items", ... and #(...))

					C_Timer.After(1, DelayedBuyItems)
					throttling = true
				end
			end

			f.MERCHANT_UPDATE = ThrottleBuyItems
			f.MERCHANT_FILTER_ITEM_UPDATE = ThrottleBuyItems
		end

		function f:PLAYER_INTERACTION_MANAGER_FRAME_SHOW(event, interactionType) -- Show and Hide events have been streamlined into PLAYER_INTERACTION_MANAGER_FRAME_SHOW/HIDE in 10.0
			if interactionType == Enum.PlayerInteractionType.Merchant then
				f.MERCHANT_UPDATE()
			end
		end

	-- Bags
		do -- UpdateItemButtons and UpdateTextLines throttling
			local throttling

			local function DelayedUpdateItemButtons(...)
				throttling = nil

				f:UpdateItemButtons()
				f:UpdateTextLines()
			end

			local function ThrottleUpdateItemButtons()
				if (not throttling) then
					Debug("-- Bags: Throttling Items and Quests Update")

					C_Timer.After(0.5, DelayedUpdateItemButtons)
					throttling = true
				end
			end

			f.BAG_UPDATE = ThrottleUpdateItemButtons
		end

	-- Quests
		function f:QUEST_ACCEPTED(event, questId)
			self:UpdateItemButtons()
		end

		function f:QUEST_DETAIL(event, questStartItemID) -- Fired when the player is given a more detailed view of his quest.
			if questStartItemID and turnInItems[questStartItemID] then -- Don't auto-accept any other quests than turn-in items
				Debug(" <= Found Quest")
				AcceptQuest()
			elseif questStartItemID and questStartItemID == 0 then -- At least on PTR for some reason questStartItemID is 0?
				Debug("- Falling back, arey you on PTR?")
				local questId = GetQuestID()
				for _, qId in pairs(turnInItems) do
					if qId == questId then
						Debug("  <== Found Quest")
						AcceptQuest()
						break
					end
				end
			end
		end

		function f:QUEST_REMOVED(event, questID, wasReplayQuest)
			self:UpdateItemButtons()
		end

		local questDataRequests = {}
		-- Check if out previously requested QuestData from f:UpdateTextLines() has arrived
		function f:QUEST_DATA_LOAD_RESULT(questID, success)
			if questDataRequests[questID] then --and success then -- At least on PTR success always seems to return false
				questDataRequests[questID] = nil
				self:UpdateTextLines()
			end
		end


--[[----------------------------------------------------------------------------
	Functions
----------------------------------------------------------------------------]]--
	-- Create UI
	local function _onEnterShowTooltip(self, motion) -- Show Tooltip
		self.buttonIcon:SetVertexColor(buttonVertices[self.itemStatus][4], buttonVertices[self.itemStatus][5], buttonVertices[self.itemStatus][6])
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(self.tooltipText)
		if db.ShowItemRewards and (self.itemStatus ~= 1) then -- Don't show rewards for already completed quests
			local info = C_CurrencyInfo.GetCurrencyInfo(515)
			local count = rewardsTable[self.itemId] or "?"
			GameTooltip:AddLine(GARRISON_MISSION_REWARD_HEADER .. " |T".. info.iconFileID ..":16:16:0:0:32:32:2:30:2:30|t " .. count .. " " .. info.name) -- 134481, Darkmoon Prize Ticket
		end
		GameTooltip:Show() -- Region:Show() resizes the tooltip and reapplies any anchor defined with SetOwner().
	end

	local function _onLeaveHideTooltip(self, motion) -- Hide Tooltip
		self.buttonIcon:SetVertexColor(buttonVertices[self.itemStatus][1], buttonVertices[self.itemStatus][2], buttonVertices[self.itemStatus][3])
		GameTooltip:Hide()
	end

	function f:CreateUI()
		Debug("CreateUI")
		self.fixedWidth = 324
		self.minimumHeight = 150
		self.heightPadding = 72 -- (TopBorder 2px, Title 20px, TopSeparator 2px) + (TopPadding 6px, Text [Dynamic], BottomPadding 6px) + (BottomSeparator 2px, Buttons 32px, BottomBorder 2px)

		--[[
		Texture Slicing (New in 10.2)
		-----------------------------
		This system is recommended to be used in new code going forward as a replacement for both the deprecated Backdrop system
		and the script-based NineSlice panel layout utility. One of the advantages of this new system is that it only requires a
		single texture object to render the grid, whereas both the old systems required nine separate objects. This system is
		fully compatible with custom texture assets and does not require the use of atlases.
		]]
		-- Background
		local backgroundTex = self:CreateTexture()
		backgroundTex:SetTexture("Interface\\AddOns\\DMFQuest\\BackgroundTexture8x64.png")
		backgroundTex:SetTextureSliceMargins(2, 24, 2, 36) -- left, top, right, bottom
		backgroundTex:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
		backgroundTex:SetAllPoints(self)
		backgroundTex:SetVertexColor(db.FrameVertexColor[1], db.FrameVertexColor[2], db.FrameVertexColor[3])
		self.Background = backgroundTex

		-- TitleText
		local titleText = self:CreateFontString(nil, "OVERLAY", "GameFontNormal") -- FontSize 12
		titleText:SetPoint("CENTER", self, "TOP", 0, -12)
		titleText:SetText(self.addonTitle)
		self.TitleText = titleText

		-- Drag
		self:SetMovable(true)
		self:SetClampedToScreen(true)
		self:EnableMouse(true)
		self:RegisterForDrag("LeftButton")

		self:SetScript("OnDragStart", function(self, button) -- self, button
			if db.FrameLock then return end

			self.StartMoving(self, button)
		end)
		self:SetScript("OnDragStop", function(self) -- self
			self:StopMovingOrSizing()

			db.XPos = self:GetLeft()
			db.YPos = (db.GrowDirection == 1) and self:GetBottom() or self:GetTop() -- 0 = Down, 1 = Up

			self:ClearAllPoints()
			self:SetPoint((db.GrowDirection == 1) and "BOTTOMLEFT" or "TOPLEFT", UIParent, "BOTTOMLEFT", db.XPos, db.YPos) -- 0 = Down, 1 = Up
		end)
		self:SetScript("OnHide", f.StopMovingOrSizing)

		-- CloseButton
		local closeButton = CreateFrame("Button", nil, self, "UIPanelCloseButton")
		closeButton:SetSize(28, 28)
		closeButton:SetPoint("TOPRIGHT", 2, 1)
		closeButton:GetNormalTexture():SetVertexColor(
			blendColors(
				{
					{ db.FrameVertexColor[1], db.FrameVertexColor[2], db.FrameVertexColor[3], .5 },
					{ 1, 1, 1, .5 }
				}
			)
		)
		self.CloseButton = closeButton

		-- CloseButton doesn't make sound when clicked
		closeButton:SetScript("OnClick", function(self, button, down)
			Debug("CloseButton OnClick", self:GetParent():GetName(), button, down)
			--PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
			PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
			--self:GetParent():Hide()
			f:Hide()
			isFramePinned = false
			f.TitleText:SetText(f.addonTitle)
		end)

		-- ItemButtons
		for i = 1, #itemButtonOrder do
			local b = CreateFrame("Button", nil, self)
			b:SetSize(32, 32)

			b.tooltipText = ""
			b.itemStatus = 4
			b:SetScript("OnEnter", _onEnterShowTooltip)
			b:SetScript("OnLeave", _onLeaveHideTooltip)

			local tex = b:CreateTexture()
			tex:SetAllPoints()
			b.buttonIcon = tex

			b:SetPoint("BOTTOMLEFT", (i - 1) * 32 + 2, 2)

			local item = Item:CreateFromItemID(itemButtonOrder[i])
			item:ContinueOnItemLoad(function()
				b.itemId = itemButtonOrder[i]
				b.itemName = item:GetItemName() 
				b.itemLink = item:GetItemLink()

				local tex = item:GetItemIcon()
				b.buttonIcon:SetTexture(tex)

				Debug(" - Button", i, b.itemName)
			end)

			self["itemButton" .. i] = b
			self:MarkIgnoreInLayout(b) -- Ignore these objects when calculating the size for the Frame
		end

		-- Profession Container
		local prefessionContainer = CreateFrame("Frame", nil, self, "ResizeLayoutFrame") -- ResizeLayoutFrame
		prefessionContainer.fixedWidth = 320
		prefessionContainer.minimumHeight = 50
		prefessionContainer:SetPoint("TOP", 0, -24)
		self.Container = prefessionContainer

		-- TextLine
		local containerText = self:CreateFontString(nil, "OVERLAY", "Game15Font_o1") -- "GameFontHighlight")
		containerText:SetPoint("CENTER", 0, 6) -- Y-offset is the size difference between the Title+Button Bars (with edges) and the Frame minimum size divided by two ((72-60)/2) and maybe adjusted by one (+1) to make the text look more natural
		containerText:SetText("\n" .. ADDON_NAME .. " Loaded!\n\n")
		--containerText:SetText(ADDON_NAME .. " Loaded!\n\n§1234567890+´+\n½!\"#¤%&/()=?`\n\nqwertyuiopå¨\nQWERTYUIOPÅ^\n\nasdfghjklöä'\nASDFGHJKLÖÄ*\n\n<zxcvbnm,.-\n>ZXCVBNM;:_") -- Debug
		self.ContainerText = containerText

		self:MarkIgnoreInLayout(backgroundTex, titleText, closeButton, containerText) -- Ignore these objects when calculating the size for the Frame

		--self:Show()
		self:Layout() -- Resize UI
		self.CreateUI = nil
	end

	-- CheckForDMF
	local function _shiftTimeTables(timeData) -- Shift timeData if needed
		if (not db.UseTimeOffset) then
			return timeData
		end

		timeData.hour = timeData.hour + db.TimeOffsetValue

		if timeData.hour < 0 then
			timeData.monthDay = timeData.monthDay - 1
			timeData.hour = timeData.monthDay + 24
		elseif timeData.hour > 23 then
			timeData.monthDay = timeData.monthDay + 1
			timeData.hour = timeData.hour - 24
		end

		local monthInfo = C_Calendar.GetMonthInfo(0)
		local previousMonthInfo = C_Calendar.GetMonthInfo(-1)

		if timeData.monthDay <= 0 then
			timeData.month = timeData.month - 1
			timeData.monthDay = previousMonthInfo.numDays
		elseif timeData.monthDay > monthInfo.numDays then
			timeData.month = timeData.month + 1
			timeData.monthDay = 1
		end

		if timeData.month <= 0 then
			timeData.year = timeData.year - 1
			timeData.month = 12
		elseif timeData.month > 12 then
			timeData.year = timeData.year + 1
			timeData.month = 1
		end

		return timeData
	end

	local function _epochToHumanReadable(epoch) -- Turn epoch into Human readable
		local mins, hours, days, returnString = 0, 0, 0, ""

		while epoch >= 86400 do
			days = days + 1
			epoch = epoch - 86400
		end
		if days > 0 then
			returnString = returnString .. string.format("%d %s, ", days, days > 1 and "days" or "day")
		end

		while epoch >= 3600 do
			hours = hours + 1
			epoch = epoch - 3600
		end
		if hours > 0 then
			returnString = returnString .. string.format("%d %s, ", hours, hours > 1 and "hours" or "hour")
		end

		while epoch >= 60 do
			mins = mins + 1
			epoch = epoch - 60
		end
		if mins > 0 then
			returnString = returnString .. string.format("%d %s, ", mins, mins > 1 and "mins" or "min")
		end
		if epoch > 0 then
			returnString = returnString .. string.format("%d %s", epoch, epoch > 1 and "secs" or "sec")
		end

		return strtrim(returnString, " ,")
	end

	function f:CheckForDMF() -- Check Calendar for if DMF is on
		Debug("CheckForDMF")

		local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime()
		--[[
			CalendarTime
			Field		Type	Description
			year		number	The current year (e.g. 2019)
			month		number	The current month [1-12]
			monthDay	number	The current day of the month [1-31]
			weekday		number	The current day of the week (1=Sunday, 2=Monday, ..., 7=Saturday)
			hour		number	The current time in hours [0-23]
			minute		number	The current time in minutes [0-59]
		]]--
		if self.startTime > 0 and self.endTime > 0 then
			if (db.debug and db.isPTR) then currentCalendarTime.monthDay = 7 end -- PTR Debug
			currentCalendarTime.day = currentCalendarTime.monthDay
			local currentEpoch = time(currentCalendarTime)

			if currentEpoch >= self.startTime and currentEpoch <= self.endTime then
				Debug(" <= Exit via shortcut:", _epochToHumanReadable(currentEpoch - self.startTime), "<-", currentEpoch, "->", _epochToHumanReadable(self.endTime - currentEpoch))
				return true
			end

			Debug("- Reset startTime and endTime:", _epochToHumanReadable(currentEpoch - self.startTime), "<-", currentEpoch, "->", _epochToHumanReadable(self.endTime - currentEpoch))
			self.startTime = 0
			self.endTime = 0
		end

		local searchResult, openMonth, openYear
		if CalendarFrame and CalendarFrame:IsShown() then -- Get current open month in calendar view
			Debug("- Save Open")
			local monthInfo = C_Calendar.GetMonthInfo()
			openMonth, openYear = monthInfo.month, monthInfo.year
		end
		C_Calendar.SetAbsMonth(currentCalendarTime.month, currentCalendarTime.year)

		currentCalendarTime = _shiftTimeTables(currentCalendarTime)
		Debug("- Date and Time: %d.%d.%d   %d:%d (%s%d)", currentCalendarTime.year, currentCalendarTime.month, currentCalendarTime.monthDay, currentCalendarTime.hour, currentCalendarTime.minute, db.TimeOffsetValue < 0 and "-" or "+", db.TimeOffsetValue)
		if (db.debug and db.isPTR) then currentCalendarTime.monthDay = 7 end -- PTR Debug
		local numDayEvents = C_Calendar.GetNumDayEvents(0, currentCalendarTime.monthDay)

		Debug("- Check HolidayInfo")
		for i = 1, numDayEvents do
			local holidayData = C_Calendar.GetHolidayInfo(0, currentCalendarTime.monthDay, i)

			local texture = (holidayData and holidayData.texture) and holidayData.texture or 0

			Debug("  -- ", i, "/", numDayEvents, "-", texture)
			if texture == 235448 or texture == 235447 or texture == 235446 then -- DMF begin, middle, end
				Debug("  <== Found DMF: %d.-%d.%d.%d", holidayData.startTime.monthDay, holidayData.endTime.monthDay, holidayData.startTime.month, holidayData.startTime.year)
				holidayData.startTime.day = holidayData.startTime.monthDay
				holidayData.endTime.day = holidayData.endTime.monthDay
				self.startTime = time(holidayData.startTime)
				self.endTime = time(holidayData.endTime)

				if db.UseTimeOffset then
					self.startTime = self.startTime + (db.TimeOffsetValue * 3600)
					self.endTime = self.endTime + (db.TimeOffsetValue * 3600)
				end

				searchResult = true
				break
			end
		end

		if openMonth and openYear then -- Restore previously open month in calendar view
			Debug("- Restore Open")
			C_Calendar.SetAbsMonth(openMonth, openYear)
		end

		return (searchResult == true)
	end

	-- CheckForPortalZone
	local cacheAreaNames = {}
	f.cacheAreaNames = cacheAreaNames -- Debug
	-- With default PTR settings for my machine (Draw Distance 3)
	-- Portal disappears around 415-420yd
	-- Portal appears around 375-400+yd
	local portalDistance = 800 -- Just to be safe
	-- UnitPosition: posY, posX, posZ (always 0), instanceId (1 for Kalimdor) - We don't use last two
	local function _isPortalInRange(portalX, portalY, playerX, playerY)
		if not portalX or not portalY or not playerX or not playerY then
			return false
		end

		local deltaX, deltaY = playerX - portalX, playerY - portalY
		local distance = (deltaX * deltaX + deltaY * deltaY)^0.5
		if db.isPTR then
			Debug("  --> _isPortalInRange: %.2f (%.2f, %.2f) %s", distance, deltaX, deltaY, tostring(distance <= portalDistance))
		end
		f.portalDistance = distance
		return distance <= portalDistance
	end

	function f:CheckForPortalZone() -- Check if we are  near DMF Portal area
		Debug("CheckForPortalZone")

		local uiMapID = C_Map.GetBestMapForUnit("player")
		if uiMapID then
			local info = C_Map.GetMapInfo(uiMapID)
			local subZone = GetMinimapZoneText() --GetSubZoneText()
			local subZoneMatch = false
			Debug("- Map", uiMapID, info.name, info.mapType, subZone)

			if subZoneAreaIDs[uiMapID] then
				Debug("- Search for subZoneMatch")
				for i = 1, #subZoneAreaIDs[uiMapID] do
					Debug("  -- ", i, "/", #subZoneAreaIDs[uiMapID], "-", subZoneAreaIDs[uiMapID][i], C_Map.GetAreaInfo(subZoneAreaIDs[uiMapID][i]))
					local areaName = cacheAreaNames[subZoneAreaIDs[uiMapID][i]] or C_Map.GetAreaInfo(subZoneAreaIDs[uiMapID][i]) -- Check if we have cached this areaName already
					if (areaName == subZone) or (uiMapID == 7 and info.name == subZone) then
						cacheAreaNames[subZoneAreaIDs[uiMapID][i]] = cacheAreaNames[subZoneAreaIDs[uiMapID][i]] or areaName -- Cache areaName for later use to reduce function calls
						subZoneMatch = true
						Debug("  <== Found subZoneMatch:", subZoneAreaIDs[uiMapID][i], subZone)
						break
					end
				end
			end

			--[[
				/dump C_Map.GetBestMapForUnit("player")
				/dump C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player"))
				/dump C_MapExplorationInfo.GetExploredAreaIDsAtPosition(7, C_Map.GetPlayerMapPosition(7, "player"))
				/dump C_Map.GetAreaInfo(1638)

				Mulgore Portal
				/dump UnitPosition("player")
				x, y = -1472, 196
				/dump format("%.5f x %.5f", C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player"):GetXY())
				x, y= .36852, .35870
			]]--
			if
				(uiMapID == 37 or uiMapID == 88 or uiMapID == 7) -- Elwynn Forrest // Thunder Bluff // Mulgore
			and
				subZoneMatch -- Goldshire or Lion's Pride Inn // Thunder Bluff, Any of the Rises or The Cat and the Shaman // Special handling for Mulgore
			then
				if db.isPTR then -- PTR Debug
					local position = C_Map.GetPlayerMapPosition(uiMapID, "player")
					local areaID = C_MapExplorationInfo.GetExploredAreaIDsAtPosition(uiMapID, position)
					Debug("-- Check areaIDs")
					if areaID then
						for i = 1, #areaID do
							Debug("  -- ", i, "/", #areaID, "-", areaID[i], C_Map.GetAreaInfo(areaID[i]))
						end
					end
				end

				if uiMapID == 7 then -- Weird stuff happens in Mulgore
					return _isPortalInRange(-1472, 196, UnitPosition("player"))
				end

				return true
			end
		end

		return false
	end

	-- UpdateItemButtons
	local function _onClickNoop(self, button, down) return end -- No Operation

	local function _onClickUseItem(self, button, down) -- Find item from your backbags and use it
		if (not InCombatLockdown()) then
			local itemId = self.itemId
			local bag, slot = 0, 0
			for bag = Enum.BagIndex.Backpack, Constants.InventoryConstants.NumBagSlots do -- 0, 4
				for slot = 1, C_Container.GetContainerNumSlots(bag) do
					if C_Container.GetContainerItemID(bag, slot) == itemId then
						C_Container.UseContainerItem(bag, slot)
						return
					end
				end
			end
		end
	end

	function f:UpdateItemButtons() -- Update turnInItem-buttons
		Debug("UpdateItemButtons")
		for i = 1, #itemButtonOrder do
			local button = self["itemButton" .. i]
			local itemId = button.itemId
			local questId = turnInItems[itemId]
			local itemLink = button.itemLink

			if questId and C_QuestLog.IsQuestFlaggedCompleted(questId) or (db.debug and db.isPTR and i == 6) then -- Quest Done
				Debug("- %d QuestDone", i)
				button.tooltipText = L.Quest_QuestDone
				button.itemStatus = 1

			elseif questId and C_QuestLog.IsOnQuest(questId) or (db.debug and db.isPTR and i == 7) then -- On Quest
				Debug("- %d OnQuest", i)
				button.tooltipText = L.Quest_QuestReady
				button.itemStatus = 2

			elseif questId and GetItemCount(itemId) > 0 or (db.debug and db.isPTR and i == 8) then -- Item, not on Quest (yet)
				Debug("- %d ItemNoQuest", i)
				button.tooltipText = L.Quest_QuestReadyToAccept
				button.itemStatus = 3

			else -- No item
				Debug("- %d NoItem", i)
				button.tooltipText = string.format(L.Quest_QuestNoItem, itemLink and itemLink or itemId and itemId or "n/a")
				button.itemStatus = 4

			end

			if button.itemStatus == 3 then -- Item, not on Quest
				button:SetScript("OnClick", _onClickUseItem)
			else
				button:SetScript("OnClick", _onClickNoop)
			end
			button.buttonIcon:SetVertexColor(buttonVertices[button.itemStatus][1], buttonVertices[button.itemStatus][2], buttonVertices[button.itemStatus][3])
		end
	end

	-- UpdateTextLines
	local cacheItemNames = {}
	f.cacheItemNames = cacheItemNames -- Debug

	local numTextLinesWaitingForServerData = 0
	local textLinesWaitingForServerData = {}

	local activeStrings = {}
	local function poolReset(_, stringObject)
		stringObject:Hide()
	end
	local stringPool = CreateFontStringPool(f, "OVERLAY", 0, "GameFontHighlight", poolReset)
	local function _getTextLine(textFormat, ...)
		local s = stringPool:Acquire()
		s:SetFormattedText(textFormat, ...)
		activeStrings[#activeStrings + 1] = s
		s:SetParent(f.Container)
		if #activeStrings == 1 then
			s:SetPoint("TOP", 0, -6)
		else
			s:SetPoint("TOP", activeStrings[#activeStrings - 1], "BOTTOM", 0, -6)
		end
		s:Show()

		return
	end
	local delayLock = false
	local function _delayedUpdateTextLines()
		if not delayLock then
			delayLock = true
			C_Timer.After(0, f.UpdateTextLines) -- Wait until next frame
		end
	end

	local updateCount = 0
	function f:UpdateTextLines() -- Update textLine to reflect Quest progress
		Debug("UpdateTextLines")
		delayLock = false

		if updateCount == 0 then
			-- Release previously used FontStrings
			Debug(" -> PRE:", #activeStrings)
			for s = #activeStrings, 1, -1 do
				stringPool:Release(activeStrings[s])
				activeStrings[s] = nil
			end
			Debug(" -> POST:", #activeStrings)

			-- Iterate Professions
			local profCount = 0
			for j = 1, 6 do
				if ProfData and ProfData[j] then
					Debug(" -->", j, ProfData[j].name, "OK")
					profCount = profCount + 1
				end
			end
			Debug(" -> Data: %d / %d", #ProfData, profCount)
		end

		--for i = 1, #ProfData do
		for i = 1, 6 do
			local prof = ProfData[i]

			if prof and prof.professionId then
				Debug("- %d %s (%d) %d/%d", i, prof.name, prof.professionId, prof.skillLevel, prof.maxSkillLevel)
				if prof.maxSkillLevel == 0 and updateCount < 5 then
					updateCount = updateCount + 1
					Debug(" !!! maxSkillLevel 0 !!!", updateCount)
					f:UpdateProfessions(true)
					return
				end

				local questData = ProfessionQuestData[prof.professionId]
				local showThisProfession = true
				local skillLineText, questItemText = "", ""

				if db.HideMax and prof.skillLevel == prof.maxSkillLevel then -- Skip if Maxed professions
					showThisProfession = false
				elseif C_QuestLog.IsQuestFlaggedCompleted(questData.questId) then -- Quest already done
					skillLineText = string.format("%d / %d\n%s", prof.skillLevel, prof.maxSkillLevel, GREEN_FONT_COLOR:WrapTextInColorCode(L.Quest_QuestDone))
				elseif prof.skillLevel >= minimumSkillRequired then -- Quest not done, enough skill to get the quest
					skillLineText = string.format("%d / %d", prof.skillLevel, prof.maxSkillLevel)

					if (prof.maxSkillLevel - prof.skillLevel) < 5 and prof.maxSkillLevel < currentSkillCap then -- In danger to waste skillpoints by capping
						skillLineText = ORANGE_FONT_COLOR:WrapTextInColorCode(skillLineText)
					end

					if prof.professionId == 794 then -- Archaeology
						for currencyId, requiredAmount in pairs(questData.questCurrency) do
							local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyId)
							if currencyInfo.quantity < requiredAmount then -- Not enough currency
								questItemText = currencyInfo.name .. RED_FONT_COLOR:WrapTextInColorCode(string.format(" %d / %d", currencyInfo.quantity, requiredAmount))
							else
								questItemText = currencyInfo.name .. GREEN_FONT_COLOR:WrapTextInColorCode(string.format(" %d / %d", currencyInfo.quantity, requiredAmount))
							end
						end
					elseif questData.questItems and next(questData.questItems) then -- This quest requires items
						for itemId, requiredAmount in pairs(questData.questItems) do
							local itemCount = GetItemCount(itemId)
							local itemName
							if cacheItemNames[itemId] then
								itemName = cacheItemNames[itemId]
							else -- itemName not yet cached from UpdateProfessions, keep waiting
								if (not textLinesWaitingForServerData[itemId]) then
									numTextLinesWaitingForServerData = numTextLinesWaitingForServerData + 1
									textLinesWaitingForServerData[itemId] = 1
									Debug("  -- Waiting for ContinueOnItemLoad: %d | Total: %d", itemId, numTextLinesWaitingForServerData) -- Debug
								else
									textLinesWaitingForServerData[itemId] = textLinesWaitingForServerData[itemId] + 1
									Debug("  -- STILL Waiting for ContinueOnItemLoad: %d x %d | Total: %d", itemId, textLinesWaitingForServerData[itemId], numTextLinesWaitingForServerData) -- Debug
								end
							end

							if itemName then
								if itemCount < requiredAmount then -- Not enough items
									questItemText = questItemText .. "\n" .. itemName .. RED_FONT_COLOR:WrapTextInColorCode(string.format(" %d / %d", itemCount, requiredAmount))
								else
									questItemText = questItemText .. "\n" .. itemName .. GREEN_FONT_COLOR:WrapTextInColorCode(string.format(" %d / %d", itemCount, requiredAmount))
								end
							end
						end
					else -- Quest doesn't require items
						questItemText = GREEN_FONT_COLOR:WrapTextInColorCode(L.Profession_NoItemsNeeded)
					end
				else -- Skill under minimum requirement
					if db.HideLow then
						showThisProfession = false
					else
						skillLineText = RED_FONT_COLOR:WrapTextInColorCode(string.format("%d / %d\n%s", prof.skillLevel, prof.maxSkillLevel, L.Profession_SkillTooLow))
					end
				end

				if showThisProfession then
					_getTextLine("|T%d:0|t %s - %s\n%s", prof.icon, prof.name, skillLineText, strtrim(questItemText))
				end
			else -- No profession
				Debug("- %d - !!! No profession !!!", i)
				if (not db.HideLow) then
					_getTextLine("%s\n\n", RED_FONT_COLOR:WrapTextInColorCode(L.Profession_NoProfessions))
				end
			end
		end

		-- Additional Quests
		if db.PetBattle then
			local questIcon = additionalQuests.PetBattle.Icon
			local questCount, questMaxCount = 0, #additionalQuests.PetBattle.QuestIdTable
			for _, questId in ipairs(additionalQuests.PetBattle.QuestIdTable) do
				if C_QuestLog.IsQuestFlaggedCompleted(questId) then
					questCount = questCount + 1
				end
			end

			local petBattleTextColor = (questCount == questMaxCount) and GREEN_FONT_COLOR or (questCount > 0) and ORANGE_FONT_COLOR or RED_FONT_COLOR
			local petBattleQuestTextLine = petBattleTextColor:WrapTextInColorCode(string.format("%d / %d", questCount, questMaxCount))

			Debug("- PetBattle - %s %d / %d", SHOW_PET_BATTLES_ON_MAP_TEXT, questCount, questMaxCount)
			_getTextLine("|T%d:0|t %s\n%s %s %s\n", questIcon, SHOW_PET_BATTLES_ON_MAP_TEXT, strtrim(petBattleQuestTextLine), SHOW_PET_BATTLES_ON_MAP_TEXT, L.Quest_ActivityDone)
		end

		if db.DeathMetalKnight then
			local questId = additionalQuests.DeathMetalKnight.QuestId
			local questIcon = additionalQuests.DeathMetalKnight.Icon
			local questDone = C_QuestLog.IsQuestFlaggedCompleted(questId)

			local questTitle = L.QuestTitleFix_DeathMetalKnight -- API doesn't return questName for this hidden quest
			--[[
			local questTitle = C_QuestLog.GetTitleForQuestID(questId)
			if (not questTitle) and (not questDataRequests[questId]) then -- Request only once
				C_QuestLog.RequestLoadQuestByID(questId)
				questDataRequests[questId] = true
			end
			]]
			local textColor = questDone and GREEN_FONT_COLOR or RED_FONT_COLOR
			local questTextLine = textColor:WrapTextInColorCode(questDone and L.Quest_QuestDone or L.Quest_QuestNotDone)

			Debug("- DeathMetalKnight - %s %s", questTitle or "DMKtitle n/a", tostring(questDone))
			_getTextLine("|T%d:0|t %s\n%s", questIcon, questTitle or "DMKtitle n/a", strtrim(questTextLine))
		end

		if db.TestYourStrength then
			local questId = additionalQuests.TestYourStrength.QuestId
			local questIcon = additionalQuests.TestYourStrength.Icon
			local questDone = C_QuestLog.IsQuestFlaggedCompleted(questId)
			local questProgressText, _, _, fulfilled, required = GetQuestObjectiveInfo(questId, 1, false)

			local questTitle = C_QuestLog.GetTitleForQuestID(questId)
			if (not questTitle) and (not questDataRequests[questId]) then -- Request only once
				C_QuestLog.RequestLoadQuestByID(questId)
				questDataRequests[questId] = true
			end

			local textColor = questDone and GREEN_FONT_COLOR or fulfilled == required and ORANGE_FONT_COLOR or RED_FONT_COLOR
			local questTextLine = textColor:WrapTextInColorCode(questDone and L.Quest_QuestDone or questProgressText or L.Quest_QuestNotDone)

			Debug("- TestYourStrength - %s %s (%s - %d / %d)", questTitle or "TYStitle n/a", tostring(questDone), tostring(questProgressText), tostring(fulfilled), tostring(required))
			_getTextLine("|T%d:0|t %s\n%s", questIcon, questTitle or "TYStitle n/a", strtrim(questTextLine))
		end

		if db.FadedTreasureMap then
			local questStartItemId = additionalQuests.FadedTreasureMap.StartItemId

			local itemName
			if cacheItemNames[questStartItemId] then
				itemName = cacheItemNames[questStartItemId]
			else -- itemName not yet cached from UpdateProfessions, keep waiting
				if (not textLinesWaitingForServerData[questStartItemId]) then
					numTextLinesWaitingForServerData = numTextLinesWaitingForServerData + 1
					textLinesWaitingForServerData[questStartItemId] = 1
					Debug("  -- Waiting for ContinueOnItemLoad: %d | Total: %d", questStartItemId, numTextLinesWaitingForServerData) -- Debug
				else
					textLinesWaitingForServerData[questStartItemId] = textLinesWaitingForServerData[questStartItemId] + 1
					Debug("  -- STILL Waiting for ContinueOnItemLoad: %d x %d | Total: %d", questStartItemId, textLinesWaitingForServerData[questStartItemId], numTextLinesWaitingForServerData) -- Debug
				end
			end

			local questId = additionalQuests.FadedTreasureMap.QuestId
			local questIcon = additionalQuests.FadedTreasureMap.Icon
			local questDone = C_QuestLog.IsQuestFlaggedCompleted(questId)
			local textColor = questDone and GREEN_FONT_COLOR or RED_FONT_COLOR
			local questTextLine = textColor:WrapTextInColorCode(questDone and L.Quest_QuestDone or L.Quest_QuestNotDone)

			Debug("- FadedTreasureMap - %s %s", itemName or "FTMtitle n/a", tostring(questDone))
			_getTextLine("|T%d:0|t %s\n%s", questIcon, itemName or "FTMtitle n/a", strtrim(questTextLine))
		end

		updateCount = 0
		f.ContainerText:Hide() -- Hide this if it is still showing
		f:Layout() -- Resize UI
	end

	-- UpdateProfessions
	f.ProfData = ProfData -- Debug

	local additionalQuestItemsDone = false

	function f:UpdateProfessions(forceUpdateTextLines)
		Debug("UpdateProfessions", forceUpdateTextLines and "true" or "")

		local textLinesWaitingChanged = false
		local goodResults = 0
		for index, professionIndex in pairs({ GetProfessions() }) do -- prof1, prof2, archaeology, fishing, cooking
			if professionIndex then
				local name, icon, skillLevel, maxSkillLevel, _, _, skillLine = GetProfessionInfo(professionIndex)

				if (not ProfData[index]) then
					ProfData[index] = {
						name = name,
						icon = icon,
						skillLevel = 0,
						maxSkillLevel = 0,
						professionId = skillLine
					}
				else
					ProfData[index].skillLevel = 0
					ProfData[index].maxSkillLevel = 0
				end

				if index ~= 3 then
					for _, skillLineId in ipairs(ProfessionTradeSkillLines[skillLine]) do
						local skillInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineId)
						if skillInfo and skillInfo.maxSkillLevel and skillInfo.maxSkillLevel > 0 then
							goodResults = goodResults + 1
							ProfData[index].skillLevel = ProfData[index].skillLevel + skillInfo.skillLevel
							ProfData[index].maxSkillLevel = ProfData[index].maxSkillLevel + skillInfo.maxSkillLevel
						end

					end

					-- Cache itemNames of the items needed for this professions Quest
					if ProfessionQuestData[skillLine].questItems and next(ProfessionQuestData[skillLine].questItems) then -- This quest requires items
						for itemId in pairs(ProfessionQuestData[skillLine].questItems) do
							if (not cacheItemNames[itemId]) then
								local item = Item:CreateFromItemID(itemId)
								item:ContinueOnItemLoad(function()
									local itemName = item:GetItemName()
									cacheItemNames[itemId] = itemName
									if textLinesWaitingForServerData[itemId] then
										numTextLinesWaitingForServerData = numTextLinesWaitingForServerData - 1
										textLinesWaitingForServerData[itemId] = nil
										textLinesWaitingChanged = true
									end
									Debug("  -- Caching: %s (%d) | Waiting: %d", itemName, itemId, numTextLinesWaitingForServerData) -- Debug
									if (textLinesWaitingChanged) and numTextLinesWaitingForServerData == 0 then
										--f:UpdateTextLines()
										_delayedUpdateTextLines()
									end
								end)
							end
						end
					end

				else -- Archeology returns proper info without iterating skillLineIds
					ProfData[index].skillLevel = skillLevel
					ProfData[index].maxSkillLevel = maxSkillLevel
				end
				Debug("- %s (%d) %d/%d", name, skillLine, ProfData[index].skillLevel, ProfData[index].maxSkillLevel)
			end
		end

		-----

		if (not additionalQuestItemsDone) then -- Cache also questStartingItems from additionalQuests if we haven't done so yet
			additionalQuestItemsDone = true
			Debug("-> Caching questStartingItems from additionalQuests")
			for _, questData in pairs(additionalQuests) do
				if questData and questData.StartItemId then
					if (not cacheItemNames[questData.StartItemId]) then
						local item = Item:CreateFromItemID(questData.StartItemId)
						item:ContinueOnItemLoad(function()
							local itemName = item:GetItemName()
							cacheItemNames[questData.StartItemId] = itemName
							if textLinesWaitingForServerData[questData.StartItemId] then
								numTextLinesWaitingForServerData = numTextLinesWaitingForServerData - 1
								textLinesWaitingForServerData[questData.StartItemId] = nil
								textLinesWaitingChanged = true
							end
							Debug("  -- Caching: %s (%d) | Waiting: %d", itemName, questData.StartItemId, numTextLinesWaitingForServerData) -- Debug
							if (textLinesWaitingChanged) and numTextLinesWaitingForServerData == 0 then
								--f:UpdateTextLines()
								_delayedUpdateTextLines()
							end
						end)
					end
				end
			end
		end

		-----

		if (forceUpdateTextLines) and goodResults > 0 then
			Debug(" --> goodResults", goodResults)
			_delayedUpdateTextLines()
		end
	end

	function f:AutoBuyItems()
		if (not db.AutoBuy) then return end
		Debug("AutoBuyItems")

		local totalCost = 0
		local receiptTitleForAutoBuyShown = false

		--for i = 1, #ProfData do
		for i = 1, 6 do
			local prof = ProfData[i]

			-- Check we have profession, we are at or above minimum skillLevel and the profession isn't Archaeology because it uses currency instead of items for turn in
			if prof and prof.professionId and prof.skillLevel >= minimumSkillRequired and prof.professionId ~= 794 then
				Debug("%s (%d) %d", prof.name, prof.professionId, prof.skillLevel)
				local questData = ProfessionQuestData[prof.professionId]

				-- Quest not done, this quest requires items
				if (not C_QuestLog.IsQuestFlaggedCompleted(questData.questId)) and questData.questItems and next(questData.questItems) then
					for itemId, materialNeeds in pairs(questData.questItems) do
						local buyCount = materialNeeds - GetItemCount(itemId)

						if buyCount > 0 then -- We need to buy more of this item
							Debug(" - Looking for %d x %d", buyCount, itemId)
							for j = 1, GetMerchantNumItems() do
								local itemLink = GetMerchantItemLink(j)

								if itemLink and itemId == GetMerchantItemID(j) then -- Found item we want
									local maxStack = GetMerchantItemMaxStack(j)
									local itemName, _, itemPrice, itemQuantity, numAvailable = GetMerchantItemInfo(j)

									if numAvailable ~= -1 then -- -1 == unlimited amount available
										buyCount = math.min(buyCount, numAvailable) -- Check if there is enough for our needs, if not, we buy everything
									end

									-- Check if we need to buy stuff in full stacks and we can afford it
									while buyCount >= maxStack and (numAvailable >= maxStack or numAvailable == -1) and GetMoney() >= (maxStack / itemQuantity * itemPrice) do
										if (not db.isPTR) then -- PTR Debug
											BuyMerchantItem(j, maxStack)
										end
										buyCount = buyCount - maxStack
										totalCost = totalCost + (maxStack / itemQuantity * itemPrice)

										Debug(" --> Buy (maxStack): %d x %s (%d) | Q: %d, P: %d, T: %d", maxStack, itemName, itemId, itemQuantity, itemPrice, (maxStack / itemQuantity * itemPrice))
										if (not receiptTitleForAutoBuyShown) then
											receiptTitleForAutoBuyShown = true
											Print(L.Config_ExtraFeatures_AutoBuy)
											Print("- - - - - - - - - - - - - - -")
										end
										Print("   %d x %s", maxStack, itemLink)
									end

									-- Buy smaller quantities of items if still needed and we can afford it
									if buyCount > 0 and (numAvailable >= buyCount or numAvailable == -1) and GetMoney() >= (buyCount / itemQuantity * itemPrice) then
										if (not db.isPTR) then -- PTR Debug
											BuyMerchantItem(j, buyCount)
										end
										totalCost = totalCost + (buyCount / itemQuantity * itemPrice)

										Debug(" --> Buy: %d x %s (%d) | Q: %d, P: %d, T: %d", buyCount, itemName, itemId, itemQuantity, itemPrice, (buyCount / itemQuantity * itemPrice))
										if (not receiptTitleForAutoBuyShown) then
											receiptTitleForAutoBuyShown = true
											Print(L.Config_ExtraFeatures_AutoBuy)
											Print("- - - - - - - - - - - - - - -")
										end
										Print("   %d x %s", buyCount, itemLink)
									end
								end
							end
						end
					end
				end
			end
		end

		if totalCost > 0 then -- End Total
			Debug("  -- Total: %d", totalCost)
			Print("- - - - - - - - - - - - - - -")
			Print(L.ChatMessage_AutoBuy_Total, GetCoinText(totalCost, " "))
		end

		lastShoppingTime = GetTime()
	end

	-- Reset Settings
	local function _resetSettings()
		-- Reset back to Default Options
		wipe(db)
		initDB(db, dbDefaults)

		-- Apply Default Options
		f:ClearAllPoints()
		f:SetPoint((db.GrowDirection == 1) and "BOTTOMLEFT" or "TOPLEFT", UIParent, "BOTTOMLEFT", db.XPos, db.YPos) -- 0 = Down, 1 = Up

		f.Background:SetVertexColor(db.FrameVertexColor[1], db.FrameVertexColor[2], db.FrameVertexColor[3])
		f.CloseButton:GetNormalTexture():SetVertexColor(
			blendColors(
				{
					{ db.FrameVertexColor[1], db.FrameVertexColor[2], db.FrameVertexColor[3], .5 },
					{ 1, 1, 1, .5 }
				}
			)
		)

		f:UpdateTextLines()
		f:UpdateItemButtons()
		f:PLAYER_ENTERING_WORLD()
	end


--[[----------------------------------------------------------------------------
	SlashHandler
----------------------------------------------------------------------------]]--
	SLASH_DMFQUESTNEXT1 = "/dmfquest"
	SLASH_DMFQUESTNEXT2 = "/dmfq"

	local SlashHandlers = {
		["config"] = function()
			if f.categoryId and Settings and Settings.OpenToCategory then
				Debug("Config: NEW!")
				Settings.OpenToCategory(f.categoryId)
			elseif f.optionsFrame and InterfaceOptionsFrame_OpenToCategory then
				Debug("Config: OLD!")
				InterfaceOptionsFrame_OpenToCategory(f.optionsFrame)
			else
				Print("Something went wrong and you should let the author of the addon know with following information:", tostring(f.categoryId), tostring(f.optionsFrame), GetBuildInfo())
			end
		end,
		["pin"] = function()
			isFramePinned = not isFramePinned
			Print(L.ChatMessage_Slash_PinningChanged, isFramePinned)
			if (isFramePinned) then
				f.TitleText:SetText(f.addonTitle .. " " .. L.FrameTitle_Pinned)
				f:Show()
			else
				f.TitleText:SetText(f.addonTitle)
			end
		end,
		["reset"] = function()
			_resetSettings()
		end,
		["offset"] = function(offset)
			if (offset ~= nil and tonumber(offset) == 0) then
				db.UseTimeOffset = false
				db.TimeOffsetValue = 0
			else
				db.UseTimeOffset = true
				db.TimeOffsetValue = tonumber(offset) or 0
			end
			Print("Offset", db.UseTimeOffset, db.TimeOffsetValue)
		end,
		["debug"] = function() -- Debug stuff
			db.debug = not db.debug
			Print("Debug:", db.debug)
		end,
		["ptr"] = function() -- PTR stuff
			db.isPTR = not db.isPTR
			Print("PTR:", db.isPTR)
			f:UpdateItemButtons()
			f:UpdateTextLines()
		end,
		["check"] = function()
			local uiMapID = C_Map.GetBestMapForUnit("player")
			local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime()
			local currentCalendarTimeString = string.format("Time Now: %d.%d.%d   %d:%d", currentCalendarTime.year, currentCalendarTime.month, currentCalendarTime.monthDay, currentCalendarTime.hour, currentCalendarTime.minute)
			local offsetCalendarTime = _shiftTimeTables(currentCalendarTime)
			local offsetCalendarTimeString = string.format("With Offset: %d.%d.%d   %d:%d (%s)", offsetCalendarTime.year, offsetCalendarTime.month, offsetCalendarTime.monthDay, offsetCalendarTime.hour, offsetCalendarTime.minute, db.UseTimeOffset and (db.TimeOffsetValue < 0 and "-" or "+" .. db.TimeOffsetValue) or "Offset Off")
			currentCalendarTime.day = currentCalendarTime.monthDay
			local currentEpoch = time(currentCalendarTime)
			local currentEpochString = (f.startTime > 0 and f.endTime > 0) and string.format("%s <- You are here -> %s", _epochToHumanReadable(currentEpoch - f.startTime), _epochToHumanReadable(f.endTime - currentEpoch)) or "n/a"

			Print(">", f.addonTitle, "/", f.initDone,
				"\n  |   ",
					"Zone:", f:CheckForPortalZone(), "/", tostring(uiMapID), "/", (uiMapID and subZoneAreaIDs[uiMapID]) and #subZoneAreaIDs[uiMapID] or "n/a",
				"\n  |   ",
					"DMF:", f:CheckForDMF(), "/", currentEpochString,
				"\n  |   ",
					currentCalendarTimeString,
				"\n  |   ",
					offsetCalendarTimeString
			)
		end,
		["update"] = function()
			f:UpdateItemButtons()
			f:UpdateProfessions()
			f:UpdateTextLines()
		end,
		--[[
		["text"] = function()
			if f.ContainerText:GetText() == "\n" .. ADDON_NAME .. " Loaded!\n\n" then
				f.ContainerText:SetText(ADDON_NAME .. " Loaded!\n\n§1234567890+´+\n½!\"#¤%&/()=?`\n\nqwertyuiopå¨\nQWERTYUIOPÅ^\n\nasdfghjklöä'\nASDFGHJKLÖÄ*\n\n<zxcvbnm,.-\n>ZXCVBNM;:_")
			else
				f.ContainerText:SetText("\n" .. ADDON_NAME .. " Loaded!\n\n")
			end
			for s = #activeStrings, 1, -1 do
				stringPool:Release(activeStrings[s])
				activeStrings[s] = nil
			end
			f.ContainerText:Show()
			f:Layout()
		end,
		]]
		["grow"] = function()
			if db.GrowDirection == 0 then
				db.GrowDirection = 1
			else
				db.GrowDirection = 0
			end
			
			db.XPos = f:GetLeft()
			db.YPos = (db.GrowDirection == 1) and f:GetBottom() or f:GetTop() -- 0 = Down, 1 = Up

			f:ClearAllPoints()
			f:SetPoint((db.GrowDirection == 1) and "BOTTOMLEFT" or "TOPLEFT", UIParent, "BOTTOMLEFT", db.XPos, db.YPos) -- 0 = Down, 1 = Up

			Print("Grow Direction:", (db.GrowDirection == 1) and "Up" or "Down")
		end,
		["lock"] = function()
			db.FrameLock = not db.FrameLock
			Print("Lock:", db.FrameLock)
		end,
		["test"] = function()
			Print("TEST START:")
			----------------------------------------------------------------------------------------------------
			local uiMapID = C_Map.GetBestMapForUnit("player")
			local subZone = GetMinimapZoneText() --GetSubZoneText()

			local info = C_Map.GetMapInfo(uiMapID)
			Print("- Map", uiMapID, info.name, info.mapType, subZone)

			local position = C_Map.GetPlayerMapPosition(uiMapID, "player")
			local areaID = C_MapExplorationInfo.GetExploredAreaIDsAtPosition(uiMapID, position)
			Print("-- Check areaIDs")
			if areaID then
				for i = 1, #areaID do
					Print("  -- ", i, "/", #areaID, "-", areaID[i], C_Map.GetAreaInfo(areaID[i]))
				end
			end
			----------------------------------------------------------------------------------------------------
			Print("TEST END!")
		end
	}

	SlashCmdList.DMFQUESTNEXT = function(text)
		local command, params = strsplit(" ", text, 2)

		if SlashHandlers[command] then
			SlashHandlers[command](params)
		else
			Debug("SlashHandler", tostring(command), tostring(params))
			if f:IsShown() then
				f:Hide()
			else
				f:Show()
			end
		end
	end


--[[----------------------------------------------------------------------------
	DMFQuest Config
		-- Frame
		XPos = 275,
		YPos = 275,
		FrameLock = false,
		GrowDirection = 1, -- 0 = Down, 1 = Up
		FrameVertexColor = { 0, 1, 0 }, -- UI shade
		-- Features
		AutoBuy = true,
		HideLow = false,
		HideMax = false,
		-- Quests
		PetBattle = true,
		DeathMetalKnight = true,
		TestYourStrength = true,
		FadedTreasureMap = true,
		ShowItemRewards = true,
		-- Time Offset
		UseTimeOffset = false,
		TimeOffsetValue = 0,
		-- Development and Debug
		dbVersion = 1, -- In case we need to change things in the future
		debug = false, -- Debug output
		isPTR = false, -- Change some values on PTR only
----------------------------------------------------------------------------]]--
local DMFQConfig = {
	name = ADDON_NAME,
	type = "group",
	set = function(info, val)
		--Print(" = C -> %s (%s -> %s)", info[#info], tostring(db[info[#info]]), tostring(val))
		db[info[#info]] = val

		local cat = info[1]
		if cat == "FrameOptions" then
			Debug(" = Config - updateFramePosition", info[#info], val)
			f:ClearAllPoints()
			f:SetPoint((db.GrowDirection == 1) and "BOTTOMLEFT" or "TOPLEFT", UIParent, "BOTTOMLEFT", db.XPos, db.YPos) -- 0 = Down, 1 = Up
		elseif cat == "ExtraFeaturesOptions" or cat == "AdditionalQuestsandActivitiesOptions" then
			Debug(" = Config - updateFrameContent", info[#info], val)
			f:UpdateTextLines()
			if info[#info] == "ShowItemRewards" then
				Debug(" = Config -- ShowItemRewards")
				f:UpdateItemButtons()
			end
		elseif cat == "MiscOptions" then
			Debug(" = Config - updateTimeFrame", info[#info], val)
			f:PLAYER_ENTERING_WORLD()
		end
	end,
	get = function(info)
		-- Print(" = C <-", info[#info])
		return db[info[#info]]
	end,
	args = {
		FrameOptions = {
			order = 100,
			name = L.Config_GroupHeader_Frame,
			type = "group",
			inline = true,
			args = {
				XPos = {
					order = 10,
					name = string.format(L.Config_Frame_Pos, "X-"),
					desc = string.format(L.Config_Frame_Pos_Desc, "X-"),
					type = "range",
					min = 0,
					max = math.floor(GetScreenWidth() + .5),
					step = 1,
					width = "double"
				},
				YPos = {
					order = 20,
					name = string.format(L.Config_Frame_Pos, "Y-"),
					desc = string.format(L.Config_Frame_Pos_Desc, "Y-"),
					type = "range",
					min = 0,
					max = math.floor(GetScreenHeight() + .5),
					step = 1,
					width = "double"
				},
				FrameLock = {
					order = 30,
					name = L.Config_Frame_FrameLock,
					desc = L.Config_Frame_FrameLock_Desc,
					type = "toggle",
					width = "double"
				},
				GrowDirection = {
					order = 40,
					name = L.Config_Frame_GrowDirection,
					desc = string.format(L.Config_Frame_GrowDirection_Desc, HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP, HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN),
					type = "select",
					values = {
						[0] = HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN,
						[1] = HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP
					},
					style = "radio"
				},
				FrameVertexColor = {
					order = 50,
					name = L.Config_Frame_TintingColor,
					desc = L.Config_Frame_TintingColor_Desc,
					type = "color",
					hasAlpha = false,
					set = function(info, r, g, b, a)
						--Print(" = CC -> %s (%.2f %.2f %.2f -> %.2f %.2f %.2f %.2f)", info[#info], db[info[#info]][1], db[info[#info]][2], db[info[#info]][3], r, g, b, a)
						db[info[#info]][1] = r
						db[info[#info]][2] = g
						db[info[#info]][3] = b

						
						f.Background:SetVertexColor(r, g, b)
						f.CloseButton:GetNormalTexture():SetVertexColor(
							blendColors(
								{
									{ r, g, b, .5 },
									{ 1, 1, 1, .5 }
								}
							)
						)
					end,
					get = function(info)
						local r, g, b = db[info[#info]][1], db[info[#info]][2], db[info[#info]][3]
						--Print(" = CC <-", r, g, b)
						return r, g, b, 1
					end,
					width = "double"
				}
			}
		},
		ExtraFeaturesOptions = {
			order = 200,
			name = L.Config_GroupHeader_ExtraFeatures,
			type = "group",
			inline = true,
			args = {
				AutoBuy = {
					order = 10,
					name = L.Config_ExtraFeatures_AutoBuy,
					desc = L.Config_ExtraFeatures_AutoBuy_Desc,
					type = "toggle",
					width = 1.5
				},
				HideLow = {
					--	https://www.wowhead.com/news=318875/darkmoon-faire-november-2020-skill-requirement-removed-from-profession-quests
					--	----------------------------------------------------------------------------------------------------
					--	In the Shadowlands pre-patch, the 75 skill requirement has been removed from Darkmoon Faire
					--	profession quests. You now only need to know a minimum of level 1, and completing the quest still
					--	adds points to the highest expansion's profession level known.
					--	----------------------------------------------------------------------------------------------------
					order = 20,
					name = L.Config_ExtraFeatures_HideLow,
					desc = string.format(L.Config_ExtraFeatures_HideLow_Desc, minimumSkillRequired),
					type = "toggle",
					width = 1.5,
					--hidden = true
				},
				HideMax = {
					order = 30,
					name = L.Config_ExtraFeatures_HideMax,
					desc = L.Config_ExtraFeatures_HideMax_Desc,
					type = "toggle",
					width = 1.5
				}
			}
		},
		AdditionalQuestsandActivitiesOptions = {
			order = 300,
			name = L.Config_GroupHeader_AdditionalQuests,
			type = "group",
			inline = true,
			args = {
				PetBattle = {
					order = 10,
					name = L.Config_Activity_PetBattle,
					desc = L.Config_Activity_PetBattle_Desc,
					type = "toggle",
					width = 1.5
				},
				DeathMetalKnight = {
					order = 20,
					name = L.QuestTitleFix_DeathMetalKnight,
					desc = string.format(L.Config_Activity_DeathMetalKnight_Desc, ORANGE_FONT_COLOR:WrapTextInColorCode(L.QuestTitleFix_DeathMetalKnight)),
					type = "toggle",
					width = 1.5
				},
				TestYourStrength = {
					order = 30,
					name = C_QuestLog.GetTitleForQuestID(additionalQuests.TestYourStrength.QuestId) or L.QuestTitleFix_TestYourStrength,
					desc = string.format(L.Config_Activity_TestYourStrength_Desc, ORANGE_FONT_COLOR:WrapTextInColorCode(C_QuestLog.GetTitleForQuestID(additionalQuests.TestYourStrength.QuestId) or L.QuestTitleFix_TestYourStrength)),
					type = "toggle",
					width = 1.5
				},
				FadedTreasureMap = {
					order = 40,
					name = cacheItemNames[additionalQuests.FadedTreasureMap.StartItemId] or L.QuestTitleFix_FadedTreasureMap,
					desc = string.format(L.Config_Activity_FadedTreasureMap_Desc, ORANGE_FONT_COLOR:WrapTextInColorCode(cacheItemNames[additionalQuests.FadedTreasureMap.StartItemId] or L.QuestTitleFix_FadedTreasureMap)),
					type = "toggle",
					width = 1.5
				},
				ShowItemRewards = {
					order = 50,
					name = L.Config_Activity_ShowItemRewards,
					desc = L.Config_Activity_ShowItemRewards_Desc,
					type = "toggle",
					width = 1.5
				}
			}
		},
		MiscOptions = {
			order = 400,
			name = MISCELLANEOUS,
			type = "group",
			inline = true,
			args = {
				UseTimeOffset = {
					order = 10,
					name = L.Config_Misc_UseTimeOffset,
					desc = L.Config_Misc_UseTimeOffset_Desc,
					type = "toggle",
					width = 1.5
				},
				TimeOffsetValue = {
					order = 20,
					name = L.Config_Misc_TimeOffsetValue,
					desc = L.Config_Misc_TimeOffsetValue_Desc,
					type = "range",
					min = -24,
					max = 24,
					step = 1,
					disabled = function()
						return (not db.UseTimeOffset)
					end,
					width = 1.5
				},
				TimeNow = {
					order = 30,
					name = function()
						--[[
						TIMEMANAGER_TOOLTIP_REALMTIME = "Realm time:"
						TIME_LABEL = "Time:"
						]]
						local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime()
						local currentCalendarTimeString = string.format("%s: %.2d.%.2d.%.2d   %.2d:%.2d", TIMEMANAGER_TOOLTIP_REALMTIME, currentCalendarTime.year, currentCalendarTime.month, currentCalendarTime.monthDay, currentCalendarTime.hour, currentCalendarTime.minute)
						local offsetCalendarTime = _shiftTimeTables(currentCalendarTime)
						local offsetCalendarTimeString = string.format("%s: %.2d.%.2d.%.2d   %.2d:%.2d (%s)", L.Config_Misc_WithOffset, offsetCalendarTime.year, offsetCalendarTime.month, offsetCalendarTime.monthDay, offsetCalendarTime.hour, offsetCalendarTime.minute, db.UseTimeOffset and (db.TimeOffsetValue < 0 and "-" or "+" .. db.TimeOffsetValue) or L.Config_Misc_TimeOffsetOff)
						return currentCalendarTimeString .. "\n" .. offsetCalendarTimeString
					end,
					type = "description",
					width = "full",
					fontSize = "medium",
					image = "Interface/Store/Perks",
					imageCoords = { 0.640625, 0.669921875, 0.2421875, 0.2568359375 }
				}
			}
		},
		DebugOptions = {
			order = 500,
			name = BINDING_HEADER_DEBUG, -- "Debug"
			type = "group",
			inline = true,
			args = {
				debug = {
					order = 10,
					name = "Debug",
					desc = "Enable Debugging",
					type = "toggle",
					width = 1.5
				},
				isPTR = {
					order = 20,
					name = "isPTR",
					desc = "Enable PTR-mode for debugging",
					type = "toggle",
					width = 1.5
				}
			},
			hidden = function()
				return (not db.debug)
			end
		},
		ResetDB = {
			order = 1000,
			name = RESET_ALL_BUTTON_TEXT, -- "Reset All"
			desc = RESET_TO_DEFAULT, -- "Reset To Default"
			type = "execute",
			func = _resetSettings,
			confirm = true,
			confirmText = CONFIRM_RESET_SETTINGS -- "Do you want to reset all settings to their defaults? This will immediately apply all settings."
		}
	}
}

local AceConfig = LibStub("AceConfig-3.0")
AceConfig:RegisterOptionsTable(ADDON_NAME, DMFQConfig)
f.optionsFrame, f.categoryId = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ADDON_NAME)


------------------------------------------------------------------------- EOF --