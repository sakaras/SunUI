local S, C, L, DB, _ = unpack(SunUI)
----------------------------------------------------------------------------------------
--	Based on tekKompare(by Tekkub)
----------------------------------------------------------------------------------------
local orig1, orig2 = {}, {}
local GameTooltip = GameTooltip

local linktypes = {item = true, enchant = true, spell = true, quest = true, unit = true, talent = true, achievement = true, glyph = true, instancelock = true, currency = true}

local function OnHyperlinkEnter(frame, link, ...)
	local linktype = link:match("^([^:]+)")
	if linktype and linktypes[linktype] then
		GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT", -3, 0)
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end

	if orig1[frame] then return orig1[frame](frame, link, ...) end
end

local function OnHyperlinkLeave(frame, ...)
	GameTooltip:Hide()
	if orig2[frame] then return orig2[frame](frame, ...) end
end

local _G = getfenv(0)
for i = 1, NUM_CHAT_WINDOWS do
	if i ~= 2 then
		local frame = _G["ChatFrame"..i]
		orig1[frame] = frame:GetScript("OnHyperlinkEnter")
		frame:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)

		orig2[frame] = frame:GetScript("OnHyperlinkLeave")
		frame:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)
	end
end