![Release](https://github.com/ahakola/DMFQuest/actions/workflows/release.yml/badge.svg)

# DMF Quest

**New completely rewritten version 3.0 out now!**

## About the Addon
### Ever forgot to buy materials for your Darkmoon Faire crafting quests?
DMF Quest pops up a small reminder window for you near the DMF portal and tells you if you are missing any crafting profession materials or haven't accepted the turn in item quests from your backbag.

### Reminder window
For Alliance the reminder window will automaticly show up in Goldshire and Lion's Pride Inn when the DMF is on for easy mats buying.

Horde got the short stick in this competition as the current detection system dictates the reminder window will pop out when near the portal and I included Thunder Bluff for your shopping needs.

Try `/dmfq` to make the reminder window to appear/disappear outside the DMF portal area for placement or what ever you want to do with it. `/dmfq pin` to pin the window to prevent the automatic closing when leaving the portal area.

### Professions
The addon will automaticly detect your professions and tell what mats you need with you (or if don't need any). It also tells if you have completed the quest already or your crafting skill is too low for quest.

* Supports all primary professions
* Supports all secondary professions
* `Orange` text on skill level display indicates by turning in your quest you are going to waste some or all of your skill level gains because gapping.
* `AutoBuy` option will buy missing crafting materials you won't get inside the DMF when talking to vendors.
* You are now able to track Pet Battle quests.

### Turn in items
Under the window you'll see a row of buttons. One for every turn in item DMF offers.

* `White` means you have the item in your backbag and you can click the button to auto accept that quest for you.
* `Cyan` means you have the item in your backbag and you are on the quest already.
* `Darkened out` is for not having the item with you in your backbag (the addon can't see your bank).
* `Green` means that you already turned the quest in.

## Help me improve this addon
### Features missing?
If you feel like some feature is flawed, missing or you have suggestion to improve the addon or the code under the hood, don't hesitate to drop me a line through comments or PM (Curse.com or curseforge.com - same account works for both).

If you run into a bug, please report it with via:

* PM at Cursefoge
* Open an issue at Curseforges Ticket-tool: https://wow.curseforge.com/projects/dmfquest/issues/
* Open an issue at Github https://github.com/ahakola/DMFQuest/issues

### Localization
Most of the item and profession names should come automaticly from your client, but there are few phrases in the Frame and Config that needs to be translated. If you want to help translate this addon, do it at https://legacy.curseforge.com/wow/addons/dmfquest/localization and PM at Curseforge or open a issue ticket at Github after you have done so.

---

### Translators

#### 3.0:

Language | Translator(s)
-------- | -------------
German | Bullseiify, Lingkan, Mistrahw
French | Mad_Ti
Korean | netaras
Russian | the_notorious_thug
Traditional Chinese | sopgri

#### 2.0:

Language | Translator(s)
-------- | -------------
German | Mistrahw, pas06, 
French | Mad_Ti
Korean | netaras
Russian | the_notorious_thug
Traditional Chinese | sopgri

#### 1.0:

Thanks to **Mistrahw** for providing the German translation (only languange that had translations) for the old 1.x.x-versions.