--[[  
            _                    _____            __  __ 
           | |             /\   |  __ \     /\   |  \/  |
   __ _ ___| |_ ___  _ __ /  \  | |__) |   /  \  | \  / |
  / _` / __| __/ _ \| '__/ /\ \ |  _  /   / /\ \ | |\/| |
 | (_| \__ \ || (_) | | / ____ \| | \ \  / ____ \| |  | |
  \__,_|___/\__\___/|_|/_/    \_\_|  \_\/_/    \_\_|  |_| v1

  - astorARAM - League ARAM script. Written by Astoriane.
  - inspired by Burnbot by Burn
  - huge thanks to people who worked on iAram


]]--

if GetGame().map.index ~= 12 then return end -- Don't load if not ARAM

local abilitySequence
local qOff, wOff, eOff, rOff = 0, 0, 0, 0

LOG_PATH = SCRIPT_PATH .. "astorARAM\\"
LOG_FILE = LOG_PATH .. "gameLog.txt"

dependencies = {

    "ItemRecipes",
    "SourceLib"

}

player = GetMyHero()
hero = player.charName

local version = 1.34

local scriptName = "astorARAM"
local scriptTagged = "[" .. scriptName .. "]"

local gold = nil

stance, stName = 2, nil

buyIndex = 1
shoplist = {}
inventoryTable = {}

colors = {

    white = RGB(255, 255, 255),
    brightGreen = RGB(54, 168, 80),
    darkOrange = RGB(204, 120, 50),
    darkRed = RGB(189, 9, 9)

}

drawConstants = {

    x = 50,
    y = 350,
    rectX1 = 420,
    rectY1 = 45,
    rectX2 = 420,
    rectY2 = 350,
    rectCenter = 390 / 2,
    textSize = 28,
    textStartX =  50 + 10,
    textStartY = 350 + 10,
    textStartX2 = 60 + 160,
    textYOffset = 21,
    textEndX = 300 - 10,
    textEndY = 350 + 350 - 30

}

buyDelay = 10000

lastBuy = 0

healthRelics =  {

    { pos = { x = 8922, y = 10, z = 7868 }, current = 0 },
    { pos = { x = 7473, y = 10, z = 6617 }, current = 0 },
    { pos = { x = 5929, y = 10, z = 5190 }, current = 0 },
    { pos = { x = 4751, y = 10, z = 3901 }, current = 0 }
}

target = nil
spawn = { x = player.x, y = player.y }

assassins = {

    "Akali",
    "Diana",
    "Evelynn",
    "Fizz",
    "Katarina",
    "Nidalee"

}

adtanks = {

    "DrMundo",
    "Garen",
    "Hecarim",
    "Jarvan IV",
    "Nasus",
    "Skarner",
    "Volibear",
    "Yorick"

}

adcs = {

    "Ashe",
    "Caitlyn",
    "Corki",
    "Draven",
    "Ezreal",
    "Gankplank",
    "Graves",
    "Jinx",
    "KogMaw",
    "Lucian",
    "MasterYi",
    "MissFortune",
    "Quinn",
    "Sivir",
    "Thresh",
    "Tristana",
    "Tryndamere",
    "Twitch",
    "Urgot",
    "Varus",
    "Vayne",
    "Yasuo"

}

aptanks = {

    "Alistar",
    "Amumu",
    "Blitzcrank",
    "Braum",
    "ChoGath",
    "Leona",
    "Malphite",
    "Maokai",
    "Nautilus",
    "Nunu",
    "Rammus",
    "Sejuani",
    "Shen",
    "Singed",
    "Zac"

}

mages = {

    "Ahri",
    "Anivia",
    "Annie",
    "Brand",
    "Cassiopeia",
    "Galio",
    "Gragas",
    "Heimerdinger",
    "Janna",
    "Karma",
    "Karthus",
    "LeBlanc",
    "Lissandra",
    "Lulu",
    "Lux",
    "Malzahar",
    "Morgana",
    "Nami",
    "Orianna",
    "Ryze",
    "Sona",
    "Soraka",
    "Swain",
    "Syndra",
    "Taric",
    "TwistedFate",
    "Veigar",
    "Velkoz",
    "Viktor",
    "Xerath",
    "Ziggs",
    "Zilean",
    "Zyra"

}

hybrids = {

    "Kayle",
    "Teemo"

}

bruisers = {

    "Darius",
    "Irelia",
    "Khazix",
    "LeeSin",
    "Olaf",
    "Pantheon",
    "Renekton",
    "Rengar",
    "Riven",
    "Shyvana",
    "Talon",
    "Trundle",
    "Vi",
    "Wukong",
    "Zed"

}

fighters = {

    "Aatrox",
    "Fiora",
    "Gnar",
    "Jax",
    "Jayce",
    "Nocturne",
    "Poppy",
    "Sion",
    "Udyr",
    "Warwick",
    "XinZhao"

}

apcs = {

    "Elise",
    "FiddleSticks",
    "Kennen",
    "Mordekaiser",
    "Rumble",
    "Vladimir"

}

heroType = nil
typeString = nil

ranged = 0

-- called once when the script is loaded
function OnLoad()

  if not _G.AstorAramLoaded then

    AstorAram:Load()

    _G.AstorAramLoaded = true

  end

end

-- handles script logic, a pure high speed loop
function OnTick()

  if _G.AstorAramLoaded then

    AstorAram()

  end

end

--handles overlay drawing (processing is not recommended here,use onTick() for that)
function OnDraw()

  AstorAram:Draw()

end

function LoadingSequence()

  PrintChat("<font color='#0066cc'>" .. scriptTagged .. " <font color='#cc7832'>" .. "v" .. version .. "</font> Loaded!</font>")

  PrintChat("<font color='#0066cc'>" .. scriptTagged .. " Hero Type: <font color='#cc7832'>" .. typeString .. "</font></font>")

end

function ProcessDebug()

  print(chatTableGameAlive)

end

--------------------------
-- AstorAram main class --
--------------------------

class 'AstorAram'

function AstorAram:__init()

  gold = player.gold

  if Menu.debug.enabled then

    self:Debug()

  end

  if not Menu.opts.manualMode then

    if not player.dead then

      -- TODO Do stuff here

      --[[




        - Check allies and enemies in range, keep a table.


        - Check skills and cooldowns.


        - Allies in range < enemies in range = def mode

        

        - Def mode: do circular random movements stay behind allied minions and towers, use poke spells



        - Allies approaching enemies, = TF mode



        - TF mode = stay near a random ally, use skills on nearest enemy


        - Allies in range > enemies in range, farm mode.


        - Farm mode = use skills and basic attacks on minions to push lane


        - allies attacking tower = push mode


        - Push mode: attack towers and inhibs



      ]]--

      Bot()

    else

      InventoryHandler()

    end

    ChatHandler()
    InventoryHandler()
    PlayerHandler()
    EndgameHandler()

  end

end

function AstorAram:Load()

  for index = 1, #dependencies do

    if FileExist(LIB_PATH .. dependencies[index] .. ".lua") then

      require(dependencies[index])

    else

      print("Dependency: " .. dependenices[index] .. " was not found. Please redownload.")
      Error = true

    end

  end

  if not Error then

    PlayerHandler:Load()

    LoadMenu()

    LoadingSequence()

    InventoryHandler:Load()

    ChatHandler:Load()

  end

end

function AstorAram:Draw()

  DrawingHandler()

end

function AstorAram:Debug()

  ProcessDebug()

end

---------------------
-- Load menu items --
---------------------

function LoadMenu()

  Menu = scriptConfig(scriptName, 'astorAram_Settings')
  Menu:addSubMenu("astorARAM options", "opts")
  Menu:addSubMenu("Draw options", "draw")
  Menu:addSubMenu("Autobuy options", "auto")
  Menu:addSubMenu("Debug options", "debug")
  Menu:addSubMenu("Chat options", "chat")

  Menu.opts:addParam("enabled", "Enable astorARAM", SCRIPT_PARAM_ONOFF, true)
  Menu.opts:addParam("manualMode", "Toggle Manual Controls", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte('B'))
  Menu.opts:addParam("autoLevel", "Auto Level Spells", SCRIPT_PARAM_ONOFF, true)

  Menu.auto:addParam("enableBuy", "Enable Autobuy", SCRIPT_PARAM_ONOFF, true)
  Menu.auto:addParam("enableSell", "Enable Autosell", SCRIPT_PARAM_ONOFF, true)

  Menu.draw:addParam("enabled", "Enable Drawings", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte('V'))
  Menu.draw:addParam("drawMode", "Draw Script Mode", SCRIPT_PARAM_ONOFF, true)
  Menu.draw:addParam("drawNextBuy", "Draw Next Item", SCRIPT_PARAM_ONOFF, true)
  Menu.draw:addParam("drawRange", "Draw Champion Range", SCRIPT_PARAM_ONOFF, true)
  Menu.draw:addParam("lfc", "Use LagFree Circles", SCRIPT_PARAM_ONOFF, false)

  Menu.debug:addParam("enabled", "Enable Debug Mode", SCRIPT_PARAM_ONOFF, false)

  Menu.chat:addParam("enabled", "Enable Positive Attitude", SCRIPT_PARAM_ONOFF, true)
  Menu.chat:addParam("delay", "Chat Delay", SCRIPT_PARAM_SLICE, 200, 30, 500, 5)

  Menu.opts:permaShow("manualMode")

end

------------------------------------------
-- Handle player and hero related tasks --
------------------------------------------

class 'PlayerHandler'

function PlayerHandler:__init()

  self:AutoLevel()

end

function PlayerHandler:Load()

  self:DetectHeroType()

  self:LoadAbilitySequence()

  self:GenerateShoplist()

end

function PlayerHandler:DetectHeroType()

  for i,nam in pairs(adcs) do
    if nam == myHero.charName then
      heroType = 1
    end
  end

  for i,nam in pairs(adtanks) do
    if nam == myHero.charName then
      heroType = 2
    end
  end

  for i,nam in pairs(aptanks) do
    if nam == myHero.charName then
      heroType = 3
    end
  end

  for i,nam in pairs(hybrids) do
    if nam == myHero.charName then
      heroType = 4
    end
  end

  for i,nam in pairs(bruisers) do
    if nam == myHero.charName then
      heroType = 5
    end
  end

  for i,nam in pairs(assassins) do
    if nam == myHero.charName then
      heroType = 6
    end
  end

  for i,nam in pairs(mages) do
    if nam == myHero.charName then
      heroType = 7
    end
  end

  for i,nam in pairs(apcs) do
    if nam == myHero.charName then
      heroType = 8
    end
  end

  for i,nam in pairs(fighters) do
    if nam == myHero.charName then
      heroType = 9
    end
  end

  if heroType == nil then
    heroType = 10
  end

  if heroType == 1 then
    typeString = "ADC"
  elseif heroType == 2 then
    typeString = "AD TANK"
  elseif heroType == 3 then
    typeString = "AP TANK"
  elseif heroType == 4 then
    typeString = "HYBRID"
  elseif heroType == 5 then
    typeString = "BRUISER"
  elseif heroType == 6 then
    typeString = "ASSASSIN"
  elseif heroType == 7 then
    typeString = "MAGE"
  elseif heroType == 8 then
    typeString = "APC"
  elseif heroType == 9 then
    typeString = "FIGHTER"
  else
    typeString = "UNKNOWN"
  end

  if player.range > 400 then
    ranged = 1
  end

end

function PlayerHandler:GenerateShoplist()

  if heroType == 1 then
    shoplist = { 3006, 1042, 3086, 3087, 3144, 3153, 1038, 3181, 1037, 3035, 3026, 0 }
  end
  if heroType == 2 then
    shoplist = { 3047, 1011, 3134, 3068, 3024, 3025, 3071, 3082, 3143, 3005, 0 }
  end
  if heroType == 3 then
    shoplist = { 3111, 1031, 3068, 1057, 3116, 1026, 3001, 3082, 3110, 3102, 0 }
  end
  if heroType == 4 then
    shoplist = { 1001, 3108, 3115, 3020, 1026, 3136, 3089, 1043, 3091, 3151, 3116, 0 }
  end
  if heroType == 5 then
    shoplist = { 3111, 3134, 1038, 3181, 3155, 3071, 1053, 3077, 3074, 3156, 3190, 0 }
  end
  if heroType == 6 then
    shoplist = { 3020, 3057, 3100, 1026, 3089, 3136, 3151, 1058, 3157, 3135, 0 }
  end
  if heroType == 7 then
    shoplist = { 3028, 1001, 3020, 3136, 1058, 3089, 3174, 3151, 1026, 3001, 3135, 0 }
  end
  if heroType == 8 then
    shoplist = { 3145, 3020, 3152, 1026, 3116, 1058, 3089, 1026, 3001, 3157, 0 }
  end
  if heroType == 9 or heroType == 10 then
    shoplist = { 3111, 3044, 3086, 3078, 3144, 3153, 3067, 3065, 3134, 3071, 3156, 0}
  end

end

function PlayerHandler:LoadAbilitySequence()

  if hero == "Aatrox" then           abilitySequence = { 1, 2, 3, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
  elseif hero == "Ahri" then         abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 2, 2, }
  elseif hero == "Akali" then        abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Alistar" then      abilitySequence = { 1, 3, 2, 1, 3, 4, 1, 3, 1, 3, 4, 1, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Amumu" then        abilitySequence = { 2, 3, 3, 1, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
  elseif hero == "Anivia" then       abilitySequence = { 1, 3, 1, 3, 3, 4, 3, 2, 3, 2, 4, 1, 1, 1, 2, 4, 2, 2, }
  elseif hero == "Annie" then        abilitySequence = { 2, 1, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Ashe" then         abilitySequence = { 2, 3, 2, 1, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
  elseif hero == "Blitzcrank" then   abilitySequence = { 1, 3, 2, 3, 2, 4, 3, 2, 3, 2, 4, 3, 2, 1, 1, 4, 1, 1, }
  elseif hero == "Brand" then        abilitySequence = { 2, 3, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
  elseif hero == "Braum" then        abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Caitlyn" then      abilitySequence = { 2, 1, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Cassiopeia" then   abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Chogath" then      abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
  elseif hero == "Corki" then        abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 2, 3, 2, 4, 2, 2, }
  elseif hero == "Darius" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
  elseif hero == "Diana" then        abilitySequence = { 2, 1, 2, 3, 1, 4, 1, 1, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "DrMundo" then      abilitySequence = { 2, 1, 3, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
  elseif hero == "Draven" then       abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Elise" then        abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, } rOff = -1
  elseif hero == "Evelynn" then      abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Ezreal" then       abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
  elseif hero == "FiddleSticks" then abilitySequence = { 3, 2, 2, 1, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
  elseif hero == "Fiora" then        abilitySequence = { 2, 1, 3, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
  elseif hero == "Fizz" then         abilitySequence = { 3, 1, 2, 1, 2, 4, 1, 1, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Galio" then        abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 3, 3, 2, 2, 4, 3, 3, }
  elseif hero == "Gangplank" then    abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Garen" then        abilitySequence = { 1, 2, 3, 3, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
  elseif hero == "Gragas" then       abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
  elseif hero == "Graves" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 4, 3, 3, 3, 2, 4, 2, 2, }
  elseif hero == "Hecarim" then      abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Heimerdinger" then abilitySequence = { 1, 2, 2, 1, 1, 4, 3, 2, 2, 2, 4, 1, 1, 3, 3, 4, 1, 1, }
  elseif hero == "Irelia" then       abilitySequence = { 3, 1, 2, 2, 2, 4, 2, 3, 2, 3, 4, 1, 1, 3, 1, 4, 3, 1, }
  elseif hero == "Janna" then        abilitySequence = { 3, 1, 3, 2, 3, 4, 3, 2, 3, 2, 1, 2, 2, 1, 1, 1, 4, 4, }
  elseif hero == "JarvanIV" then     abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 2, 1, 4, 3, 3, 3, 2, 4, 2, 2, }
  elseif hero == "Jax" then          abilitySequence = { 3, 2, 1, 2, 2, 4, 2, 3, 2, 3, 4, 1, 3, 1, 1, 4, 3, 1, }
  elseif hero == "Jayce" then        abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, } rOff = -1
  elseif hero == "Karma" then        abilitySequence = { 1, 3, 1, 2, 3, 1, 3, 1, 3, 1, 3, 1, 3, 2, 2, 2, 2, 2, }
  elseif hero == "Karthus" then      abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 1, 3, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Kassadin" then     abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Katarina" then     abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 3, 2, 1, 4, 1, 1, 1, 3, 4, 3, 3, }
  elseif hero == "Kayle" then        abilitySequence = { 3, 2, 3, 1, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
  elseif hero == "Kennen" then       abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
  elseif hero == "Khazix" then       abilitySequence = { 1, 3, 1, 2 ,1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "KogMaw" then       abilitySequence = { 2, 3, 2, 1, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
  elseif hero == "Leblanc" then      abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
  elseif hero == "LeeSin" then       abilitySequence = { 3, 1, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Leona" then        abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
  elseif hero == "Lissandra" then    abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Lucian" then       abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Lulu" then         abilitySequence = { 3, 2, 1, 3, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
  elseif hero == "Lux" then          abilitySequence = { 3, 1, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
  elseif hero == "Malphite" then     abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 2, 3, 2, 4, 2, 2, }
  elseif hero == "Malzahar" then     abilitySequence = { 1, 3, 3, 2, 3, 4, 1, 3, 1, 3, 4, 2, 1, 2, 1, 4, 2, 2, }
  elseif hero == "Maokai" then       abilitySequence = { 3, 1, 2, 3, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
  elseif hero == "MasterYi" then     abilitySequence = { 3, 1, 3, 1, 3, 4, 3, 1, 3, 1, 4, 1, 2, 2, 2, 4, 2, 2, }
  elseif hero == "MissFortune" then  abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "MonkeyKing" then   abilitySequence = { 3, 1, 2, 1, 1, 4, 3, 1, 3, 1, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Mordekaiser" then  abilitySequence = { 3, 1, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
  elseif hero == "Morgana" then      abilitySequence = { 1, 2, 2, 3, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
  elseif hero == "Nami" then         abilitySequence = { 1, 2, 3, 2, 2, 4, 2, 2, 3, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
  elseif hero == "Nasus" then        abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
  elseif hero == "Nautilus" then     abilitySequence = { 2, 3, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
  elseif hero == "Nidalee" then      abilitySequence = { 2, 3, 1, 3, 1, 4, 3, 2, 3, 1, 4, 3, 1, 1, 2, 4, 2, 2, }
  elseif hero == "Nocturne" then     abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Nunu" then         abilitySequence = { 3, 1, 3, 2, 1, 4, 3, 1, 3, 1, 4, 1, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Olaf" then         abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Orianna" then      abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Pantheon" then     abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 2, 3, 2, 4, 2, 2, }
  elseif hero == "Poppy" then        abilitySequence = { 3, 2, 1, 1, 1, 4, 1, 2, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, }
  elseif hero == "Quinn" then        abilitySequence = { 3, 1, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Rammus" then       abilitySequence = { 1, 2, 3, 3, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
  elseif hero == "Renekton" then     abilitySequence = { 2, 1, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Rengar" then       abilitySequence = { 1, 3, 2, 1, 1, 4, 2, 1, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Riven" then        abilitySequence = { 1, 2, 3, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
  elseif hero == "Rumble" then       abilitySequence = { 3, 1, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Ryze" then         abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Sejuani" then      abilitySequence = { 2, 1, 3, 3, 2, 4, 3, 2, 3, 3, 4, 2, 1, 2, 1, 4, 1, 1, }
  elseif hero == "Shaco" then        abilitySequence = { 2, 3, 1, 3, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
  elseif hero == "Shen" then         abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Shyvana" then      abilitySequence = { 2, 1, 2, 3, 2, 4, 2, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, }
  elseif hero == "Singed" then       abilitySequence = { 1, 3, 1, 3, 1, 4, 1, 2, 1, 2, 4, 3, 2, 3, 2, 4, 2, 3, }
  elseif hero == "Sion" then         abilitySequence = { 1, 3, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
  elseif hero == "Sivir" then        abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
  elseif hero == "Skarner" then      abilitySequence = { 1, 2, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 3, 3, 3, 4, 3, 3, }
  elseif hero == "Sona" then         abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Soraka" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 4, 2, 3, 2, 3, 4, 2, 3, }
  elseif hero == "Swain" then        abilitySequence = { 2, 3, 3, 1, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
  elseif hero == "Syndra" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Talon" then        abilitySequence = { 2, 3, 1, 2, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
  elseif hero == "Taric" then        abilitySequence = { 3, 2, 1, 2, 2, 4, 1, 2, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
  elseif hero == "Teemo" then        abilitySequence = { 1, 3, 2, 3, 1, 4, 3, 3, 3, 1, 4, 2, 2, 1, 2, 4, 2, 1, }
  elseif hero == "Thresh" then       abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
  elseif hero == "Tristana" then     abilitySequence = { 3, 2, 2, 3, 2, 4, 2, 1, 2, 1, 4, 1, 1, 1, 3, 4, 3, 3, }
  elseif hero == "Trundle" then      abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 3, 4, 2, 3, 2, 3, 4, 2, 3, }
  elseif hero == "Tryndamere" then   abilitySequence = { 3, 1, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "TwistedFate" then  abilitySequence = { 2, 1, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Twitch" then       abilitySequence = { 1, 3, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 1, 2, 2, }
  elseif hero == "Udyr" then         abilitySequence = { 4, 2, 3, 4, 4, 2, 4, 2, 4, 2, 2, 1, 3, 3, 3, 3, 1, 1, }
  elseif hero == "Urgot" then        abilitySequence = { 3, 1, 1, 2, 1, 4, 1, 2, 1, 3, 4, 2, 3, 2, 3, 4, 2, 3, }
  elseif hero == "Varus" then        abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Vayne" then        abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Veigar" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 2, 2, 2, 2, 4, 3, 1, 1, 3, 4, 3, 3, }
  elseif hero == "Velkoz" then       abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 1, 2, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Vi" then           abilitySequence = { 3, 1, 2, 3, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
  elseif hero == "Viktor" then       abilitySequence = { 3, 2, 3, 1, 3, 4, 3, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, }
  elseif hero == "Vladimir" then     abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Volibear" then     abilitySequence = { 2, 3, 2, 1, 2, 4, 3, 2, 1, 2, 4, 3, 1, 3, 1, 4, 3, 1, }
  elseif hero == "Warwick" then      abilitySequence = { 2, 1, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 3, 2, 4, 2, 2, }
  elseif hero == "Xerath" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "XinZhao" then      abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Yorick" then       abilitySequence = { 2, 3, 1, 3, 3, 4, 3, 2, 3, 1, 4, 2, 1, 2, 1, 4, 2, 1, }
  elseif hero == "Zac" then          abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Zed" then          abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Ziggs" then        abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  elseif hero == "Zilean" then       abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  elseif hero == "Zyra" then         abilitySequence = { 3, 2, 1, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
  else                               abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 1, 2, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
  end
  if abilitySequence and #abilitySequence == 18 then

  else
    PrintChat(" >> AutoLevel Error")
    OnTick = function() end
    return
  end

end

function PlayerHandler:AutoLevel()

  if not Menu.opts.manualMode and Menu.opts.autoLevel then

    local qL, wL, eL, rL = player:GetSpellData(_Q).level + qOff, player:GetSpellData(_W).level + wOff, player:GetSpellData(_E).level + eOff, player:GetSpellData(_R).level + rOff

    if qL + wL + eL + rL < player.level then

      local spellSlot = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
      local level = { 0, 0, 0, 0 }

      for i = 1, player.level, 1 do

        level[abilitySequence[i]] = level[abilitySequence[i]] + 1

      end

      for i, v in ipairs({ qL, wL, eL, rL }) do

        if v < level[i] then LevelSpell(spellSlot[i]) end

      end

    end

  end

end

---------------------------------------
-- Handle Items and manage inventory --
---------------------------------------

class 'InventoryHandler'
function InventoryHandler:__init()

  if Menu.auto.enableBuy then

    self:BuyItems()

  end

  if Menu.auto.enableSell then

    self:SellItems()

  end


end

function InventoryHandler:Load()

  self:CheckItems()
  self:UpdateItems()

end

function InventoryHandler:CheckItems()

  for index = 1, #shoplist do

    if GetInventorySlotItem(shoplist[index]) ~= nil then

      if shoplist[index] ~= 0 then

        table.insert(inventoryTable, index, shoplist[index])

      end

    end

  end

end

function InventoryHandler:UpdateItems()

  for index = 1, #inventoryTable do

    if inventoryTable[index] ~= nil or inventoryTable[index] ~= 0 then

      buyIndex = GetLastIndex(inventoryTable) + 1

    end

  end

end

function InventoryHandler:SellItems()

end

function InventoryHandler:BuyItems()

  if shoplist[buyIndex] ~= 0 then

    local itemval = shoplist[buyIndex]

    BuyItem(itemval)

    if GetInventorySlotItem(shoplist[buyIndex]) ~= nil then

      --Last Buy successful
      buyIndex = buyIndex + 1
      self:BuyItems()

    end

  end

end

------------------
-- Do bot stuff --
------------------

class 'Bot'

local stance

function Bot:__init()

  self:Load()

end

function Bot:Load()

  if stance == 0 then

    self:ModeDef()

  elseif stance == 1 then

    self:ModeTF()

  elseif stance == 2 then

    self:ModeFarm()

  elseif stance == 3 then

    self:ModePush()

  else

    self:ModeDef()

  end

end

function Bot:ModeDef()

  stName = "Defense"

end

function Bot:ModeTF()

  stName = "Teamfight"

end

function Bot:ModeFarm()

  stName = "Farm"

  self:Farm()

end

function Bot:ModePush()

  stName = "Push"

end

function Bot:Allies()

  local allyCout = 0

  for i = 1, heroManager.iCount do

    indexedHero = heroManager:GetHero(i)

    if indexedHero.team == hero.team and not indexedHero.dead and GetDistance(indexedHero) < 400 then

      allyCout = allyCout + 1

    end

  end

  return allyCout

end

function Bot:Farm()



end

function Bot:Follow()

end

-------------------------------------------------
-- Inspired by PAS, sends chosen chat messages --
-------------------------------------------------

class "ChatHandler"

chatTableStart, chatTableGameAlive, chatTableGameDead, chatTableEnd = {}, {}, {}, {}

local chatNextDelay, chatNextDelay2 = 0, 0

function ChatHandler:__init()

  if Menu.chat.enabled then

    self:StartupMessage()

    if os.clock() > chatNextDelay and player.dead  then

      SendChat(chatTableGameDead[math.random(2, #chatTableGameDead)])
      chatNextDelay = os.clock() + 70 -- DELAY METHOD VERY IMPORTANT

    end

    if os.clock() > chatNextDelay2  then

      SendChat(chatTableGameAlive[math.random(2, #chatTableGameAlive)])
      chatNextDelay2 = os.clock() + math.random(Menu.chat.delay, Menu.chat.delay + 10) -- DELAY METHOD VERY IMPORTANT

    end

  end

end

function ChatHandler:Load()

  local path = SCRIPT_PATH .. scriptName .. "\\chat.txt"

  if FileExist(path) then

    local file = io.open(path)

    local cout, id = 1, 1

    for line in file:lines() do

      if string.match(line, "-- GAME START") then

        id = 1
        cout = 1

      elseif string.match(line, "-- GAME ALIVE") then

        id = 2
        cout = 1

      elseif string.match(line, "-- GAME DEAD") then

        id = 3
        cout = 1

      elseif string.match(line, "-- GAME END") then

        id = 4
        cout = 1

      end

      if id == 1 then

        table.insert(chatTableStart, cout, line)
        cout = cout + 1

      elseif id == 2 then

        table.insert(chatTableGameAlive, cout, line)
        cout = cout + 1

      elseif id == 3 then

        table.insert(chatTableGameDead, cout, line)
        cout = cout + 1

      elseif id == 4 then

        table.insert(chatTableEnd, cout, line)
        cout = cout + 1

      end

      if string.match(line, "-- END") then

        file:close()
        break

      end

    end

  else
    
    DownloadFile("http://pastebin.com/download.php?i=PPSeuMPw", path, function() end)
    
    self:Load()

  end

  chatNextDelay = os.clock() + 35
  chatNextDelay2 = os.clock() + 135

end

local chatFlag1 = false

function ChatHandler:StartupMessage(msg)

  if GetInGameTimer() < math.random(6,12) then

    if not chatFlag1 then

      self:SendMessage(chatTableStart[math.random(2, #chatTableStart)])
      chatFlag1 = true

    end

  end

end

function ChatHandler:SendMessage(msg)

  SendChat(msg)

end



------------------------------
-- Handle Drawings and Such --
------------------------------

class 'DrawingHandler'
function DrawingHandler:__init()

  if Menu.draw.enabled then

    self:DrawBaseRectangles()
    self:DrawTitle()
    self:DrawStatus()
    self:DrawAARange()

    if Menu.draw.drawNextBuy then

      self:DrawItem(shoplist[buyIndex], drawConstants.textStartX, drawConstants.textEndY)

    end

    if Menu.draw.drawMode then

    end

  end

end

function DrawingHandler:DrawBaseRectangles()

  DrawRectangle(drawConstants.x - 10, drawConstants.y - 10, drawConstants.rectX1 + 20, drawConstants.rectY2 + 20, ARGB(60,12,12,12))
  DrawRectangle(drawConstants.x, drawConstants.y, drawConstants.rectX1, drawConstants.rectY1, ARGB(75,12,12,12))
  DrawRectangle(drawConstants.x, drawConstants.y + 50, drawConstants.rectX2, drawConstants.rectY2 - 50, ARGB(75,12,12,12))

end

function DrawingHandler:DrawTitle()

  local color

  if Menu.opts.enabled then

    color = colors.white

  else

    color = colors.darkRed

  end

  DrawText("-- astorARAM " .. version .. " --", drawConstants.textSize, drawConstants.textStartX + 75, drawConstants.textStartY, color)

end

function DrawingHandler:DrawStatus()

  local status = nil
  local color = colors.white

  DrawText("Script Status: ", drawConstants.textSize, drawConstants.textStartX, drawConstants.textStartY + drawConstants.textYOffset * 2, colors.white)

  if Menu.opts.manualMode then

    status = "Manual Control"
    color = colors.darkRed

  else

    status = "Automatic Control"
    color = colors.brightGreen

  end

  DrawText(status, drawConstants.textSize, drawConstants.textStartX2, drawConstants.textStartY + drawConstants.textYOffset * 2, color)

end

function DrawingHandler:DrawItem(item, x, y)

  local nextBuyStr = "Next Item: "

  if ItemTable[item].name ~= nil then

    nextItemStr = ItemTable[item].name

    DrawText(nextBuyStr, drawConstants.textSize, x, y, colors.white)

    if Menu.auto.enableBuy then

      DrawText(nextItemStr, drawConstants.textSize, drawConstants.textStartX + 120, y, colors.brightGreen)

    else

      DrawText("Autobuy Disabled", drawConstants.textSize, drawConstants.textStartX + 120, y, colors.darkRed)

    end

  end

end

function DrawingHandler:DrawAARange()

  if Menu.draw.drawRange then

    if Menu.draw.lfc then

      self:DrawCircle2(player.x, player.y, player.z, getTrueRange(), colors.brightGreen)

    else

      DrawCircle(player.x, player.y, player.z, getTrueRange(), colors.brightGreen)

    end

  end

end

function DrawingHandler:DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)

  radius = radius or 300

  quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))

  quality = 2 * math.pi / quality

  radius = radius*.92

  local points = {}

  for theta = 0, 2 * math.pi + quality, quality do

    local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
    points[#points + 1] = D3DXVECTOR2(c.x, c.y)

  end

  DrawLines2(points, width or 1, color or 4294967295)

end

function DrawingHandler:DrawCircle2(x, y, z, radius, color)

  local vPos1 = Vector(x, y, z)
  local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
  local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
  local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))

  if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then

    self:DrawCircleNextLvl(x, y, z, radius, 1, color, 75)

  end

end

---------------------------------------
-- Detect game end, and kill process --
---------------------------------------

class 'EndgameHandler'

function EndgameHandler:__init()

  if GetGame().isOver and not Exit then

    Exit = true
    self:Quit(7)

  end

end

function EndgameHandler:Quit(timeout)

  RunAsyncCmdCommand("cmd /c" .. (timeout and (" ping -n " .. math.floor(timeout) .. " 127.0.0.1>nul &&") or "") .. ' taskkill /im "League of Legends.exe"')
  DelayAction(os.exit, (timeout or 0) + 5, { 0 }) -- Force Quit

end


------------------------------------------------------
-- Random Ass Functions that had nowhere to be kept --
------------------------------------------------------
function table.len(t)

  local cout = 0

  for _ in pairs(t) do cout = cout + 1 end
  return cout

end

function round(num)

  if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end

end

function GetLastIndex(t)
  local lowest, highest

  for k in pairs(t) do
    if type(k) == "number" and k % 1 == 0 and k > 0 then -- Assuming mixed (possibly non-integer) keys
      if lowest then
        lowest = math.min(lowest, k)
        highest = math.max(highest, k)
    else
      lowest, highest = k, k
    end
    end
  end

  return highest or 0 -- "or 0" in case there were no indices
end

function getTrueRange()

  return player.range + GetDistance(myHero.minBBox) + 50

end
