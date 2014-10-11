--[[

    GIBE SUPPORT PLOX v0.1 - Astoriane Support Bundle - Template

]]

if myHero.charName ~= "" then return end

local ScriptName = "SuppPlox"
local ScriptVersion = 0.1

local AutoUpdate = false
local SrcLibURL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SrcLibPath = LIB_PATH .. "SourceLib.lua"
local SrcLibDownload = false

local orbwalker = "SOW"

if FileExist(SrcLibPath) then

    require "SourceLib"
    SrcLibDownload = false

else

    SrcLibDownload = true
    DownloadFile(SrcLibURL, SrcLibPath, function SendMessage("Downloaded SourceLib, please reload. [Double F9]") end)

end

if SrcLibDownload == true then

    SendMessage("SourceLib was not found. Downloading...")
    return

end

if AutoUpdate then

    SourceUpdater(ScriptName .. " - " .. myHero.charName, tostring(ScriptVersion), "raw.github.com", "Astoriane/BoL-Scripts/SuppPlox/master/" .. ScriptName .. " - " .. myHero.charName .. ".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME):CheckUpdate()

end

local libs = Require(ScriptName .. " Libs")
libs:Add("VPrediction", "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua")
libs:Add("SOW", "https://raw.githubusercontent.com/Hellsing/BoL/master/common/SOW.lua")
libs:Add("Prodiction", "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/ec830facccefb3b52212dba5696c08697c3c2854/Test/Prodiction/Prodiction.lua")

libs:Check()

if libs.downloadNeeded == true then return end

local SpellTable = {
    
    [_Q] = {

        name = "",
        ready = false,
        range = 0,
        width = 0,
        speed = 0,
        delay = 0,
        self = false,
        ally = false

    },

    [_W] = {

        name = "",
        ready = false,
        range = 0,
        width = 0,
        speed = 0,
        delay = 0,
        self = false,
        ally = false

    },

    [_E] = {

        name = "",
        ready = false,
        range = 0,
        width = 0,
        speed = 0,
        delay = 0,
        self = false,
        ally = false

    },

    [_R] = {

        name = "",
        ready = false,
        range = 0,
        width = 0,
        speed = 0,
        delay = 0,
        self = false,
        ally = false

    }

}

local ItemTable = {
    
    [3092] = { id = "fqc",      name = "Frost Queen's Claim",        range = 850, slot = nil, ready = false },
    [3143] = { id = "ro",       name = "Randuin's Omen",             range = 500, slot = nil, ready = false },
    [3190] = { id = "locket",   name = "Locket of the Iron Solari",  range = 600, slot = nil, ready = false },
    [3222] = { id = "mc",       name = "Mikael's Crucible",          range = 600, slot = nil, ready = false }

}

local TargetList = {[_Q] = nil, [_W] = nil, [_E] = nil, [_R] = nil, ["main"] = nil}
local Recalling

function OnLoad()

    __initLibs()
    __initMenu()
    __initOrbwalkers()

end

function OnTick()

    if not _G.SuppPlox_Loaded then return end

end 

function OnUnload()

    if not _G.SuppPlox_Loaded then return end

end

function OnDraw()

    if not _G.SuppPlox_Loaded then return end

end

function OnProcessSpell(unit, spell)

    if not _G.SuppPlox_Loaded then return end

end

function OnCreateObj(obj)

    if not _G.SuppPlox_Loaded then return end

end

function OnDeleteObj(obj)

    if not _G.SuppPlox_Loaded then return end

end

function SendMessage(msg)

    PrintChat(tostring(msg))

end

function __initLibs()

    VP = VPrediction()
    STS = SimpleTS(STS_PRIORITY)
    SOWi = SOW(VP)
    PROD = Prodiction

end

function __initMenu()

    Menu = scriptConfig("[" .. ScriptName .. "] " .. myHero.charName, "SuppPlox"..myHero.charName)

    Menu:addSubMenu("[" .. myHero.charName.. "] Keybindings", "keys")
        Menu.keys:addParam("carry", "Carry Mode Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
        Menu.keys:addParam("harass", "Harass Mode Key". SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))

    Menu:addSubMenu("[" .. myHero.charName.. "] Combo", "combo")
        Menu.combo:addParam("useQ", "Enable Q (".. SpellTable[_Q].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.combo:addParam("useW", "Enable W (".. SpellTable[_W].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.combo:addParam("useE", "Enable E (".. SpellTable[_E].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.combo:addParam("useR", "Enable R (".. SpellTable[_R].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.combo:addParam("mana", "Min Mana For Combo", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)

    Menu:addSubMenu("[" .. myHero.charName.. "] Harass", "harass")
        Menu.harass:addParam("useQ", "Enable Q (".. SpellTable[_Q].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.harass:addParam("useW", "Enable W (".. SpellTable[_W].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.harass:addParam("useE", "Enable E (".. SpellTable[_E].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.harass:addParam("useR", "Enable R (".. SpellTable[_R].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.harass:addParam("mana", "Min Mana For Harass", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)

    Menu:addSubMenu("[" .. myHero.charName.. "] Farm", "farm")
        Menu.farm:addParam("useQ", "Enable Q (".. SpellTable[_Q].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.farm:addParam("useW", "Enable W (".. SpellTable[_W].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.farm:addParam("useE", "Enable E (".. SpellTable[_E].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.farm:addParam("mana", "Min Mana For Lane Clear", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)

    Menu:addSubMenu("[" .. myHero.charName.. "] Orbwalk", "orbwalk")
        SOWi:LoadToMenu(Menu.orbwalk, STS)

    Menu:addSubMenu("[" .. myHero.charName.. "] Items", "item")
        for ItemID, Values in pairs(ItemTable) do

            Menu.item:addParam(string.lower(tostring(Values.id)), "Enable " .. tostring(Values.name), SCRIPT_PARAM_ONOFF, true)

        end

    Menu:addSubMenu("[" .. myHero.charName.. "] Draw", "draw")
        Menu.draw:addParam("drawAA", "Draw AutoAttack Range". SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawQ", "Draw ".. SpellTable[_Q].name .." Range". SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawW", "Draw ".. SpellTable[_W].name .." Range". SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawE", "Draw ".. SpellTable[_E].name .." Range". SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawR", "Draw ".. SpellTable[_R].name .." Range". SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawTarget", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)

    Menu:addSubMenu("[" .. myHero.charName.. "] Misc", "misc")
        if VIP_USER then
            Menu.misc:addParam("pred", "Prediction", SCRIPT_PARAM_LIST, 1, {"Prodiction", "VPrediction"})
        else
            Menu.misc:addParam("info", "Prediction: VPrediction", SCRIPT_PARAM_INFO, "")
        end

    if VIP_USER then

        Menu:addSubMenu("Choose Skin", "skin")

    end

end

function __initOrbwalkers()

    if _G.Reborn_Loaded then

        SendMessage("SAC:R Detected. Disabling SOW.")
        orbwalker = "SAC"
        Menu.orbwalk.Enabled = false

    elseif _G.MMA_Loaded then

        SendMessage("MMA Detected. Disabling SOW.")
        orbwalker = "MMA"
        Menu.orbwalk.Enabled = false

    elseif _G.SxOrbMenu then

        SendMessage("SxOrbwalk Detected. Disabling SOW.")
        orbwalker = "SxOrb"
        Menu.orbwalk.Enabled = false

    end

    if not _G.SuppPlox_Loaded then _G.SuppPlox_Loaded = true end

end

function Update()

    local Allies = GetAlliedHeroes()

    -- SKILLS --
    for i in pairs(SpellTable) do
        SpellTable[i].ready = myHero:CanUseSpell(i) == READY
    end
    -- SKILLS --

    -- ITEMS --
    for ItemID in pairs(ItemTable) do
        if GetInventoryHaveItem(ItemID) then
            ItemTable[ItemID].slot = GetInventorySlotItem(ItemID)
            ItemTable[ItemID].ready = myHero:CanUseSpell(ItemTable[ItemID].slot) == READY
        end

    end
    -- ITEMS --

    -- MAIN TARGET --
    if not Menu.orbwalk.enabled and (_G.Reborn_Loaded or _G.MMA_Loaded or _G.SxOrbMenu) then

        if _G.Reborn_Loaded then
            if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then
                TargetList["main"] = _G.AutoCarry.Attack_Crosshair.target
            else
                TargetList["main"] = STS:GetTarget(myHero.range)
            end
        elseif _G.MMA_Loaded then
            if _G.MMA_Target and _G.MMA_Target.type == myHero.type then
                TargetList["main"] = _G.MMA_Target
            else
                TargetList["main"] = STS:GetTarget(myHero.range)
            end
        elseif
            if SxOrb then
                TargetList["main"] = SxOrb:GetTarget()
            end
        end

    else

        TargetList["main"] = STS:GetTarget(math.max(SpellTable[_Q].range, SpellTable[_W].range, SpellTable[_E].range, SpellTable[_R].range, myHero.range))

    end
    -- MAIN TARGET --

    -- SKILL TARGETS --
    TargetList[_Q] = STS:GetTarget(SpellTable[_Q].range or (if SpellTable[_Q].ally then GetClosestAlly() end) or (if SpellTable[_Q].self then myHero end) or nil)
    TargetList[_W] = STS:GetTarget(SpellTable[_W].range or (if SpellTable[_W].ally then GetClosestAlly() end) or (if SpellTable[_W].self then myHero end) or nil)
    TargetList[_E] = STS:GetTarget(SpellTable[_E].range or (if SpellTable[_E].ally then GetClosestAlly() end) or (if SpellTable[_E].self then myHero end) or nil)
    TargetList[_R] = STS:GetTarget(SpellTable[_R].range or (if SpellTable[_R].ally then GetClosestAlly() end) or (if SpellTable[_R].self then myHero end) or nil)
    -- SKILL TARGETS --

end

function GetAlliesNearHero(vrange)
    local count = 0
    for i=1, heroManager.iCount do
        currentAlly = heroManager:GetHero(i)
        if currentAlly.team == myHero.team and currentAlly.charName ~= myHero.charName then
            if myHero:GetDistance(currentAlly) <= vrange and not currentAlly.dead then count = count + 1 end
        end
    end
    return count
end

function GetEnemiesNearHero(vrange)
    count = 0
    for i=1, heroManager.iCount do
        currentEnemy = heroManager:GetHero(i)
        if currentEnemy.team ~= myHero.team then
            if myHero:GetDistance(currentEnemy) <= vrange and not currentEnemy.dead then count = count + 1 end
        end
    end
    return count
end

function GetClosestAlly()
    local distance = 25000
    local closest = nil
    for i=1, heroManager.iCount do
        currentAlly = heroManager:GetHero(i)
        if currentAlly.team == myHero.team and currentAlly.charName ~= myHero.charName and not currentAlly.dead and myHero:GetDistance(currentAlly) < distance then
            distance = person:GetDistance(currentAlly)
            closest = currentAlly
        end
    end
    return closest
end