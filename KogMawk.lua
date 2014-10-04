--[[ 
		  _  __           _                          _    
		 | |/ /          ( )                        | |   
		 | ' / ___   __ _|/ _ __ ___   __ ___      _| | __
		 |  < / _ \ / _` | | '_ ` _ \ / _` \ \ /\ / / |/ /
		 | . \ (_) | (_| | | | | | | | (_| |\ V  V /|   < 
		 |_|\_\___/ \__, | |_| |_| |_|\__,_| \_/\_/ |_|\_\
			     __/ |        				by madk - astoriane                       
			    |___/                                 
					
					
	
		Changelog:
		
		  04/10/2014 - v1.11
		    [new] Initiated the github repo
		    [removed] Bol tracker as it is not needed anymore
		    
			26/09/2014 - v1.11
				[bugfix] Fixed the loading errors - Astoriane
				
			22/08/2014 - v1.10
				[bugfix] Auto Passive now goes for enemy with Less HP
				
			22/08/2014 - v1.9
				[bugfix] Q Cast (i hope)
				[bugfix] Disable SkinHack if you never changed the skins menu (Fix for CN servers i think)
				
			27/07/2014 - v1.8
				[bugfix] Error spam when using SAC:Revamped (not supported by the script)
				[new] SxOrbWalk support!
				
			27/07/2014 - v1.7
				[bugfix] Spells in Lane/Jungle clear mode
				
			26/07/2014 - v1.6
				[new] Added W on Mixed Mode
				[new] Lane/Jungle clear
				[bugfix] VPrediction
				
			21/07/2014 - v1.5
				[new] New menu and logic for Kill Steal
				[new] Move to killable target when passive is active
				[new] MMA and SAC:Reborn support (not tested yet, looking for some feedback)
				[bugfix] Fixed Q on VPrediction
				
			14/07/2014 - v1.4
				[new] Prodiction Support
				[bugfix] Default Draw circles posision
				[bugfix] Ultimate Range on Target Selector
				
			13/07/2014 - v1.3
				[new] Add default Draw Circles
				[bugfix] Fixed W activation
				[bugfix] Item Cast (finally?)
				
			13/07/2014 - v1.2
				[new] New logic for W activation (Now takes in count the bonus AA Range from W)
				[new] Reworked Drawings (Not using SourceLib for that anymore)
				[new] Auto Attack Range display 
				[bugfix] Ultimate Range
				[bugfix] Item Cast
				
			12/07/2014 - v1.1
				[new] Reworked Menu
				[new] Item Cast on Carry Mode
				[new] R Stack Limit now available to free users
				[new] Auto Pot/Flask
				[bugfix] Kill Steal don't cancel recall anymore
				[bugfix] Don't try to KS if enemy is out of range
				
			11/07/2014 - v1.0
				> First Release 
			
]]--

if myHero.charName ~= "Kogmaw" then return end

local version = 4.20
local AUTOUPDATE = false
local SCRIPT_NAME = "KogMawk"

local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"

if FileExist(SOURCELIB_PATH) then 
    require("SourceLib")
else 
    DOWNLOADING_SOURCELIB = true
    DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() print("Required libraries downloaded successfully, please reload") end)
end

if DOWNLOADING_SOURCELIB then print("Downloading required libraries, please wait...") return end

if AUTOUPDATE then
    SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/Astoriane/BoL-Scripts/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/madk/BotOfLegends/master/version/"..SCRIPT_NAME..".version"):CheckUpdate()
end

local RequireI = Require("SourceLib")

RequireI:Add("vPrediction", "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua")
RequireI:Add("SOW", "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua")
if VIP_USER then
	RequireI:Add("Prodiction", "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/ec830facccefb3b52212dba5696c08697c3c2854/Test/Prodiction/Prodiction.lua")
end

RequireI:Check()

if RequireI.downloadNeeded == true then return end

local SpellData = { 
	[_Q] = {
		name = "Caustic Spittle",
		ready = false,
		range = 975,
		width = 70,
		speed = 1200,
		delay = 0.5
	},
	
	[_W] = {
		name = "Bio-Arcane Barrage",
		ready = false,
		range = {130, 150, 170, 190, 210}
	},
	
	[_E] = {
		name = "Void Ooze",
		ready = false,
		range = 1200,
		width = 120,
		speed = 1200,
		delay = 0.5
	},
	
	[_R] = {
		name = "Living Artillery",
		ready = false,
		range = {1100, 1375, 1650},
		width = 225,
		speed = math.huge,
		delay = 1.1,
		stacks = 0,
		lastCast = 0
	}
}

local ItemData = {
	[3144] = {name = "Bilgewater Cutlass", 			range = 500, 			slot = nil,	ready = false},
	[3153] = {name = "Blade of The Ruined King",	range = 450, 			slot = nil,	ready = false},
	[3146] = {name = "Hextech Gunblade",			range = 700,			slot = nil, ready = false},
	[3128] = {name = "Deathfire Grasp",				range = 750,			slot = nil, ready = false},
	[3142] = {name = "Youmuu's Ghostblade",			range = myHero.range, 	slot = nil,	ready = false,	noTarget = true},
	[3131] = {name = "Sword of the Divine",			range = myHero.range,	slot = nil,	ready = false,	noTarget = true}
}
local TargetList = {[_Q] = nil, [_W] = nil, [_E] = nil, [_R] = nil, ["main"] = nil}
local PassiveTracker = {status = false, startClock = 0, startPoint = nil, ms = nil, target = nil}
local LastPotCast = {red = 0, blue = 0, flask = 0}
local Recalling

local SkinList = {"Caterpillar Kog'Maw", "Sonoran Kog'Maw", "Monarch Kog'Maw", "Reindeer Kog'Maw", "Lion Dance Kog'Maw", "Deep Sea Kog'Maw", "Jurassic Kog'Maw", "Classic Skin"}
local lastSkin = 0

function OnLoad()
	__initLibs()
	__initMenu()
	PrintChat("<font color=\"#FF6600\">[Kog'Mawk]</font> <font color=\"#FFFFFF\">Script loaded. Running version v"..version.."</font>")
	PrintChat("<font color=\"#FF6600\">[Kog'Mawk]</font> <font color=\"#FFFFFF\">This script is further updated by Astoriane on BoL forums.</font>")
	DelayAction(OrbWalkerCheck, 2.0)
end
 
function OnUnload()
	UpdateWeb(false, ScriptName, id, HWID)
end

function OnBugsplat()
	UpdateWeb(false, ScriptName, id, HWID)
end

function OnTick()
	UpdateValues()
	AutoPot()
	KillSteal()
	
	if Menu.sow.Mode0 or _G.MMA_Orbwalker or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.AutoCarry) or (_G.SxOrbMenu and _G.SxOrbMenu.AutoCarry) then -- Carry Me!
		Combo()
	elseif Menu.sow.Mode1 or _G.MMA_HybridMode or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.MixedMode) or (_G.SxOrbMenu and _G.SxOrbMenu.MixedMode) then -- Harass (Mixed Mode)
		Harass()
	elseif Menu.sow.Mode2 or _G.MMA_LaneClear or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.LaneClear) or (_G.SxOrbMenu and _G.SxOrbMenu.LaneClear) then -- Lane Clear
		Farm()
	end
	
	if PassiveTracker.status and Menu.useP then -- Use passive
		for _,enemy in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) and not enemy.dead and GetDistance(enemy) < myHero.ms * (PassiveTracker.startClock +  4.2 - os.clock()) + 200 then
				PassiveTracker.target = PassiveTracker.target and (PassiveTracker.target.health > enemy.health and enemy or PassiveTracker.target) or enemy
			end
		end
		
		if PassiveTracker.target and ValidTarget(PassiveTracker.target) then 
			myHero:MoveTo(PassiveTracker.target.x, PassiveTracker.target.z)
		end
	end
end

function OnDraw()
	if not PassiveTracker.status or not myHero.dead then
		-- AA
		if Menu.drawings.aa.active then
			DrawRangek(myHero.range + 25, Menu.drawings.aa.width, Menu.drawings.aa.color)
		end
		-- Q
		if Menu.drawings.Q.active and myHero:GetSpellData(_Q).level > 0 then
			DrawRangek(SpellData[_Q].range, Menu.drawings.Q.width, Menu.drawings.Q.color)
		end
		
		-- W
		if Menu.drawings.W.active and myHero:GetSpellData(_W).level > 0 and myHero.range < 501 then
			DrawRangek(SpellData[_W].range[myHero:GetSpellData(_W).level] + myHero.range, Menu.drawings.W.range, Menu.drawings.W.color)
		end
		
		-- E
		if Menu.drawings.E.active and myHero:GetSpellData(_E).level > 0 then
			DrawRangek(SpellData[_E].range, Menu.drawings.E.width, Menu.drawings.E.color)
		end
		
		-- R
		if Menu.drawings.R.active and myHero:GetSpellData(_R).level > 0 then
			DrawRangek(SpellData[_R].range[myHero:GetSpellData(_R).level], Menu.drawings.R.width, Menu.drawings.R.color)
		end
	end
	
	-- Passive
	if Menu.drawings.P.active and PassiveTracker.status then
		if Menu.drawings.P.drawTarget then
			for i = 1, 3 do 
				DrawRangek(i * 40, Menu.drawings.P.width, Menu.drawings.P.color, PassiveTracker.target) 
			end
		end
		
		if Menu.drawings.P.mode == 1 or Menu.drawings.P.mode == 3 then
			PassiveRange = GetPassiveRange()
			DrawRangek(PassiveRange, Menu.drawings.P.width, Menu.drawings.P.color, PassiveTracker.startPoint)
		end
		
		if Menu.drawings.P.mode == 2 or Menu.drawings.P.mode == 3 then
			DrawRangek(myHero.ms * (PassiveTracker.startClock + 4.2 - os.clock()) + 200, Menu.drawings.P.width, Menu.drawings.P.color)
		end
	end
end

function OnGainBuff(unit, buff)
	if unit.isMe and buff.name == "kogmawlivingartillerycost" then
		SpellData[_R].stacks = 1
	end
end

function OnUpdateBuff(unit, buff)
	if unit.isMe and buff.name == "kogmawlivingartillerycost" then
		SpellData[_R].stacks = buff.stack
	end
end

function OnLoseBuff(unit, buff)
	if unit.isMe and buff.name == "kogmawlivingartillerycost" then
		SpellData[_R].stacks = 0
	end
end

function OnProcessSpell(unit, spell)
	if unit.isMe and spell.name == "KogMawLivingArtillery" and not VIP_USER then
		SpellData[_R].lastCast = GetTickCount()
		SpellData[_R].stacks = SpellData[_R].stacks == 9 and 9 or SpellData[_R].stacks + 1
	end
end

function OnCreateObj(obj)
	if obj ~= nil and obj.name:find("TeleportHome.troy") and GetDistance(obj, myHero) <= 70 and not Recalling then
		Recalling = true
	elseif obj.name:find("KogMawIcathianSurprise_foam.troy") and GetDistance(obj) < 1 then
		-- Passive
		PassiveTracker.status = true
		PassiveTracker.startClock = os.clock()
		PassiveTracker.endClock = os.clock() + 4
		PassiveTracker.startPoint = {x = myHero.x, y = myHero.y, z = myHero.z}
		PassiveTracker.ms = myHero.ms
	end
end
function OnDeleteObj(obj)
	if obj ~= nil and obj.name:find("TeleportHome.troy") and Recalling then
		Recalling = false
	end
end

function UpdateValues()
	-- Spells CD
	for i in pairs(SpellData) do
		SpellData[i].ready = myHero:CanUseSpell(i) == READY
	end
	
	-- Items
	for ItemID in pairs(ItemData) do
		if GetInventoryHaveItem(ItemID) then
			ItemData[ItemID].slot = GetInventorySlotItem(ItemID)
			ItemData[ItemID].ready = myHero:CanUseSpell(ItemData[ItemID].slot) == READY
		end
	end
	
	-- Targets
	if _G.MMA_Loaded and _G.MMA_Target and _G.MMA_Target.type == myHero.type then
		TargetList["main"] = _G.MMA_Target
	elseif _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then
		TargetList["main"] = _G.AutoCarry.Attack_Crosshair.target
	else
		TargetList["main"] = STS:GetTarget(myHero.range)
	end
	
	TargetList[_Q] = STS:GetTarget(SpellData[_Q].range)
	TargetList[_E] = STS:GetTarget(SpellData[_E].range)
	TargetList[_R] = STS:GetTarget(myHero:GetSpellData(_R).level > 0 and SpellData[_R].range[myHero:GetSpellData(_R).level] or myHero.range)
	TargetList[_W] = STS:GetTarget(myHero:GetSpellData(_W).level > 0 and SpellData[_W].range[myHero:GetSpellData(_W).level] + myHero.range or myHero.range)
	
	-- Passive
	if PassiveTracker.status and myHero.dead then PassiveTracker.status = false end
	
	-- _R Stacks for Non-VIP
	if SpellData[_R].lastCast + 6000 <= GetTickCount() and not VIP_USER then
		SpellData[_R].stacks = 0
	end
	
	-- Skin Hack
	if Menu.skin then
		SkinHack()
	end
	
	-- BoL-Tracker.com
	if GetGame().isOver then
		UpdateWeb(false, ScriptName, id, HWID)
		startUp = false;
	end
end

function Combo()
	-- Cast Items
	for ItemID,IDValues in pairs(ItemData) do
		if TargetList["main"] and IDValues.slot and IDValues.ready and GetDistance(TargetList["main"]) <= IDValues.range then
			CastItem(TargetList["main"], ItemID)
		end
	end
	
	-- Focus Target in range
	if Menu.carry.tirfocus then
		if TargetList["main"] then 
			for i in pairs(TargetList) do 
				TargetList[i] = TargetList["main"] 
			end 
		end
	end
	
	-- Cast Spells
	if CanCastE(1) then	CastE(TargetList[_E], VIP_USER and Menu.prediction == 2 and Menu.carry.E.prochance or Menu.carry.E.chance) end
	if CanCastQ(1) then	CastQ(TargetList[_Q], VIP_USER and Menu.prediction == 2 and Menu.carry.Q.prochance or Menu.carry.Q.chance) end
	if CanCastW(1) then CastSpell(_W) end
	if CanCastR(1) then CastR(TargetList[_R], VIP_USER and Menu.prediction == 2 and Menu.carry.R.prochance or Menu.carry.R.chance) end
end

function Harass()
	if CanCastE(2) then CastE(TargetList[_E], VIP_USER and Menu.prediction == 2 and Menu.harass.E.prochance or Menu.harass.E.chance) end
	if CanCastQ(2) then CastQ(TargetList[_Q], VIP_USER and Menu.prediction == 2 and Menu.harass.Q.prochance or Menu.harass.Q.chance) end
	if CanCastW(2) then CastSpell(_W) end
	if CanCastR(2) then	CastR(TargetList[_R], VIP_USER and Menu.prediction == 2 and Menu.harass.R.prochance or Menu.harass.R.chance) end
end

function Farm()
	-- Lane clear
	EnemyMinions:update()	
	for _,minion in pairs(EnemyMinions.objects) do
		if CanCastW(3, minion) then CastSpell(_W) end
		if CanCastE(3, minion) then CastE(minion, 2, 1, true) end
		if CanCastR(3, minion) then CastR(minion, 2, 1, true) end
	end
	
	-- Jungle Clear
	JungleMinions:update()
	for _,minion in pairs(JungleMinions.objects) do
		if CanCastW(3, minion) then CastSpell(_W) end
		if CanCastE(3, minion) then CastE(minion, 2, 1, true) end
		if CanCastR(3, minion) then CastR(minion, 2, 1, true) end
	end
end
 
function CastQ(target, chance, forcevp)
	if not target or not ValidTarget(target) then return end
	
	chance = chance or 2
	
	local CastPos, Info, HitChance
	
	if VIP_USER and Menu.prediction == 2 and not forcevp then -- Prodiction
		CastPos, Info = Prodiction.GetPrediction(target, SpellData[_Q].range, SpellData[_Q].speed, SpellData[_Q].delay, SpellData[_Q].width, myHero)
		if Info.mCollision() then return end
		HitChance = tonumber(Info.hitchance)
	else -- VPrediction
		CastPos, HitChance = VP:GetLineCastPosition(target, SpellData[_Q].delay, SpellData[_Q].width, SpellData[_Q].range, SpellData[_Q].speed, myHero, true)
	end
	
	if HitChance and HitChance >= chance and SpellData[_Q].ready then
		CastSpell(_Q, CastPos.x, CastPos.z)
	end
end

function CastE(target, chance, forcevp)
	if not target or not ValidTarget(target) then return end
	
	chance = chance or 2
	
	local CastPos, Info, HitChance
	
	if VIP_USER and Menu.prediction == 2 and not forcevp then -- Prodiction
		CastPos, Info = Prodiction.GetLineAOEPrediction(target, SpellData[_E].range, SpellData[_E].speed, SpellData[_E].delay, SpellData[_E].width, myHero)
		HitChance = tonumber(Info.hitchance)
	else -- VPrediction
		CastPos, HitChance, NTargets = VP:GetLineAOECastPosition(target, SpellData[_E].delay, SpellData[_E].width, SpellData[_E].range, SpellData[_E].speed, myHero)
	end
	
	if HitChance and HitChance >= chance and SpellData[_E].ready then
		CastSpell(_E, CastPos.x, CastPos.z)
	end
end

function CastR(target, chance, forcevp)
	if not target or not ValidTarget(target) then return end
	
	chance = chance or 2
	
	local CastPos, Info, HitChance
	
	if VIP_USER and Menu.prediction == 2 and not forcevp then -- Prodiction
		CastPos, Info = Prodiction.GetCircularAOEPrediction(target, SpellData[_R].range[myHero:GetSpellData(_R).level], SpellData[_R].speed, SpellData[_R].delay, SpellData[_R].width, myHero)
		HitChance = tonumber(Info.hitchance)
	else -- VPrediction
		CastPos, HitChance, NTargets = VP:GetCircularAOECastPosition(target, SpellData[_R].delay, SpellData[_R].width, SpellData[_R].range[myHero:GetSpellData(_R).level], SpellData[_R].speed, myHero)
	end
	
	if HitChance and HitChance >= chance and SpellData[_R].ready then
		CastSpell(_R, CastPos.x, CastPos.z)
	end
end

function CanCastQ(mode)
	mode = mode or 1
	
	if mode == 1 then -- Carry Me!
		-- Spell not Available
		if (not SpellData[_Q].ready)
		
		-- No target
		or (not TargetList[_Q])
		
		-- Disabled
		or (not Menu.carry.Q.use)
		
		-- Not enought mana
		or (myManaPct() < Menu.carry.Q.mn)
		
		-- Disabled Target
		or (not Menu.carry.Q[TargetList[_Q].hash]) 
		
		then return false end

	elseif mode == 2 then -- Mixed Mode
		-- Spell not Available
		if (not SpellData[_Q].ready)
		
		-- No target
		or (not TargetList[_Q])
		
		-- Disabled
		or (not Menu.harass.Q.use)
		
		-- Not enought mana
		or (myManaPct() < Menu.harass.Q.mn)
		
		-- Disabled Target
		or (not Menu.harass.Q[TargetList[_Q].hash]) 
		
		then return false end
	end
	
	return true
end

function CanCastW(mode, target)
	mode = mode or 1
	target = target or TargetList[_W]
	if mode == 1 then -- Carry Me!
		-- Spell not Available
		if (not SpellData[_W].ready)
		
		-- No target
		or (not TargetList[_W])
		
		-- Disabled
		or (not Menu.carry.W.use)
		
		-- Out of Range
		or (GetDistance(TargetList[_W]) > myHero.range + SpellData[_W].range[myHero:GetSpellData(_W).level])
		
		-- Disabled Target
		or (not Menu.carry.W[TargetList[_W].hash]) 
		
		then return false end
	
	elseif mode == 2 then -- Mixed Mode
		if myHero:GetSpellData(_W).level < 1 then return false end
		MMTarget = SOWi:KillableMinion() or STS:GetTarget(myHero.range + SpellData[_W].range[myHero:GetSpellData(_W).level]) -- Target of Mixed Mode
		
		-- Spell not Available
		if (not SpellData[_W].ready)
		
		-- No target
		or (not MMTarget)
		
		-- Out of Range
		or (GetDistance(MMTarget) > myHero.range + SpellData[_W].range[myHero:GetSpellData(_W).level])
		
		-- Use on Heroes
		or (not Menu.harass.W.useH and MMTarget.type == myHero.type)
		
		-- Use on Minions
		or (not Menu.harass.W.useM and MMTarget.type ~= myHero.type)
		
		-- Disabled Target
		or (MMTarget.type == myHero.type and not Menu.harass.W[TargetList[_W].hash])
		
		then return false end
	
	elseif mode == 3 then -- Farm
		-- Spell not Available
		if (not SpellData[_W].ready)
		
		-- No target
		or (not target)
		
		-- Disabled
		or (not Menu.farm.W.use)
		
		-- Out of Range
		or (GetDistance(target) > myHero.range + SpellData[_W].range[myHero:GetSpellData(_W).level])
		
		-- Disabled on Jungle creeps
		or (target.team == TEAM_NEUTRAL and Menu.farm.W.mode == 1)
		
		-- Disabled on Minions
		or (target.team == TEAM_ENEMY and Menu.farm.W.mode == 2)
		
		then return false end
	end
	
	return true
end

function CanCastE(mode, target)
	mode = mode or 1
	target = target or TargetList[_E]
	if mode == 1 then -- Carry Me!
		-- Spell not Available
		if (not SpellData[_E].ready)
		
		-- No target
		or (not TargetList[_E])
		
		-- Disabled
		or (not Menu.carry.E.use)
		
		-- Not enought mana
		or (myManaPct() < Menu.carry.E.mn)
		
		-- Disabled Target
		or (not Menu.carry.E[TargetList[_E].hash])
		
		then return false end
		
	elseif mode == 2 then -- Mixed Mode
		-- Spell not Available
		if (not SpellData[_E].ready)
		
		-- No target
		or (not TargetList[_E])
		
		-- Disabled
		or (not Menu.harass.E.use)
		
		-- Not enought mana
		or (myManaPct() < Menu.harass.E.mn)
		
		-- Disabled Target
		or (not Menu.harass.E[TargetList[_E].hash])
		
		then return false end
		
	elseif mode == 3 then -- Farm
		-- Spell not Available
		if (not SpellData[_E].ready)
		
		-- No target
		or (not target)
		
		-- Disabled
		or (not Menu.farm.E.use)
		
		-- Not enought mana
		or (myManaPct() < Menu.farm.E.mn)
		
		-- Disabled on Jungle creeps
		or (target.team == TEAM_NEUTRAL and Menu.farm.E.mode == 1)
		
		-- Disabled on Minions
		or (target.team == TEAM_ENEMY and Menu.farm.E.mode == 2)
		
		then return false end
	end
	
	return true
end

function CanCastR(mode, target)
	mode = mode or 1
	target = target or TargetList[_R]
	if mode == 1 then -- Carry Me!	
		-- Spell not Available
		if (not SpellData[_R].ready)
		
		-- No target
		or (not TargetList[_R])
		
		-- Disabled
		or (not Menu.carry.R.use)
		
		-- Not enought mana
		or (myManaPct() < Menu.carry.R.mn)
		
		-- Too much stacks
		or (Menu.carry.R.stacks <= SpellData[_R].stacks)
		
		-- Disabled target
		or (not Menu.carry.R[TargetList[_R].hash])
		
		then return false end
		
	elseif mode == 2 then 
		-- Spell not Available
		if (not SpellData[_R].ready)
		
		-- No target
		or (not TargetList[_R])
		
		-- Disabled
		or (not Menu.harass.R.use)
		
		-- Not enought mana
		or (myManaPct() < Menu.harass.R.mn)
		
		-- Too much stacks
		or (Menu.harass.R.stacks <= SpellData[_R].stacks)
		
		-- Disabled target
		or (not Menu.harass.R[TargetList[_R].hash])
		
		then return false end
		
	elseif mode == 3 then -- Farm
		-- Spell not Available
		if (not SpellData[_R].ready)
		
		-- No target
		or (not target)
		
		-- Disabled
		or (not Menu.farm.R.use)
		
		-- Not enought Mana
		or (myManaPct() < Menu.farm.R.mn)
		
		-- Disabled on Jungle creeps
		or (target.team == TEAM_NEUTRAL and Menu.farm.E.mode == 1)
		
		-- Disabled on Minions
		or (target.team == TEAM_ENEMY and Menu.farm.E.mode == 2)
		
		-- Too much stacks
		or (Menu.farm.R.stacks <= SpellData[_R].stacks)
		
		then return false end
	end
	
	return true
end

function CastItem(target, ItemID)
	if not target or not ValidTarget(target) or not ItemData[ItemID].ready or not ItemData[ItemID].slot then return end
	if ItemID == 3153 then -- BOTRK
		if Menu.carry.items[target.hash] == 1 then -- Normal Cast
			CastSpell(ItemData[ItemID].slot, target)
		elseif Menu.carry.items[target.hash] == 2 then -- Max Heal
			if myHero.health <= myHero.maxHealth * 0.65 then
				CastSpell(ItemData[ItemID].slot, target)
			end
		elseif Menu.carry.items[target.hash] == 3 then -- Chase
			if IsRunningAway(target) then
				CastSpell(ItemData[ItemID].slot, target)
			end
		else return end
	else
		if GetDistance(target) <= ItemData[ItemID].range and Menu.carry.items[tostring(ItemID)] then
			if ItemData[ItemID].noTarget then -- Ghostblade / SOTD
				CastSpell(ItemData[ItemID].slot)
			else
				CastSpell(ItemData[ItemID].slot, target)
			end
		end
	end
end

function KillSteal()
	-- Recalling
	if (Recalling) 
	-- KS Active
	or (not Menu.KS.active)
	
	then return end
	
	for _,enemy in pairs(GetEnemyHeroes()) do
	
		if GetDistance(enemy) <= myHero.range and not Menu.KS.irspells then goto continue end
		
		if GetNearbyAllies(enemy, 800) == 0 and Menu.KS.allycheck then goto continue end
		
		if Menu.KS.spells.R and SpellData[_R].ready and enemy.health <= getDmg("R", enemy, myHero) and GetDistance(enemy) < SpellData[_R].range[myHero:GetSpellData(_R).level] and SpellData[_R].stacks <= Menu.KS.RStacks then
			CastR(enemy, 2)
		elseif Menu.KS.spells.E and SpellData[_E].ready and enemy.health <= getDmg("E", enemy, myHero) and GetDistance(enemy) < SpellData[_E].range then
			CastE(enemy, 2)
		elseif Menu.KS.spells.Q and SpellData[_Q].ready and enemy.health <= getDmg("Q", enemy, myHero) and GetDistance(enemy) < SpellData[_Q].range then
			CastQ(enemy, 2)
		end
		
		::continue::
	end
	
end

function DrawRangek(range, width, color, pos)
	pos = pos or myHero
	if Menu.drawings.circles == 1 then
		DrawCircle(pos.x, pos.y, pos.z, range, ARGB(color[1], color[2], color[3], color[4]))
	else
		DrawCircle3D(pos.x, pos.y, pos.z, range, width, ARGB(color[1], color[2], color[3], color[4]))
	end
end

function GetPassiveRange(ms)
	ms = ms or myHero.ms
	range = 0
	for i = 1,4 do
		range = range + ((ms * (100 + (10 * i)) / 100) * i)
	end
	
	return range
end

function AutoPot()
	-- Health Pot
	if Menu.extras.autopot.hp ~= 0 and Menu.extras.autopot.hp > (myHero.health * 100) / myHero.maxHealth and GetTickCount() > LastPotCast.red + 15000 then
		PotSlot = GetInventorySlotItem(2003)
		if PotSlot then
			CastSpell(PotSlot)
			LastPotCast.red = GetTickCount()
		else
			CastFlask = true
		end
	end
	
	-- Mana Pot
	if Menu.extras.autopot.mn ~= 0 and Menu.extras.autopot.mn > myManaPct() and GetTickCount() > LastPotCast.blue + 15000 then
		PotSlot = GetInventorySlotItem(2004)
		if PotSlot then
			CastSpell(PotSlot)
			LastPotCast.blue = GetTickCount()
		else
			CastFlask = true
		end
	end
	
	-- Flask
	if CastFlask and GetTickCount() > LastPotCast.flask + 12000 then
		FlaskSlot = GetInventorySlotItem(2041)
		if FlaskSlot then
			CastSpell(FlaskSlot)
			LastPotCast.flask = GetTickCount()
		end
	end
end

function IsRunningAway(hero)
	local wp = wayPointManager:GetWayPoints(hero)
	return GetDistance(wp, myHero) > GetDistance(hero, myHero) and true or false
end

function myManaPct() return (myHero.mana * 100) / myHero.maxMana end

function GetNearbyAllies(point, range) 
	local allyCount = 0
	for _,ally in pairs(GetAllyHeroes()) do
		allyCount = (GetDistance(ally, point) < range) and allyCount + 1 or allyCount
	end
	return allyCount
end

function OrbWalkerCheck()
	if _G.MMA_Loaded then
		PrintChat("<font color=\"#FF6600\">[Kog'Mawk]</font> <font color=\"#FFFFFF\">Marksman's Mighty Assistant found! Simple Orbwalker was been disabled.</font>")
		Menu.sow.Enabled = false
	elseif _G.Reborn_Loaded then
		PrintChat("<font color=\"#FF6600\">[Kog'Mawk]</font> <font color=\"#FFFFFF\">SAC:Reborn found! Simple Orbwalker was been disabled.</font>")
		Menu.sow.Enabled = false
	elseif _G.SxOrbMenu then
		PrintChat("<font color=\"#FF6600\">[Kog'Mawk]</font> <font color=\"#FFFFFF\">SxOrbWalk found! Simple Orbwalker was been disabled.</font>")
		Menu.sow.Enabled = false
	else
		PrintChat("<font color=\"#FF6600\">[Kog'Mawk]</font> <font color=\"#FFFFFF\">No orbwalkers found, using Simple Orbwalker.</font>")		
	end
end

function __initLibs()
	VP = VPrediction(true)
	STS = SimpleTS(STS_LESS_CAST_PHYSICAL)
	SOWi = SOW(VP, STS)
	EnemyMinions = minionManager(MINION_ENEMY, SpellData[_E].range, myHero, MINION_SORT_MAXHEALTH_DEC)
	JungleMinions = minionManager(MINION_JUNGLE, SpellData[_E].range, myHero, MINION_SORT_MAXHEALTH_DEC)
	
	UpdateWeb(true, ScriptName, id, HWID) -- BoL-Tracker
end

function __initMenu()
	Menu = scriptConfig("Kog'Mawk", "KogMawk")
	
	-- Carry Me!
	Menu:addSubMenu("Carry Me!", "carry")
		Menu.carry:addSubMenu("Q: Caustic Spittle", "Q")
			Menu.carry.Q:addParam("use", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.carry.Q:addParam("mn", "Required Mana (%)", SCRIPT_PARAM_SLICE, 0, 0, 100)
			Menu.carry.Q:addParam("chance", "[VP] Hit Chance", SCRIPT_PARAM_LIST, 2, {"Low Hit Chance", "High Hit Chance", "Target too slowed or/and too close", "Target inmmobile", "Target Dashing or blinking"})
			if VIP_USER then
				Menu.carry.Q:addParam("prochance", "[Prodiction] Hit Chance", SCRIPT_PARAM_LIST, 2, {"Low", "Normal", "High", "Very High"})
			end
			Menu.carry.Q:addParam("", "-- [ Valid Targets ] --", SCRIPT_PARAM_INFO, "")
			
		Menu.carry:addSubMenu("W: Bio-Arcane Barrage", "W")
			Menu.carry.W:addParam("use", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.carry.W:addParam("", "-- [ Valid Targets ] --", SCRIPT_PARAM_INFO, "")
			
		Menu.carry:addSubMenu("E: Void Ooze", "E")
			Menu.carry.E:addParam("use", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.carry.E:addParam("mn", "Required Mana (%)", SCRIPT_PARAM_SLICE, 0, 0, 100)
			Menu.carry.E:addParam("chance", "[VP] Hit Chance", SCRIPT_PARAM_LIST, 2, {"Low Hit Chance", "High Hit Chance", "Target too slowed or/and too close", "Target inmmobile", "Target Dashing or blinking"})
			if VIP_USER then
				Menu.carry.E:addParam("prochance", "[Prodiction] Hit Chance", SCRIPT_PARAM_LIST, 2, {"Low", "Normal", "High", "Very High"})
			end
			Menu.carry.E:addParam("", "-- [ Valid Targets ] --", SCRIPT_PARAM_INFO, "")
			
		Menu.carry:addSubMenu("R: Living Artillery", "R")
			Menu.carry.R:addParam("use", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.carry.R:addParam("mn", "Required Mana (%)", SCRIPT_PARAM_SLICE, 0, 0, 100)
			Menu.carry.R:addParam("chance", "[VP] Hit Chance", SCRIPT_PARAM_LIST, 2, {"Low Hit Chance", "High Hit Chance", "Target too slowed or/and too close", "Target inmmobile", "Target Dashing or blinking"})
			if VIP_USER then
				Menu.carry.R:addParam("prochance", "[Prodiction] Hit Chance", SCRIPT_PARAM_LIST, 2, {"Low", "Normal", "High", "Very High"})
			end
			Menu.carry.R:addParam("stacks", "Stack Limiter", SCRIPT_PARAM_SLICE, 5, 1, 9)
			Menu.carry.R:addParam("", "-- [ Valid Targets ] --", SCRIPT_PARAM_INFO, "")
			
		Menu.carry:addSubMenu("Items", "items")
			for ItemID,Values in pairs(ItemData) do
				if ItemID ~= 3153 then -- BOTRK 
					Menu.carry.items:addParam(tostring(ItemID), tostring(Values.name), SCRIPT_PARAM_ONOFF, true)
				end
			end
			Menu.carry.items:addParam("", "-- [ Blade Of the Ruined King ] --", SCRIPT_PARAM_INFO, "")
		
		Menu.carry:addParam("tirfocus", "Focus target in range", SCRIPT_PARAM_ONOFF, true)
		
	-- Mixed Mode
	Menu:addSubMenu("Mixed Mode", "harass")
		Menu.harass:addSubMenu("Q: Caustic Spittle", "Q")
			Menu.harass.Q:addParam("use", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.harass.Q:addParam("mn", "Required Mana (%)", SCRIPT_PARAM_SLICE, 0, 0, 100)
			Menu.harass.Q:addParam("chance", "[VP] Hit Chance", SCRIPT_PARAM_LIST, 2, {"Low Hit Chance", "High Hit Chance", "Target too slowed or/and too close", "Target inmmobile", "Target Dashing or blinking"})
			Menu.harass.Q:addParam("", "-- [ Valid Targets ] --", SCRIPT_PARAM_INFO, "")
			if VIP_USER then
				Menu.harass.Q:addParam("prochance", "[Prodiction] Hit Chance", SCRIPT_PARAM_LIST, 2, {"Low", "Normal", "High", "Very High"})
			end
			
		Menu.harass:addSubMenu("W: Bio-Arcane Barrage", "W")
			Menu.harass.W:addParam("useH", "Active on Heroes", SCRIPT_PARAM_ONOFF, true)
			Menu.harass.W:addParam("useM", "Use on Minions", SCRIPT_PARAM_ONOFF, false)
			Menu.harass.W:addParam("", "-- [ Valid Targets ] --", SCRIPT_PARAM_INFO, "")
			
		Menu.harass:addSubMenu("E: Void Ooze", "E")
			Menu.harass.E:addParam("use", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.harass.E:addParam("mn", "Required Mana (%)", SCRIPT_PARAM_SLICE, 0, 0, 100)
			Menu.harass.E:addParam("chance", "[VP] Hit Chance", SCRIPT_PARAM_LIST, 2, {"Low Hit Chance", "High Hit Chance", "Target too slowed or/and too close", "Target inmmobile", "Target Dashing or blinking"})
			if VIP_USER then
				Menu.harass.E:addParam("prochance", "[Prodiction] Hit Chance", SCRIPT_PARAM_LIST, 2, {"Low", "Normal", "High", "Very High"})
			end
			Menu.harass.E:addParam("", "-- [ Valid Targets ] --", SCRIPT_PARAM_INFO, "")
			
		Menu.harass:addSubMenu("R: Living Artillery", "R")
			Menu.harass.R:addParam("use", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.harass.R:addParam("mn", "Required Mana (%)", SCRIPT_PARAM_SLICE, 0, 0, 100)
			Menu.harass.R:addParam("chance", "[VP] Hit Chance", SCRIPT_PARAM_LIST, 2, {"Low Hit Chance", "High Hit Chance", "Target too slowed or/and too close", "Target inmmobile", "Target Dashing or blinking"})
			if VIP_USER then
				Menu.harass.R:addParam("prochance", "[Prodiction] Hit Chance", SCRIPT_PARAM_LIST, 2, {"Low", "Normal", "High", "Very High"})
			end
			Menu.harass.R:addParam("stacks", "Stack Limiter", SCRIPT_PARAM_SLICE, 1, 1, 9)
			Menu.harass.R:addParam("", "-- [ Valid Targets ] --", SCRIPT_PARAM_INFO, "")
	
	Menu:addSubMenu("Lane/Jungle Clear", "farm")
		Menu.farm:addSubMenu("W: Bio-Arcane Barrage", "W")
			Menu.farm.W:addParam("use", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.farm.W:addParam("mode", "Modes", SCRIPT_PARAM_LIST, 2, {"Lane clear", "Jungle clear", "Both"})
		
		Menu.farm:addSubMenu("E: Void Ooze", "E")
			Menu.farm.E:addParam("use", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.farm.E:addParam("mn", "Required Mana (%)", SCRIPT_PARAM_SLICE, 0, 0, 100)
			-- Menu.farm.E:addParam("aoe", "Required Targets", SCRIPT_PARAM_SLICE, 6, 1, 12)
			Menu.farm.E:addParam("mode", "Mode", SCRIPT_PARAM_LIST, 3, {"Lane clear", "Jungle clear", "Both"})
		
		Menu.farm:addSubMenu("R: Living Artillery", "R")
			Menu.farm.R:addParam("use", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.farm.R:addParam("mn", "Required Mana (%)", SCRIPT_PARAM_SLICE, 75, 0, 100)
			Menu.farm.R:addParam("stacks", "Stack Limiter", SCRIPT_PARAM_SLICE, 1, 1, 9)
			-- Menu.farm.R:addParam("aoe", "Required Targets", SCRIPT_PARAM_SLICE, 3, 1, 12)
			Menu.farm.R:addParam("mode", "Mode", SCRIPT_PARAM_LIST, 2, {"Lane clear", "Jungle clear", "Both"})
			
	
	-- Drawings
	Menu:addSubMenu("Drawings", "drawings")
		Menu.drawings:addParam("circles", "Circles", SCRIPT_PARAM_LIST, 2, {"Default Circles", "Free Lag Circles"})
		Menu.drawings:addSubMenu("AA Range", "aa")
			Menu.drawings.aa:addParam("active", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.aa:addParam("color", "Color", SCRIPT_PARAM_COLOR, {100, 255, 255, 255})
			Menu.drawings.aa:addParam("width", "Width", SCRIPT_PARAM_SLICE, 1, 1, 5)
		Menu.drawings:addSubMenu("Q: Chaustic Spittle", "Q")
			Menu.drawings.Q:addParam("active", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.Q:addParam("color", "Color", SCRIPT_PARAM_COLOR, { 100, 255, 255, 255 })
			Menu.drawings.Q:addParam("width", "Width", SCRIPT_PARAM_SLICE, 1, 1, 5)
			
		Menu.drawings:addSubMenu("W: Bio-Arcane Barrage", "W")
			Menu.drawings.W:addParam("active", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.W:addParam("color", "Color", SCRIPT_PARAM_COLOR, { 100, 255, 255, 255 })
			Menu.drawings.W:addParam("width", "Width", SCRIPT_PARAM_SLICE, 1, 1, 5)
			
		Menu.drawings:addSubMenu("E: Void Ooze", "E")
			Menu.drawings.E:addParam("active", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.E:addParam("color", "Color", SCRIPT_PARAM_COLOR, { 100, 255, 255, 255 })
			Menu.drawings.E:addParam("width", "Width", SCRIPT_PARAM_SLICE, 1, 1, 5)
			
		Menu.drawings:addSubMenu("R: Living Artillery", "R")
			Menu.drawings.R:addParam("active", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.R:addParam("color", "Color", SCRIPT_PARAM_COLOR, { 100, 255, 255, 255 })
			Menu.drawings.R:addParam("width", "Width", SCRIPT_PARAM_SLICE, 1, 1, 5)
		
		Menu.drawings:addSubMenu("P: Icathian Surprise", "P")
			Menu.drawings.P:addParam("active", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.P:addParam("drawTarget", "Active", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.P:addParam("color", "Color", SCRIPT_PARAM_COLOR, {100, 255, 255, 255})
			Menu.drawings.P:addParam("width", "Width", SCRIPT_PARAM_SLICE, 1, 1, 5)
			Menu.drawings.P:addParam("mode", "Mode", SCRIPT_PARAM_LIST, 2, {"Max Range", "Dynamic", "Both"})
	
	-- Kill Steal
	Menu:addSubMenu("Kill Steal", "KS")
		Menu.KS:addSubMenu("Active Spells", "spells")
			Menu.KS.spells:addParam("Q", "Q: Chaustic Spittle", SCRIPT_PARAM_ONOFF, true)
			Menu.KS.spells:addParam("E", "E: Void Ooze", SCRIPT_PARAM_ONOFF, true)
			Menu.KS.spells:addParam("R", "R: Living Artillery", SCRIPT_PARAM_ONOFF, true)
		Menu.KS:addParam("active", "Active", SCRIPT_PARAM_ONOFF, true) 	
		Menu.KS:addParam("irspells", "Cast Spells in AA range", SCRIPT_PARAM_ONOFF, false)
		Menu.KS:addParam("RStacks", "Ult Stack limiter", SCRIPT_PARAM_SLICE, 9, 1, 9)
		Menu.KS:addParam("allycheck", "Ignore if no allies near", SCRIPT_PARAM_ONOFF, true)
	
	-- Extras
	Menu:addSubMenu("Extras", "extras")
		Menu.extras:addSubMenu("Auto Pot", "autopot")
			Menu.extras.autopot:addParam("hp", "Minimum Health", SCRIPT_PARAM_SLICE, 30, 0, 100)
			Menu.extras.autopot:addParam("mn", "Minimum Mana", SCRIPT_PARAM_SLICE, 30, 0, 100)
	
	-- SOW
	Menu:addSubMenu("Keybinding/Orbwalker Settings", "sow")
	SOWi:LoadToMenu(Menu.sow)
	
	-- Simple Target Selector
	Menu:addSubMenu("Simple Target Selector", "sts")
	STS:AddToMenu(Menu.sts)
	
	-- Passive
	Menu:addParam("useP", "Auto Passive", SCRIPT_PARAM_ONOFF, true)
	
	-- Skins
	if VIP_USER then
		Menu:addParam("prediction", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction", "PROdiction"})
		Menu:addParam("skin", "Skin", SCRIPT_PARAM_LIST, #SkinList, SkinList)
	end
	
	
	-- Enemy's Menu
	for _,enemy in pairs(GetEnemyHeroes()) do
		-- Carry
		Menu.carry.Q:addParam(enemy.hash, enemy.charName, SCRIPT_PARAM_ONOFF, true)
		Menu.carry.W:addParam(enemy.hash, enemy.charName, SCRIPT_PARAM_ONOFF, true)
		Menu.carry.E:addParam(enemy.hash, enemy.charName, SCRIPT_PARAM_ONOFF, true)
		Menu.carry.R:addParam(enemy.hash, enemy.charName, SCRIPT_PARAM_ONOFF, true)
		
		-- Harass
		Menu.harass.Q:addParam(enemy.hash, enemy.charName, SCRIPT_PARAM_ONOFF, true)
		Menu.harass.W:addParam(enemy.hash, enemy.charName, SCRIPT_PARAM_ONOFF, true)
		Menu.harass.E:addParam(enemy.hash, enemy.charName, SCRIPT_PARAM_ONOFF, true)
		Menu.harass.R:addParam(enemy.hash, enemy.charName, SCRIPT_PARAM_ONOFF, true)
		
		-- BOTRK
		Menu.carry.items:addParam(enemy.hash, enemy.charName, SCRIPT_PARAM_LIST, 1, {"Normal Cast", "Max Heal", "Chase", "Don't Cast"})
	end
	
end

-- Skin Hack by shalzuth
function GenModelPacket(champ, skinId)
	p = CLoLPacket(0x97)
	p:EncodeF(myHero.networkID)
	p.pos = 1
	t1 = p:Decode1()
	t2 = p:Decode1()
	t3 = p:Decode1()
	t4 = p:Decode1()
	p:Encode1(t1)
	p:Encode1(t2)
	p:Encode1(t3)
	p:Encode1(bit32.band(t4,0xB))
	p:Encode1(1)--hardcode 1 bitfield
	p:Encode4(skinId)
	for i = 1, #champ do
		p:Encode1(string.byte(champ:sub(i,i)))
	end
	for i = #champ + 1, 64 do
		p:Encode1(0)
	end
	p:Hide()
	RecvPacket(p)
end

function SkinHack()
	if Menu.skin ~= lastSkin and VIP_USER then
		if lastskin == 0 and Menu.skin == #SkinList then
			return
		else
			lastSkin = Menu.skin
			GenModelPacket("KogMaw", Menu.skin)
		end
	end
end
