-------------------------------------------------------------------------------
-- DMFQuest Localized Zone Names
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...

local B = {}
ns.B = B

-- STABBED FROM LibBabble-SubZone-3.0 TO REDUCE MEM USAGE, FOR FULL LIB SEE:
-- http://www.wowace.com/addons/libbabble-subzone-3-0/

------------------------------------------------------------------------
-- English
------------------------------------------------------------------------

B["Elwynn Forest"] = "Elwynn Forest"
B.Goldshire = "Goldshire"
B["Lion's Pride Inn"] = "Lion's Pride Inn"

B.Mulgore = "Mulgore"
B["Thunder Bluff"] = "Thunder Bluff"
B["The Cat and the Shaman"] = "The Cat and the Shaman"

local CURRENT_LOCALE = GetLocale()
if CURRENT_LOCALE:match("^en") then return end


------------------------------------------------------------------------
-- German
------------------------------------------------------------------------

if CURRENT_LOCALE == "deDE" then
B["Elwynn Forest"] = "Wald von Elwynn"
B.Goldshire = "Goldhain"
B["Lion's Pride Inn"] = "Gasthaus \"Zur Höhle des Löwen\""

B.Mulgore = "Mulgore"
B["Thunder Bluff"] = "Donnerfels"
B["The Cat and the Shaman"] = "Der Schamane und die Katze"

return end


------------------------------------------------------------------------
-- Spanish
------------------------------------------------------------------------

if CURRENT_LOCALE == "esES" then
B["Elwynn Forest"] = "Bosque de Elwynn"
B.Goldshire = "Villadorada"
B["Lion's Pride Inn"] = "Posada Orgullo de León"

B.Mulgore = "Mulgore"
B["Thunder Bluff"] = "Cima del Trueno"
B["The Cat and the Shaman"] = "El Gato y el Chamán"

return end


------------------------------------------------------------------------
-- Latin American Spanish
------------------------------------------------------------------------

if CURRENT_LOCALE == "esMX" then
B["Elwynn Forest"] = "Bosque de Elwynn"
B.Goldshire = "Villadorada"
B["Lion's Pride Inn"] = "Posada Orgullo de León"

B.Mulgore = "Mulgore"
B["Thunder Bluff"] = "Cima del Trueno"
B["The Cat and the Shaman"] = "El Gato y el Chamán"

return end


------------------------------------------------------------------------
-- French
------------------------------------------------------------------------

if CURRENT_LOCALE == "frFR" then
B["Elwynn Forest"] = "Forêt d’Elwynn"
B.Goldshire = "Comté-de-l'Or"
B["Lion's Pride Inn"] = "Auberge de la Fierté du lion"

B.Mulgore = "Mulgore"
B["Thunder Bluff"] = "Les Pitons-du-Tonnerre"
B["The Cat and the Shaman"] = "Le Chat et le Chaman"

return end


------------------------------------------------------------------------
-- Italian
------------------------------------------------------------------------

if CURRENT_LOCALE == "itIT" then
B["Elwynn Forest"] = "Foresta di Elwynn"
B.Goldshire = "Borgodoro"
B["Lion's Pride Inn"] = "Locanda del Fiero Leone"

B.Mulgore = "Mulgore"
B["Thunder Bluff"] = "Picco del Tuono"
B["The Cat and the Shaman"] = "Gatti e Sciamani"

return end


------------------------------------------------------------------------
-- Korean
------------------------------------------------------------------------

if CURRENT_LOCALE == "koKR" then
B["Elwynn Forest"] = "엘윈 숲"
B.Goldshire = "황금골"
B["Lion's Pride Inn"] = "사자무리 여관"

B.Mulgore = "멀고어"
B["Thunder Bluff"] = "썬더 블러프"
B["The Cat and the Shaman"] = "고양이와 주술사"

return end


------------------------------------------------------------------------
-- Brazilian Portuguese
------------------------------------------------------------------------

if CURRENT_LOCALE == "ptBR" then
B["Elwynn Forest"] = "Floresta de Elwynn"
B.Goldshire = "Vila d'Ouro"
B["Lion's Pride Inn"] = "Estalagem do Leão Orgulhoso"

B.Mulgore = "Mulgore"
B["Thunder Bluff"] = "Penhasco do Trovão"
B["The Cat and the Shaman"] = "O Gato e o Xamã"

return end


------------------------------------------------------------------------
-- Russian
------------------------------------------------------------------------

if CURRENT_LOCALE == "ruRU" then
B["Elwynn Forest"] = "Элвиннский лес"
B.Goldshire = "Златоземье"
B["Lion's Pride Inn"] = "Таверна \"Гордость льва\""

B.Mulgore = "Мулгор"
B["Thunder Bluff"] = "Громовой Утес"
B["The Cat and the Shaman"] = "\"Кот и шаман\""

return end


------------------------------------------------------------------------
-- Simplified Chinese
------------------------------------------------------------------------

if CURRENT_LOCALE == "zhCN" then
B["Elwynn Forest"] = "艾尔文森林"
B.Goldshire = "闪金镇"
B["Lion's Pride Inn"] = "狮王之傲旅店"

B.Mulgore = "莫高雷"
B["Thunder Bluff"] = "雷霆崖"
B["The Cat and the Shaman"] = "猫和萨满"

return end


------------------------------------------------------------------------
-- Traditional Chinese
------------------------------------------------------------------------

if CURRENT_LOCALE == "zhTW" then
B["Elwynn Forest"] = "艾爾文森林"
B.Goldshire = "閃金鎮"
B["Lion's Pride Inn"] = "獅王之傲旅店"

B.Mulgore = "莫高雷"
B["Thunder Bluff"] = "雷霆崖"
B["The Cat and the Shaman"] = "貓與薩滿酒館"

return end


------------------------------------------------------------------------
-- EOF