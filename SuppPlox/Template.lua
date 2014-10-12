--[[

    GIBE SUPPORT PLOX v0.1 - Astoriane Support Bundle - TEMPLATE

]]

if myHero.charName ~= "" then return end

local ScriptName = "SuppPlox"
local ScriptVersion = 0.1

local AutoUpdate = false
local SrcLibURL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SrcLibPath = LIB_PATH .. "SourceLib.lua"
local SrcLibDownload = false

local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "Astoriane/BoL-Scripts/SuppPlox/master/" .. ScriptName .. " - " .. myHero.charName .. ".lua"

local orbwalker = "SOW"

function SendMessage(msg)

    PrintChat("<font color='#7D1935'><b>[" .. ScriptName .. " " .. myHero.charName .. "]</b> </font><font color='#FFFFFF'>" .. tostring(msg) .. "</font>")

end

if FileExist(SrcLibPath) then

    require "SourceLib"
    SrcLibDownload = false

else

    SrcLibDownload = true
    DownloadFile(SrcLibURL, SrcLibPath, function() SendMessage("Downloaded SourceLib, please reload. (Double F9)") end)

end

if SrcLibDownload == true then

    SendMessage("SourceLib was not found. Downloading...")
    return

end

if AutoUpdate then

    SourceUpdater(ScriptName .. " - " .. myHero.charName, tostring(ScriptVersion), UPDATE_HOST, UPDATE_PATH, SCRIPT_PATH .. GetCurrentEnv().FILE_NAME):CheckUpdate()

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

    __load()
    __initLibs()
    __initMenu()
    __initOrbwalkers()

end

function OnTick()

    if not _G.SuppPlox_Loaded then return end

    Update()

end 

function OnUnload()

    if not _G.SuppPlox_Loaded then return end

end

function OnDraw()

    if not _G.SuppPlox_Loaded then return end

    __draw()

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

function __load()

    SendMessage("SuppPlox by Astoriane")
    SendMessage("Script version v" .. ScriptVersion .. " loaded for " .. myHero.charName)

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
        Menu.keys:addParam("carry", "Carry Mode Key:", SCRIPT_PARAM_ONKEYDOWN, false, 32)
        Menu.keys:addParam("harass", "Harass Mode Key:", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))
        Menu.keys:addParam("farm", "Lane Clear Mode Key:", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('V'))


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
        Menu.draw:addParam("enabled", "Enable All Drawings", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawAA", "Draw AutoAttack Range", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawQ", "Draw ".. SpellTable[_Q].name .." Range", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawW", "Draw ".. SpellTable[_W].name .." Range", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawE", "Draw ".. SpellTable[_E].name .." Range", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawR", "Draw ".. SpellTable[_R].name .." Range", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawTarget", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("lfc", "Use Lag Free Circles", SCRIPT_PARAM_ONOFF, true)

    Menu:addSubMenu("[" .. myHero.charName.. "] Misc", "misc")
        Menu.misc:addParam("packet", "Use Packets to Cast Spells", SCRIPT_PARAM_ONOFF, false)
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
        elseif _G.SxOrbMenu then
            if SxOrb then
                TargetList["main"] = SxOrb:GetTarget()
            end
        end

    else

        TargetList["main"] = STS:GetTarget(math.max(SpellTable[_Q].range, SpellTable[_W].range, SpellTable[_E].range, SpellTable[_R].range, myHero.range))

    end
    -- MAIN TARGET --

    -- SKILL TARGETS --
    -- TargetList[_Q] = STS:GetTarget(SpellTable[_Q].range or (if SpellTable[_Q].ally then GetClosestAlly() end) or (if SpellTable[_Q].self then myHero end) or nil)
    -- TargetList[_W] = STS:GetTarget(SpellTable[_W].range or (if SpellTable[_W].ally then GetClosestAlly() end) or (if SpellTable[_W].self then myHero end) or nil)
    -- TargetList[_E] = STS:GetTarget(SpellTable[_E].range or (if SpellTable[_E].ally then GetClosestAlly() end) or (if SpellTable[_E].self then myHero end) or nil)
    -- TargetList[_R] = STS:GetTarget(SpellTable[_R].range or (if SpellTable[_R].ally then GetClosestAlly() end) or (if SpellTable[_R].self then myHero end) or nil)
    -- SKILL TARGETS --

end

-- SCRIPT FUNCTIONS --
function Combo()

end

function Harass()

end

function Farm()

end
-- SCRIPT FUNCTIONS --

-- SKILL FUNCTIONS --
function CastQ()

end

function CastW()

end

function CastE()

end

function CastR()

end
-- SKILL FUNCTIONS --

function CanCastQ(mode, target)

    mode = mode or 1
    target = target or TargetList[_Q]

    if mode == 1 then -- CARRY MODE

        -- Spell not ready
        if (not SpellTable[_Q].ready)

        -- No target
        or (not TargetList[_Q])

        -- Disabled
        or (not Menu.carry.useQ)

        -- Not enought mana
        or (myManaPct() < Menu.carry.mana)

        -- Out of range
        or (GetDistance(TargetList[_Q]) > myHero.range + SpellTable[_Q].range)

        -- Disabled Target
        -- or (not Menu.skills.q[TargetList[_Q].hash])

        then return false end

    elseif mode == 2 then -- MIXED MODE

        if myHero:GetSpellData(_Q).level < 1 then return false end
        MMTarget = STS:GetTarget(myHero.range + SpellTable[_Q].range)

        -- Spell not ready
        if (not SpellTable[_Q].ready)

        -- No target
        or (not MMTarget)

        -- Not enought mana
        or (myManaPct() < Menu.harass.mana)

        -- Out of Range
        or (GetDistance(MMTarget) > myHero.range + SpellTable[_Q].range)

        -- Use on heroes
        or (MMTarget.type ~= myHero.type)

        -- Disabled Target
        -- (MMTarget.type == myHero.type and not Menu.skills.w[TargetList[_Q].hash])

        then return false end

    elseif mode == 3 then -- CLEAR MODE

        -- Spell not ready
        if (not SpellTable[_Q].ready)

        -- No Target
        or (not target)

        -- Disabled
        or (not Menu.farm.useQ)

        -- Not enought mana
        or (myManaPct() < Menu.farm.mana)

        -- Out of range
        or (GetDistance(target) > myHero.range + SpellTable[_Q].range)

        then return false end

    end

    return true

end

function CanCastW(mode, target)

    mode = mode or 1
    target = target or TargetList[_W]

    if mode == 1 then -- CARRY MODE

        -- Spell not ready
        if (not SpellTable[_W].ready)

        -- No target
        or (not TargetList[_W])

        -- Disabled
        or (not Menu.carry.useW)

        -- Not enought mana
        or (myManaPct() < Menu.carry.mana)

        -- Out of range
        or (GetDistance(TargetList[_W]) > myHero.range + SpellTable[_W].range)

        -- Disabled Target
        -- or (not Menu.skills.q[TargetList[_W].hash])

        then return false end

    elseif mode == 2 then -- MIXED MODE

        if myHero:GetSpellData(_W).level < 1 then return false end
        MMTarget = STS:GetTarget(myHero.range + SpellTable[_W].range)

        -- Spell not ready
        if (not SpellTable[_W].ready)

        -- No target
        or (not MMTarget)

        -- Not enought mana
        or (myManaPct() < Menu.harass.mana)

        -- Out of Range
        or (GetDistance(MMTarget) > myHero.range + SpellTable[_W].range)

        -- Use on heroes
        or (MMTarget.type ~= myHero.type)

        -- Disabled Target
        -- (MMTarget.type == myHero.type and not Menu.skills.w[TargetList[_Q].hash])

        then return false end

    elseif mode == 3 then -- CLEAR MODE

        -- Spell not ready
        if (not SpellTable[_W].ready)

        -- No Target
        or (not target)

        -- Disabled
        or (not Menu.farm.useW)

        -- Not enought mana
        or (myManaPct() < Menu.farm.mana)

        -- Out of range
        or (GetDistance(target) > myHero.range + SpellTable[_W].range)

        then return false end

    end

    return true

end

function CanCastE(mode, target)

    mode = mode or 1
    target = target or TargetList[_E]

    if mode == 1 then -- CARRY MODE

        -- Spell not ready
        if (not SpellTable[_E].ready)

        -- No target
        or (not TargetList[_E])

        -- Disabled
        or (not Menu.carry.useE)

        -- Not enought mana
        or (myManaPct() < Menu.carry.mana)

        -- Out of range
        or (GetDistance(TargetList[_E]) > myHero.range + SpellTable[_E].range)

        -- Disabled Target
        -- or (not Menu.skills.q[TargetList[_Q].hash])

        then return false end

    elseif mode == 2 then -- MIXED MODE

        if myHero:GetSpellData(_E).level < 1 then return false end
        MMTarget = STS:GetTarget(myHero.range + SpellTable[_E].range)

        -- Spell not ready
        if (not SpellTable[_E].ready)

        -- No target
        or (not MMTarget)

        -- Not enought mana
        or (myManaPct() < Menu.harass.mana)

        -- Out of Range
        or (GetDistance(MMTarget) > myHero.range + SpellTable[_E].range)

        -- Use on heroes
        or (MMTarget.type ~= myHero.type)

        -- Disabled Target
        -- (MMTarget.type == myHero.type and not Menu.skills.w[TargetList[_Q].hash])

        then return false end

    elseif mode == 3 then -- CLEAR MODE

        -- Spell not ready
        if (not SpellTable[_E].ready)

        -- No Target
        or (not target)

        -- Disabled
        or (not Menu.farm.useE)

        -- Not enought mana
        or (myManaPct() < Menu.farm.mana)

        -- Out of range
        or (GetDistance(target) > myHero.range + SpellTable[_E].range)

        then return false end

    end

    return true

end

function CanCastR(mode, target, min)

    mode = mode or 1
    target = target or TargetList[_R]

    if mode == 1 then -- CARRY MODE

        -- Spell not ready
        if (not SpellTable[_R].ready)

        -- No target
        or (not TargetList[_R])

        -- Disabled
        or (not Menu.carry.useR)

        -- Not enought mana
        or (myManaPct() < Menu.carry.mana)

        -- Out of range
        or (GetDistance(TargetList[_R]) > myHero.range + SpellTable[_R].range)

        -- Disabled Target
        -- or (not Menu.skills.q[TargetList[_R].hash])

        then return false end

    elseif mode == 2 then -- MIXED MODE

        if myHero:GetSpellData(_R).level < 1 then return false end
        MMTarget = STS:GetTarget(myHero.range + SpellTable[_R].range)

        -- Spell not ready
        if (not SpellTable[_R].ready)

        -- No target
        or (not MMTarget)

        -- Out of Range
        or (GetDistance(MMTarget) > myHero.range + SpellTable[_R].range)

        -- Not enought mana
        or (myManaPct() < Menu.harass.mana)

        -- Use on heroes
        or (MMTarget.type ~= myHero.type)

        -- Disabled Target
        -- (MMTarget.type == myHero.type and not Menu.skills.w[TargetList[_Q].hash])

        -- Minimum targets
        -- or (not target or #TargetList[_R] < min)

        then return false end

    elseif mode == 3 then -- CLEAR MODE

        -- Spell not ready
        if (not SpellTable[_R].ready)

        -- No Target
        or (not target)

        -- Disabled
        or (not Menu.farm.useR)

        -- Not enought mana
        or (myManaPct() < Menu.farm.mana)

        -- Out of range
        or (GetDistance(target) > myHero.range + SpellTable[_R].range)

        then return false end

    end

    return true

end

-- MAIN DRAW FUNCTION --
function __draw()

    DrawCircles()
    DrawText()

end
-- MAIN DRAW FUNCION --

-- DRAW FUNCTIONS -- 
function DrawCircles()

    if Menu and Menu.draw and Menu.draw.enabled then

        if Menu.draw.lfc then -- LAG FREE CIRCLES

            if Menu.draw.drawAA then DrawCircleLFC(myHero.x, myHero.y, myHero.z, SOWi:MyRange() + 50, ARGB(255,255,255,255)) end -- DRAW AA RANGE

            if Menu.draw.drawQ and SpellTable[_Q].ready then DrawCircleLFC(myHero.x, myHero.y, myHero.z, SpellTable[_Q].range, ARGB(255,255,255,255)) end -- DRAW Q RANGE

            if Menu.draw.drawW and SpellTable[_W].ready then DrawCircleLFC(myHero.x, myHero.y, myHero.z, SpellTable[_W].range, ARGB(255,255,255,255)) end -- DRAW W RANGE

            if Menu.draw.drawE and SpellTable[_E].ready then DrawCircleLFC(myHero.x, myHero.y, myHero.z, SpellTable[_E].range, ARGB(255,255,255,255)) end -- DRAW E RANGE

            if Menu.draw.drawR and SpellTable[_R].ready then DrawCircleLFC(myHero.x, myHero.y, myHero.z, SpellTable[_R].range, ARGB(255,255,255,255)) end -- DRAW R RANGE

            if Menu.draw.drawTarget and GetTarget() ~= nil then DrawCircleLFC(GetTarget().x, GetTarget().y, GetTarget().z, 150, ARGB(255,255,255,255)) end -- DRAW TARGET

        else -- NORMAL CIRCLES

            if Menu.draw.drawAA then DrawCircle(myHero.x, myHero.y, myHero.z, SOWi:MyRange() + 50, ARGB(255,255,255,255)) end -- DRAW AA RANGE

            if Menu.draw.drawQ and SpellTable[_Q].ready then DrawCircle(myHero.x, myHero.y, myHero.z, SpellTable[_Q].range, ARGB(255,255,255,255)) end -- DRAW Q RANGE

            if Menu.draw.drawW and SpellTable[_W].ready then DrawCircle(myHero.x, myHero.y, myHero.z, SpellTable[_W].range, ARGB(255,255,255,255)) end -- DRAW W RANGE

            if Menu.draw.drawE and SpellTable[_E].ready then DrawCircle(myHero.x, myHero.y, myHero.z, SpellTable[_E].range, ARGB(255,255,255,255)) end -- DRAW E RANGE

            if Menu.draw.drawR and SpellTable[_R].ready then DrawCircle(myHero.x, myHero.y, myHero.z, SpellTable[_R].range, ARGB(255,255,255,255)) end -- DRAW R RANGE

            if Menu.draw.drawTarget and GetTarget() ~= nil then DrawCircle(GetTarget().x, GetTarget().y, GetTarget().z, 150, ARGB(255,255,255,255)) end -- DRAW TARGET

        end

    end

end

function DrawText()

end
-- DRAW FUNCTIONS --

-- SUPP PLOX GLOBAL FUNCTIONS --
function myManaPct() return (myHero.mana * 100) / myHero.maxMana end

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

-- Lag free circles (by barasia, vadash and viseversa)
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
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

function round(num) 
 if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircleLFC(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvl(x, y, z, radius, 1, color, 75) 
    end
end

function GetTarget()

    if TargetList and TargetList["main"] then return TargetList["main"] else return nil end

end

function GenerateSpellPacket(spell, x, y, fromX, fromY, target)

    return { spellID = spell, toX = x, toY = y, fromX = fromX or myHero.x, fromY = fromY or myHero.y } or { spellID = spell, targetNetworkId = target.networkID } or nil

end
-- SUPP PLOX GLOBAL FUNCTIONS --