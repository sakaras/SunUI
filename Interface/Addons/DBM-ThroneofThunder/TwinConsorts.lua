if select(4, GetBuildInfo()) < 50200 then return end--Don't load on live
local mod	= DBM:NewMod(829, "DBM-ThroneofThunder", nil, 362)
local L		= mod:GetLocalizedStrings()
local sndWOP	= mod:NewSound(nil, "SoundWOP", true)

mod:SetRevision(("$Revision: 8816 $"):sub(12, -3))
mod:SetCreatureID(68905, 68904)--Lu'lin 68905, Suen 68904
mod:SetModelID(46975)--Lu'lin, 46974 Suen

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_SUCCESS",
	"SPELL_PERIODIC_DAMAGE",
	"SPELL_PERIODIC_MISSED",
	"SPELL_SUMMON",
	"UNIT_DIED",
	"UNIT_SPELLCAST_SUCCEEDED"
)

--Darkness
local warnNight							= mod:NewSpellAnnounce("ej7641", 2, 108558)
local warnCosmicBarrage					= mod:NewSpellAnnounce(136752, 2)
local warnTearsOfSun					= mod:NewSpellAnnounce(137404, 3)
local warnBeastOfNightmares				= mod:NewTargetAnnounce(137375, 3, nil, mod:IsTank() or mod:IsHealer())
--Light
local warnDay							= mod:NewSpellAnnounce("ej7645", 2, 122789)
local warnLightOfDay					= mod:NewSpellAnnounce(137403, 2, nil, false)--Spammy, but leave it as an option at least
local warnFanOfFlames					= mod:NewStackAnnounce(137408, 2, nil, mod:IsTank() or mod:IsHealer())
local warnFlamesOfPassion				= mod:NewSpellAnnounce(137414, 3)--Todo, check target scanning
local warnIceCommet						= mod:NewSpellAnnounce(137419, 2)
local warnNuclearInferno				= mod:NewCastAnnounce(137491, 4)--Heroic
--Dusk
local warnTidalForce					= mod:NewCastAnnounce(137531, 2)

--Darkness
local specWarnCosmicBarrage				= mod:NewSpecialWarningSpell(136752, false, nil, nil, 2)
local specWarnTearsOfSun				= mod:NewSpecialWarningSpell(137404, nil, nil, nil, 2)
local specWarnBeastOfNightmares			= mod:NewSpecialWarningSpell(137375, mod:IsTank())
--Light
local specWarnFanOfFlames				= mod:NewSpecialWarningStack(137408, mod:IsTank(), 2)
local specWarnFanOfFlamesOther			= mod:NewSpecialWarningTarget(137408, mod:IsTank())
local specWarnIceCommet					= mod:NewSpecialWarningSpell(137419, false)
local specWarnFire						= mod:NewSpecialWarningMove(137417)
local specWarnNuclearInferno			= mod:NewSpecialWarningSpell(137491, nil, nil, nil, 2)--Heroic
--Dusk
local specWarnTidalForce				= mod:NewSpecialWarningSpell(137531, nil, nil, nil, 2)--Maybe switch to a stop dps warning, or a switch to Suen?


--Darkness
--Light of Day (137403) has a HIGHLY variable cd variation, every 6-14 seconds. Not to mention it requires using SPELL_DAMAGE and SPELL_MISSED. for now i'm excluding it on purpose
local timerDayCD						= mod:NewNextTimer(184, "ej7645", nil, nil, nil, 122789)--Probably just need localizing, no short text version. 
local timerCosmicBarrageCD				= mod:NewCDTimer(23, 136752)
local timerTearsOfTheSunCD				= mod:NewCDTimer(40, 137404)
local timerBeastOfNightmaresCD			= mod:NewCDTimer(50, 137375)
--Light
local timerDuskCD						= mod:NewNextTimer(179, "ej7633", nil, nil, nil, 130013)
local timerLightOfDayCD					= mod:NewCDTimer(6, 137403, nil, false)--Trackable in day phase using UNIT event since boss1 can be used in this phase. Might be useful for heroic to not run behind in shadows too early preparing for a special
local timerFanOfFlamesCD				= mod:NewNextTimer(12, 137408, nil, mod:IsTank() or mod:IsHealer())
local timerFanOfFlames					= mod:NewTargetTimer(30, 137408, nil, mod:IsTank())
local timerFlamesOfPassionCD			= mod:NewCDTimer(30, 137414)
local timerIceCommetCD					= mod:NewCDTimer(25, 137419)--Every 25-35 seconds on normal. On heroic it's every 15 seconds almost precisely (i suspect heroic gets them more often to ensure RNG doesn't wipe you to Nuclear Inferno)
local timerNuclearInfernoCD				= mod:NewCDTimer(55.5, 137491)
--Dusk
local timerTidalForceCD					= mod:NewCDTimer(74, 137531)

local berserkTimer						= mod:NewBerserkTimer(600)

mod:AddBoolOption("RangeFrame")--For various abilities that target even melee. UPDATE, cosmic barrage (worst of the 3 abilities) no longer target melee. However, light of day and tears of teh sun still do. melee want to split into 2-3 groups (depending on how many) but no longer have to stupidly spread about all crazy and out of range of boss during cosmic barrage to avoid dying. On that note, MAYBE change this to ranged default instead of all.

mod:AddBoolOption("HudMAP", true, "sound")
mod:AddBoolOption("HudMAP2", true, "sound")

local DBMHudMap = DBMHudMap
local free = DBMHudMap.free
local function register(e)	
	DBMHudMap:RegisterEncounterMarker(e)
	return e
end
local lightmaker = {}
local CBMarkers = {}

function mod:OnCombatStart(delay)
	table.wipe(lightmaker)
	table.wipe(CBMarkers)
	berserkTimer:Start(-delay)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(8)
	end
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
	if self.Options.HudMAP or self.Options.HudMAP2 then
		DBMHudMap:FreeEncounterMarkers()
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(137491) then
		warnNuclearInferno:Show()
		specWarnNuclearInferno:Show()
		timerNuclearInfernoCD:Start()
		sndWOP:Play("Interface\\AddOns\\DBM-Core\\extrasounds\\ex_tt_hzly.mp3") --核子煉獄
	elseif args:IsSpellID(137531) then
		warnTidalForce:Show()
		specWarnTidalForce:Show()
		timerTidalForceCD:Start()
		sndWOP:Play("Interface\\AddOns\\DBM-Core\\extrasounds\\ex_tt_cxzl.mp3") --潮汐之力
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(136752) then
		warnCosmicBarrage:Show()
		specWarnCosmicBarrage:Show()
		sndWOP:Play("Interface\\AddOns\\DBM-Core\\extrasounds\\scattersoon.mp3")--注意分散
		sndWOP:Schedule(1.5, "Interface\\AddOns\\DBM-Core\\extrasounds\\countfour.mp3")
		sndWOP:Schedule(2.5, "Interface\\AddOns\\DBM-Core\\extrasounds\\countthree.mp3")
		sndWOP:Schedule(3.5, "Interface\\AddOns\\DBM-Core\\extrasounds\\counttwo.mp3")
		sndWOP:Schedule(4.5, "Interface\\AddOns\\DBM-Core\\extrasounds\\countone.mp3")
		if self.Options.HudMAP2 then
			for i = 1, DBM:GetGroupMembers() do
				if not UnitIsDeadOrGhost("raid"..i) then
					CBMarkers[UnitName("raid"..i)] = register(DBMHudMap:PlaceRangeMarkerOnPartyMember("timer", UnitName("raid"..i), 8, 5, 1, 1, 1, 0.7):RegisterForAlerts():Rotate(360, 5.2):Appear())
				end
			end
		end
		if timerDayCD:GetTime() < 165 then
			timerCosmicBarrageCD:Start()
		end
	elseif args:IsSpellID(137404) then
		warnTearsOfSun:Show()
		specWarnTearsOfSun:Show()
		if timerDayCD:GetTime() < 145 then
			timerTearsOfTheSunCD:Start()
		end
	elseif args:IsSpellID(137375) then
		warnBeastOfNightmares:Show(args.destName)
		specWarnBeastOfNightmares:Show()
		if args:IsPlayer() or mod:IsHealer() then
			sndWOP:Play("Interface\\AddOns\\DBM-Core\\extrasounds\\ex_tt_mys.mp3") --夢魘獸出現
		else
			if not UnitDebuff("player", GetSpellInfo(137375)) and not UnitIsDeadOrGhost("player") then
				if mod:IsTank() then
					sndWOP:Play("Interface\\AddOns\\DBM-Core\\extrasounds\\changemt.mp3") --換坦嘲諷
				end
			end
		end
		if timerDayCD:GetTime() < 135 then
			timerBeastOfNightmaresCD:Start()
		end
	elseif args:IsSpellID(137408) then
		warnFanOfFlames:Show(args.destName, args.amount or 1)
		timerFanOfFlames:Start(args.destName)
		timerFanOfFlamesCD:Start()
		if args:IsPlayer() then
			if (args.amount or 1) >= 2 then
				specWarnFanOfFlames:Show(args.amount)
			end
		else
			if (args.amount or 1) >= 1 and not UnitDebuff("player", GetSpellInfo(137408)) and not UnitIsDeadOrGhost("player") then
				specWarnFanOfFlamesOther:Show(args.destName)
				if mod:IsTank() then
					sndWOP:Play("Interface\\AddOns\\DBM-Core\\extrasounds\\changemt.mp3") --換坦嘲諷
				end
			end
		end
	elseif args:IsSpellID(138264) and args:IsPlayer() then  --白虎
		if self.Options.HudMAP then
			lightmaker["1"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,705,352,731,381))
			lightmaker["2"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,731,381,709,377))
			lightmaker["3"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,709,377,686,373))
			lightmaker["4"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,686,373,712,398))
			lightmaker["5"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,712,398,709,376))
			lightmaker["6"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,709,376,705,354))
		end
	elseif args:IsSpellID(138267) and args:IsPlayer() then  --青龍
		if self.Options.HudMAP then
			lightmaker["1"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,693,393,686,371))
			lightmaker["2"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,686,371,710,377))
			lightmaker["3"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,710,377,704,353))
			lightmaker["4"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,704,353,725,361))
		end
	elseif args:IsSpellID(138254) and args:IsPlayer() then  --玄牛
		if self.Options.HudMAP then
			lightmaker["1"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,713,401,709,376))
			lightmaker["2"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,709,376,705,352))
			lightmaker["3"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,705,352,688,370))
			lightmaker["4"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,688,370,709,376))
			lightmaker["5"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,709,376,732,383))
		end
	elseif args:IsSpellID(138189) and args:IsPlayer() then  --红鹤
		if self.Options.HudMAP then
			lightmaker["1"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,733,382,705,353))
			lightmaker["2"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,705,353,687,371))
			lightmaker["3"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,687,371,709,377))
			lightmaker["4"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,709,377,732,383))
			lightmaker["5"] = register(DBMHudMap:AddEdge(1, 1, 1, 1, nil, nil, nil,732,383,713,401))
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(137408) then
		timerFanOfFlames:Cancel(args.destName)
	elseif args:IsSpellID(138264) and args:IsPlayer() then
		if self.Options.HudMAP then
			DBMHudMap:FreeEncounterMarkers()
			table.wipe(lightmaker)
		end
	elseif args:IsSpellID(138267) and args:IsPlayer() then
		if self.Options.HudMAP then
			DBMHudMap:FreeEncounterMarkers()
			table.wipe(lightmaker)
		end
	elseif args:IsSpellID(138254) and args:IsPlayer() then
		if self.Options.HudMAP then
			DBMHudMap:FreeEncounterMarkers()
			table.wipe(lightmaker)
		end
	elseif args:IsSpellID(138189) and args:IsPlayer() then
		if self.Options.HudMAP then
			DBMHudMap:FreeEncounterMarkers()
			table.wipe(lightmaker)
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(137414) then
		warnFlamesOfPassion:Show()
		timerFlamesOfPassionCD:Start()
	end
end

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(137419) then
		warnIceCommet:Show()
		specWarnIceCommet:Show()
		if self:IsDifficulty("heroic10", "heroic25") then
			timerIceCommetCD:Start(15)
		else
			timerIceCommetCD:Start()
		end
	end
end

--If this turns out unreliable, we can switch to yell, which is why I want it localized for now, in case it IS needed
--If we do switch to yell, we'll still want to delay it by 6 seconds since timers don't actually cancel until port in (ie she may cast another fan of flames for example
--"<333.5 18:37:56> [CHAT_MSG_MONSTER_YELL] CHAT_MSG_MONSTER_YELL#Lu'lin! Lend me your strength!#Suen#####0#0##0#247#nil#0#false#false", -- [71265]
--"<339.3 18:38:02> [INSTANCE_ENCOUNTER_ENGAGE_UNIT] Fake Args:#1#1#Suen#0xF1310D2800005863#worldboss#410952978#nil#1#Unknown#0xF1310D2900005864#worldboss#310232488
function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT(event)
	if UnitExists("boss2") and tonumber(UnitGUID("boss2"):sub(6, 10), 16) == 68905 then--Make sure we don't trigger it off another engage such as wipe engage event
		self:UnregisterShortTermEvents()
		sndWOP:Play("Interface\\AddOns\\DBM-Core\\extrasounds\\ex_tt_hhjd.mp3")--黃昏階段
		timerFanOfFlamesCD:Cancel()
		timerIceCommetCD:Start(11)--This seems to reset, despite what last CD was (this can be a bad thing if it was do any second)
		timerTidalForceCD:Start(20)
		timerCosmicBarrageCD:Start(48)
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 68905 then--Lu'lin
		timerCosmicBarrageCD:Cancel()
		timerTidalForceCD:Cancel()
		timerLightOfDayCD:Start()
		timerFanOfFlamesCD:Start(19)
		--She also does Flames of passion, but this is done 3 seconds after Lu'lin dies, is a 3 second timer worth it?
	elseif cid == 68904 then--Suen
		timerFlamesOfPassionCD:Cancel()
--		timerBeastOfNightmaresCD:Start()--My group kills Lu'lin first. Need log of Suen being killed first to get first beast timer value
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, _, spellId)
	if spellId == 137105 and self:AntiSpam(2, 1) then--Suen Ports away (Night Phase)
		timerLightOfDayCD:Cancel()
		timerFanOfFlamesCD:Cancel()
		timerFlamesOfPassionCD:Cancel()
		warnNight:Show()
		sndWOP:Cancel("Interface\\AddOns\\DBM-Core\\extrasounds\\countthree.mp3")
		sndWOP:Cancel("Interface\\AddOns\\DBM-Core\\extrasounds\\counttwo.mp3")
		sndWOP:Cancel("Interface\\AddOns\\DBM-Core\\extrasounds\\countone.mp3")
		sndWOP:Play("Interface\\AddOns\\DBM-Core\\extrasounds\\phasechange.mp3")--階段轉換
		sndWOP:Schedule(180, "Interface\\AddOns\\DBM-Core\\extrasounds\\ex_mop_btzb.mp3")--白天準備
		sndWOP:Schedule(181, "Interface\\AddOns\\DBM-Core\\extrasounds\\countthree.mp3")
		sndWOP:Schedule(182, "Interface\\AddOns\\DBM-Core\\extrasounds\\counttwo.mp3")
		sndWOP:Schedule(183, "Interface\\AddOns\\DBM-Core\\extrasounds\\countone.mp3")
		timerDayCD:Start()
		timerCosmicBarrageCD:Start(17)
		timerTearsOfTheSunCD:Start(23)
		timerBeastOfNightmaresCD:Start()
	elseif spellId == 137187 and self:AntiSpam(2, 2) then--Lu'lin Ports away (Day Phase)
		timerCosmicBarrageCD:Cancel()
		timerTearsOfTheSunCD:Cancel()
		timerBeastOfNightmaresCD:Cancel()
		warnDay:Show()
		timerDuskCD:Start()
		sndWOP:Cancel("Interface\\AddOns\\DBM-Core\\extrasounds\\countthree.mp3")
		sndWOP:Cancel("Interface\\AddOns\\DBM-Core\\extrasounds\\counttwo.mp3")
		sndWOP:Cancel("Interface\\AddOns\\DBM-Core\\extrasounds\\countone.mp3")
		sndWOP:Play("Interface\\AddOns\\DBM-Core\\extrasounds\\phasechange.mp3")--階段轉換
		sndWOP:Schedule(175, "Interface\\AddOns\\DBM-Core\\extrasounds\\ex_mop_hyzb.mp3")--黑夜準備
		sndWOP:Schedule(176, "Interface\\AddOns\\DBM-Core\\extrasounds\\countthree.mp3")
		sndWOP:Schedule(177, "Interface\\AddOns\\DBM-Core\\extrasounds\\counttwo.mp3")
		sndWOP:Schedule(178, "Interface\\AddOns\\DBM-Core\\extrasounds\\countone.mp3")
		timerLightOfDayCD:Start()
		timerFanOfFlamesCD:Start()
		timerFlamesOfPassionCD:Start(12.5)
		if self:IsDifficulty("heroic10", "heroic25") then
			timerIceCommetCD:Start(15)
			timerNuclearInfernoCD:Start(52)
		else
			timerIceCommetCD:Start()
		end
		self:RegisterShortTermEvents(
			"INSTANCE_ENCOUNTER_ENGAGE_UNIT"
		)
	elseif spellId == 138823 and self:AntiSpam(2, 3) then
		warnLightOfDay:Show()
		timerLightOfDayCD:Start()
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 137417 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
		specWarnFire:Show()
		sndWOP:Play("Interface\\AddOns\\DBM-Core\\extrasounds\\runaway.mp3") --快躲開
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
