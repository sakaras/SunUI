if select(4, GetBuildInfo()) < 50200 then return end--Don't load on live
local mod	= DBM:NewMod(831, "DBM-ThroneofThunder", nil, 362)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 8567 $"):sub(12, -3))
--mod:SetCreatureID(62983)
mod:SetModelID(47739) -- most likely a placeholder :)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START"
)
