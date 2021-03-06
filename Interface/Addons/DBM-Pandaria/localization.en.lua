local L

-----------------------
-- Sha of Anger --
-----------------------
L= DBM:GetModLocalization(691)

L:SetOptionLocalization({
	SoundWOP 			= "voice warning: important skills",
	HudMAP				= "HudMAP: $spell:119622",
	RangeFrame			= "Show dynamic range frame based on player debuff status for\n$spell:119622",
	SetIconOnMC			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(119622)
})

-----------------------
-- Salyis --
-----------------------
L= DBM:GetModLocalization(725)

L:SetOptionLocalization({
	SoundWOP 			= "voice warning: important skills"
})

--------------
-- Oondasta --
--------------
L= DBM:GetModLocalization(826)

L:SetOptionLocalization({
	SoundWOP 			= "voice warning: important skills",
	RangeFrame			= "Show range frame for $spell:137511"
})

---------------------------
-- Nalak, The Storm Lord --
---------------------------
L= DBM:GetModLocalization(814)

L:SetOptionLocalization({
	RangeFrame			= "Show range frame (10) for $spell:136340"
})
