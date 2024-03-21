--[[----------------------------------------------------------------------------
	DMFQuest Localization
----------------------------------------------------------------------------]]--
local ADDON_NAME, ns = ...

local L = {}
ns.L = L

-- THIS FILE IS PARTIALLY AUTOMATICALLY GENERATED. TO HELP TRANSLATE, SEE:
-- https://legacy.curseforge.com/wow/addons/dmfquest/localization
-- PM me in Curseforge after you have done your translations!

--[[----------------------------------------------------------------------------
	English
----------------------------------------------------------------------------]]--

L.ChatMessage_AutoBuy_Total = "Total:"
L.ChatMessage_Login_DMFWarning = "Darkmoon Faire is available!"
L.ChatMessage_Slash_PinningChanged = "Pinning changed to:"
L.Config_Activity_DeathMetalKnight_Desc = "Show %s kill for this months Darkmoon Faire in DMFQuest Frame."
L.Config_Activity_FadedTreasureMap_Desc = "Show %s (one time quest from item) in DMFQuest Frame."
L.Config_Activity_PetBattle = "Pet Battle Quests"
L.Config_Activity_PetBattle_Desc = "Show Pet Battle Quests in DMFQuest Frame."
L.Config_Activity_ShowItemRewards = "Turn-in item rewards"
L.Config_Activity_ShowItemRewards_Desc = "Show rewards for turn-in-item in item-tooltips in DMFQuest Frame."
L.Config_Activity_TestYourStrength_Desc = "Show %s -quest for this months Darkmoon Faire in DMFQuest Frame."
L.Config_ExtraFeatures_AutoBuy = "AutoBuy"
L.Config_ExtraFeatures_AutoBuy_Desc = "AutoBuy buys quest items automatically from vendors while Darkmoon Faire is available and DMFQuest Frame is visible."
L.Config_ExtraFeatures_HideLow = "Hide low skills"
L.Config_ExtraFeatures_HideLow_Desc = "Hide professions from DMFQuest Frame if your skill is low. You need at least 75 skill points for quest to be available."
L.Config_ExtraFeatures_HideMax = "Hide maxed skills"
L.Config_ExtraFeatures_HideMax_Desc = "Hide professions from DMFQuest Frame if your skill is maxed."
L.Config_Frame_FrameLock = "Lock position"
L.Config_Frame_FrameLock_Desc = "Lock DMFQuest Frame to prevent dragging from the title bar."
L.Config_Frame_GrowDirection = "Grow Direction"
L.Config_Frame_GrowDirection_Desc = "Change the direction DMFQuest Frame grows.\n%s - DMFQuest Frame is anchored from BOTTOMLEFT corner.\n%s - DMFQuest Frame is anchored from TOPLEFT corner." -- HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP, HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN
L.Config_Frame_Pos = "%sPosition"
L.Config_Frame_Pos_Desc = "Change DMFQ Frames %sPosition."
L.Config_Frame_TintingColor = "Change color"
L.Config_Frame_TintingColor_Desc = "Change the color of the DMFQuest Frame."
L.Config_GroupHeader_AdditionalQuests = "Additional Quests and Activities"
L.Config_GroupHeader_ExtraFeatures = "Extra Features"
L.Config_GroupHeader_Frame = "Frame Options"
L.Config_Misc_TimeOffsetOff = "Offset Off"
L.Config_Misc_TimeOffsetValue = "Time offset"
L.Config_Misc_TimeOffsetValue_Desc = "Select how many hours the time is offset to match the Darkmoon Faire's start and end times to your local timezone."
L.Config_Misc_UseTimeOffset = "Use Time offset"
L.Config_Misc_UseTimeOffset_Desc = "Time offset tries to correct the difference between your local time and realm time.\nThis offset is used to improve the detection of start and end times of Darkmoon Faire."
L.Config_Misc_WithOffset = "With Offset"
L.FrameTitle_Pinned = "(Pinned)"
L.Profession_NoItemsNeeded = "No items needed"
L.Profession_NoProfessions = "No professions learned"
L.Profession_SkillTooLow = "Skill too low"
L.Quest_ActivityDone = "done"
L.Quest_QuestDone = "Quest done"
L.Quest_QuestNoItem = "No %s in your bags"
L.Quest_QuestNotDone = "Quest not done"
L.Quest_QuestReady = "Quest ready to turn in"
L.Quest_QuestReadyToAccept = "Click to auto-accept quest"

L.ChatMessage_Slash_Syntax = "Syntax: /dmfq (config | pin | reset)"

-- This doesn't return anything C_QuestLog.GetTitleForQuestID()
L.QuestTitleFix_DeathMetalKnight = "Death Metal Knight" -- questId 47767
-- These are just something to fallback
L.QuestTitleFix_FadedTreasureMap = "Faded Treasure Map" -- itemId 126930
L.QuestTitleFix_TestYourStrength = "Test Your Strength" -- questId 29433


local CURRENT_LOCALE = GetLocale()
if CURRENT_LOCALE:match("^en") then return end


--[[----------------------------------------------------------------------------
	German
----------------------------------------------------------------------------]]--

if CURRENT_LOCALE == "deDE" then
--@localization(locale="deDE", format="lua_additive_table")@

return end


--[[----------------------------------------------------------------------------
	Spanish
----------------------------------------------------------------------------]]--

if CURRENT_LOCALE == "esES" then
--@localization(locale="esES", format="lua_additive_table")@

return end


--[[----------------------------------------------------------------------------
	Latin American Spanish
----------------------------------------------------------------------------]]--

if CURRENT_LOCALE == "esMX" then
--@localization(locale="esMX", format="lua_additive_table")@

return end


--[[----------------------------------------------------------------------------
	French
----------------------------------------------------------------------------]]--

if CURRENT_LOCALE == "frFR" then
--@localization(locale="frFR", format="lua_additive_table")@

return end


--[[----------------------------------------------------------------------------
	Italian
----------------------------------------------------------------------------]]--

if CURRENT_LOCALE == "itIT" then
--@localization(locale="itIT", format="lua_additive_table")@

return end


--[[----------------------------------------------------------------------------
	Brazilian Portuguese
----------------------------------------------------------------------------]]--

if CURRENT_LOCALE == "ptBR" then
--@localization(locale="ptBR", format="lua_additive_table")@

return end


--[[----------------------------------------------------------------------------
	Russian
----------------------------------------------------------------------------]]--

if CURRENT_LOCALE == "ruRU" then
--@localization(locale="ruRU", format="lua_additive_table")@

return end


--[[----------------------------------------------------------------------------
	Korean
----------------------------------------------------------------------------]]--

if CURRENT_LOCALE == "koKR" then
--@localization(locale="koKR", format="lua_additive_table")@

return end


--[[----------------------------------------------------------------------------
	Simplified Chinese
----------------------------------------------------------------------------]]--

if CURRENT_LOCALE == "zhCN" then
--@localization(locale="zhCN", format="lua_additive_table")@

return end


--[[----------------------------------------------------------------------------
	Traditional Chinese
----------------------------------------------------------------------------]]--

if CURRENT_LOCALE == "zhTW" then
--@localization(locale="zhTW", format="lua_additive_table")@

return end


------------------------------------------------------------------------- EOF --