# DMF Quest

**Blizzard have changed the way ItemInfo from Merchant items is delivered to player at some point. Due to this change you are going to need to open the MerchantFrame twice for AutoBuy to work correctly. I'm open for suggestions how to fix this if you have ideas.**

## About the Addon
### Ever forgot to buy materials for your Darkmoon Faire crafting quests?
DMF Quest pops up a small reminder window for you near the DMF portal and tells you if you are missing any crafting profession materials or haven't accepted the turn in item quests from your backbag.

### Reminder window
For Alliance the reminder window will automaticly show up in Goldshire and Lion's Pride Inn when the DMF is on for easy mats buying.

Horde got the short stick in this competition as the current detection system dictates the reminder window will pop out when near the portal (distance is checked every 5 seconds when in Mulgore) and I included Thunder Bluff for your shopping needs.

Try `/dmfq` to make the reminder window to appear/disappear outside the DMF portal area for placement or what ever you want to do with it. `/dmfq pin` to pin the window to prevent the automatic closing when leaving the portal area.

### Professions
The addon will automaticly detect your professions and tell what mats you need with you (or if don't need any). It also tells if you have completed the quest already or your crafting skill is too low for quest.


* Supports all primary professions
* Supports all secondary professions
* NEW 2.0: `Orange` text on skill level display indicates by turning in your quest you are going to waste some or all of your skill level gains because gapping.
* NEW 2.0: AutoBuy option will buy missing crafting materials you won't get inside the DMF when talking to vendors.
* NEW 2.0: Hide low skill quests option will hide display for professions your skill isn't high enough to accept the quest.
* NEW 2.0.19: You are now able to track Pet Battle quests. These are OFF by default, but can be enabled from Config.

### Turn in items
Under the window you'll see a row of buttons. One for every turn in item DMF offers.

* NEW 2.0: White means you have the item in your backbag and you can click the button to auto accept that quest for you.
* `Cyan` means you have the item in your backbag and you are on the quest already.
* `Darkened out` is for not having the item with you in your backbag (the addon can't see your bank).
* `Green` means that you already turned the quest in.

## Help me improve this addon
### Features missing?
If you feel like some feature is flawed, missing or you have suggestion to improve the addon or the code under the hood, don't hesitate to drop me a line through comments or PM (Curse.com or curseforge.com - same account works for both).

If you run into a bug, please report it with via PM, or curseforges Ticket-tool: https://wow.curseforge.com/projects/dmfquest/issues/

### Localization
Most of the item and profession names should come automaticly from your client, but there are few phrases in the Frame and Config that needs to be translated. If you want to help translate this addon, do it at http://wow.curseforge.com/addons/dmfquest/localization/

Translators for 2.0:
Language | Translator(s)
-------- | -------------
German | Mistrahw, pas06
French | Mad_Ti

---

Thanks to **Mistrahw** for providing the German translation (only languange that had translations) for the old 1.x.x-versions.

**Please disable TradeSkillMaster before copy&pasting Lua errors to me, it makes the Lua error -reports almost impossible to read.**
