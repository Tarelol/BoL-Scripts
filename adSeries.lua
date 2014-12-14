-- ADC Bundle v2 -- 

local charList = {
    ["Corki"] = true,
    ["KogMaw"] = true,
    ["Ezreal"] = true,
    -- ["Jinx"] =  true,  -- WIP
    -- ["Lucian"] = true  -- WIP
}

if not charList[myHero.charName] then return end

local ScriptName = "ADC Plox - " .. myHero.charName
local ScriptVersion = 1.33.7
local ScriptAuthor = "Astoriane"

-- GLOBAL --

require "VPrediction"

local currentChar
local SpellTable = {}
local VP = nil
local enemyMinions = minionManager(MINION_ENEMY, 1250, myHero)
local orbwalkers = {}
local currentOrbwalker

for i, _ in pairs(charList) do

    local createClass = i:gsub("%s+", "")
    class(createClass)
    if i == myHero.charName then
        currentChar = _G[createClass]
    end

end

function OnLoad()

    VP = VPrediction()
    currentChar:OnLoad()
    ChooseOrbwalker()

end

function OnTick()

    currentChar:OnTick()

end

function OnDraw()

    currentChar:OnDraw()

end

function OnGainBuff()

    currentChar:OnGainBuff()

end

function OnLoseBuff()

    currentChar:OnLoseBuff()

end

function OnProcessSpell(unit, spell)
    
    currentChar:OnProcessSpell(unit, spell) 
end

function OnCreateObj(object)
    
    currentChar:OnCreateObj(object)
end

function OnDeleteObj(object)
    
    currentChar:OnDeleteObj(object)
end

function KillSteal()

    currentChar:KillSteal()

end

function AutoPot()

end

function AutoIgnite(unit)

end

function ChooseOrbwalker()

    orbConfig = scriptConfig("PewPewBundle Orbwalker", "PewPewBundle Orbwalker")
    orbConfig:addParam("orbchoice", "Select Orbwalker (Requires Reload)", SCRIPT_PARAM_LIST, 1, { "SOW", "SxOrbWalk", "MMA", "SAC:R" })  

        if orbConfig.orbchoice == 1 then
            require "SOW"
            SOWi = SOW(VP)
            SOWi:LoadToMenu(orbConfig)
            orbConfig:addParam("drawrange", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
            orbConfig:addParam("drawtarget", "Draw Target Circle", SCRIPT_PARAM_ONOFF, true)
            orbConfig:addParam("focustarget", "Focus Selected Target", SCRIPT_PARAM_ONOFF, true)
        
        end

        if orbConfig.orbchoice == 2 then
            orbConfig:addParam("drawtarget", "Draw Target Circle", SCRIPT_PARAM_ONOFF, true)
            require "SxOrbWalk"
            SxOrb = SxOrbWalk()
            SxOrb:LoadToMenu(orbConfig)
        end

        if orbConfig.orbchoice == 3 then
            orbConfig:addParam("orbwalk", "OrbWalker", SCRIPT_PARAM_ONKEYDOWN, false, 32)
            orbConfig:addParam("hybrid", "HybridMode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
            orbConfig:addParam("laneclear", "LaneClear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
        end

end

-- GLOBAL -- 

-- Corki --

function Corki:OnLoad()

    self:__initVars()
    self:__initMenu()

end

function Corki:OnTick()

end

function Corki:OnDraw()

end

function Corki:OnGainBuff()

end

function Corki:OnLoseBuff()

end

function Corki:OnProcessSpell(unit, spell)

end

function Corki:OnCreateObj(object)

end

function Corki:OnDeleteObj(object)

end

function Corki:__initVars()

    SpellTable = {

        [_Q] = {
            name = "Phosphorus Bomb",
            range = 825,
            delay = 0.5,
            speed = 1050,
            width = 450,
            ready = false
        },

        [_W] = {
            name = "Valkyrie",
            range = 800,
            delay = nil,
            speed = nil,
            width = nil,
            ready = false
        },

        [_E] = {
            name = "Gatling Gun",
            range = 600,
            delay = nil,
            speed = nil,
            width = nil,
            ready = false

        },

        [_R] = {
            name = "Missile Barrage",
            range = 1225,
            delay = 0.25,
            speed = 2000,
            width = 75,
            ready = false
        }

    }

end

function Corki:__initMenu()

end

function Corki:Combo(unit)

end

function Corki:Harass(unit)

end

function Corki:Farm()

end

function Corki:Jungle()

end

function Corki:CastQ(unit)

end

-- Corki --