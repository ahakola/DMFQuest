--[[----------------------------------------------------------------------------
	DMFQuest Localization
----------------------------------------------------------------------------]]--
local ADDON_NAME, ns = ...

local L = {}
ns.L = L

-- GLOBALS: GetLocale

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
L.Config_Activity_XPRepBuff_Desc = "Show status of %s -buff in DMFQuest Frame"
L.Config_ExtraFeatures_AutoBuy = "AutoBuy"
L.Config_ExtraFeatures_AutoBuy_Desc = "AutoBuy buys quest items automatically from vendors while Darkmoon Faire is available and DMFQuest Frame is visible."
L.Config_ExtraFeatures_HideLow = "Hide low skills"
--L.Config_ExtraFeatures_HideLow_Desc = "Hide professions from DMFQuest Frame if your skill is low. You need at least 75 skill points for quest to be available."
L.Config_ExtraFeatures_HideLow_Desc = "Hide professions from DMFQuest Frame if your skill is low. You need at least %s skill points for quest to be available. This also hides all yet to be learned professions." -- minimumSkillRequired
L.Config_ExtraFeatures_HideMax = "Hide maxed skills"
L.Config_ExtraFeatures_HideMax_Desc = "Hide professions from DMFQuest Frame if your skill is maxed."
L.Config_ExtraFeatures_ShowInCapitals = "Show in all capital cities"
L.Config_ExtraFeatures_ShowInCapitals_Desc = "Show DMFQuest Frame while you are in any of your factions capital cities when Darkmoon Faire is available."
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
L.Profession_NoProfession = "No profession learned"
L.Profession_MissingProfession = "%s not learned"
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
L.QuestTitleFix_XPRepBuff = "WHEE!" -- spellId 46668


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
	L.ChatMessage_AutoBuy_Total = "Всего:",
	L.ChatMessage_Login_DMFWarning = "Ярмарка Новолуния уже доступна!",
	L.ChatMessage_Slash_PinningChanged = "Закрепление изменено на:",
	L.ChatMessage_Slash_Syntax = "Синтаксис: /dmfq (config | pin | reset)",
	L.Config_Activity_DeathMetalKnight_Desc = "Показывать %s убийств на Ярмарке Новолуния в этом месяце в рамке DMFQuest.",
	L.Config_Activity_FadedTreasureMap_Desc = "Показывать %s (одноразовое задание из предмета) в окне DMFQuest.",
	L.Config_Activity_PetBattle = "Задания по битвам питомцев",
	L.Config_Activity_PetBattle_Desc = "Показывать задания по битвам питомцев в окне DMFQuest.",
	L.Config_Activity_ShowItemRewards = "Награды за сдачу предметов",
	L.Config_Activity_ShowItemRewards_Desc = "Показывать награды за сдачу предметов в подсказках к предметам в окне DMFQuest.",
	L.Config_Activity_TestYourStrength_Desc = "Показывать %s -задание для Ярмарки Новолуния этого месяца в окне DMFQuest.",
	L.Config_Activity_XPRepBuff_Desc = "Показать статус %s -баффа в окне DMFQuest",
	L.Config_ExtraFeatures_AutoBuy = "Автопокупка",
	L.Config_ExtraFeatures_AutoBuy_Desc = "Автопокупка автоматически покупает предметы для заданий у торговцев, пока доступна Ярмарка Новолуния и открыто окно DMFQuest.",
	L.Config_ExtraFeatures_HideLow = "Скрыть низкие навыки",
	L.Config_ExtraFeatures_HideLow_Desc = "Скрыть профессии из окна DMFQuest, если ваш навык низкий. Вам нужно не менее %s очков навыков, чтобы задание было доступно. Это также скроет все еще не изученные профессии.",
	L.Config_ExtraFeatures_HideMax = "Скрыть максимальные навыки",
	L.Config_ExtraFeatures_HideMax_Desc = "Скройте профессии из окна DMFQuest, если ваш навык максимален.",
	L.Config_ExtraFeatures_ShowInCapitals = "Показать во всех столицах",
	L.Config_ExtraFeatures_ShowInCapitals_Desc = "Показывать окно DMFQuest, находясь в любой из столиц вашей фракции, когда доступна Ярмарка Новолуния.",
	L.Config_Frame_FrameLock = "Положение блокировки",
	L.Config_Frame_FrameLock_Desc = "Заблокируйте окно DMFQuest, чтобы предотвратить перетаскивание за строку заголовка.",
	L.Config_Frame_GrowDirection = "Направление роста",
	L.Config_Frame_GrowDirection_Desc = "Измените направление роста окна DMFQuest. %s - Окно DMFQuest закреплено в НИЖНЕМ ЛЕВОМ углу. %s - Окно DMFQuest закреплено в ВЕРХНЕМ ЛЕВОМ углу.",
	L.Config_Frame_Pos = "%sПозиция",
	L.Config_Frame_Pos_Desc = "Изменить %sПозицию окна DMFQ.",
	L.Config_Frame_TintingColor = "Изменить цвет",
	L.Config_Frame_TintingColor_Desc = "Измените цвет окна DMFQuest.",
	L.Config_GroupHeader_AdditionalQuests = "Дополнительные задания и активности",
	L.Config_GroupHeader_ExtraFeatures = "Дополнительные возможности",
	L.Config_GroupHeader_Frame = "Настройки окна",
	L.Config_Misc_TimeOffsetOff = "Смещение Выкл.",
	L.Config_Misc_TimeOffsetValue = "Смещение по времени",
	L.Config_Misc_TimeOffsetValue_Desc = "Выберите, на сколько часов смещается время, чтобы начало и конец Ярмарки Новолуния соответствовали вашему местному часовому поясу.",
	L.Config_Misc_UseTimeOffset = "Использовать смещение времени",
	L.Config_Misc_UseTimeOffset_Desc = "Смещение времени пытается исправить разницу между вашим локальным временем и временем в реальном времени. Это смещение используется для улучшения определения времени начала и окончания Ярмарки Новолуния.",
	L.Config_Misc_WithOffset = "Со смещением",
	L.FrameTitle_Pinned = "(Закреплено)",
	L.Profession_MissingProfession = "%s не изучен",
	L.Profession_NoItemsNeeded = "Нет необходимых предметов",
	L.Profession_NoProfession = "Никакой профессии не обучен",
	L.Profession_SkillTooLow = "Уровень профессии слишком низкий",
	L.Quest_ActivityDone = "выполнено",
	L.Quest_QuestDone = "Задание выполнено",
	L.Quest_QuestNoItem = "В ваших сумках нет %s",
	L.Quest_QuestNotDone = "Задание не выполнено",
	L.Quest_QuestReady = "Задание готово к сдаче",
	L.Quest_QuestReadyToAccept = "Нажмите, чтобы автоматически принять задание",
	L.QuestTitleFix_DeathMetalKnight = "Рыцарь металла",
	L.QuestTitleFix_FadedTreasureMap = "Выцветшая карта сокровищ",
	L.QuestTitleFix_TestYourStrength = "Испытай свою силу",
	L.QuestTitleFix_XPRepBuff = "ВУХУУУ!"

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
