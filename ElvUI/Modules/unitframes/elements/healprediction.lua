local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs

function UF:Construct_HealComm(frame)
	local myBar = CreateFrame('StatusBar', nil, frame.Health)
	myBar:SetStatusBarTexture(E["media"].blankTex)
	myBar:Hide()

	local otherBar = CreateFrame('StatusBar', nil, frame.Health)
	otherBar:SetStatusBarTexture(E["media"].blankTex)
	otherBar:Hide()

	local absorbBar = CreateFrame('StatusBar', nil, frame.Health)
	absorbBar:SetStatusBarTexture(E["media"].blankTex)
	absorbBar:Hide()

	local healAbsorbBar = CreateFrame('StatusBar', nil, frame.Health)
	healAbsorbBar:SetStatusBarTexture(E["media"].blankTex)
	healAbsorbBar:Hide()

	local overAbsorb = frame.Health:CreateTexture(nil, "ARTWORK")
	overAbsorb:SetTexture(E["media"].blankTex)
	overAbsorb:Hide()

	local overHealAbsorb = frame.Health:CreateTexture(nil, "ARTWORK")
	overHealAbsorb:SetTexture(E["media"].blankTex)
	overHealAbsorb:Hide()

	return {
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		maxOverflow = 1,
		overAbsorb_ = overAbsorb,
		overHealAbsorb = overHealAbsorb,
		PostUpdate = UF.UpdateHealComm,
		parent = frame,
	}
end

function UF:Configure_HealComm(frame)
	if (frame.db.healPrediction and frame.db.healPrediction.enable) then
		local healPrediction = frame.HealthPrediction
		local myBar = healPrediction.myBar
		local otherBar = healPrediction.otherBar
		local absorbBar = healPrediction.absorbBar
		local healAbsorbBar = healPrediction.healAbsorbBar

		if not frame:IsElementEnabled('HealthPrediction') then
			frame:EnableElement('HealthPrediction')
		end

		if frame.USE_PORTRAIT_OVERLAY then
			myBar:SetParent(frame.Portrait.overlay)
			otherBar:SetParent(frame.Portrait.overlay)
			absorbBar:SetParent(frame.Portrait.overlay)
			healAbsorbBar:SetParent(frame.Portrait.overlay)
		else
			myBar:SetParent(frame.Health)
			otherBar:SetParent(frame.Health)
			absorbBar:SetParent(frame.Health)
			healAbsorbBar:SetParent(frame.Health)
		end

		 if frame.db.health then
			local orientation = frame.db.health.orientation or frame.Health:GetOrientation()
			local reverseFill = not not frame.db.health.reverseFill
			local showAbsorbAmount = frame.db.healPrediction.showAbsorbAmount

			myBar:SetOrientation(orientation)
			otherBar:SetOrientation(orientation)
			absorbBar:SetOrientation(orientation)
			healAbsorbBar:SetOrientation(orientation)

			if frame.db.healPrediction.showOverAbsorbs and not showAbsorbAmount then
				healPrediction.overAbsorb = healPrediction.overAbsorb_
			else
				if healPrediction.overAbsorb then
					healPrediction.overAbsorb:Hide()
					healPrediction.overAbsorb = nil
				end
			end

			if orientation == "HORIZONTAL" then
				local width = frame.Health:GetWidth()
				local p1 = reverseFill and "RIGHT" or "LEFT"
				local p2 = reverseFill and "LEFT" or "RIGHT"

				myBar:ClearAllPoints()
				myBar:Point("TOP")
				myBar:Point("BOTTOM")
				myBar:Point(p1, frame.Health:GetStatusBarTexture(), p2)
				myBar:Size(width, 0)

				otherBar:ClearAllPoints()
				otherBar:Point("TOP")
				otherBar:Point("BOTTOM")
				otherBar:Point(p1, myBar:GetStatusBarTexture(), p2)
				otherBar:Size(width, 0)

				absorbBar:ClearAllPoints()
				absorbBar:Point("TOP")
				absorbBar:Point("BOTTOM")

				if showAbsorbAmount then
					absorbBar:Point(p2, frame.Health, p2)
				else
					absorbBar:Point(p1, otherBar:GetStatusBarTexture(), p2)
				end

				absorbBar:Size(width, 0)

				healAbsorbBar:ClearAllPoints()
				healAbsorbBar:Point("TOP")
				healAbsorbBar:Point("BOTTOM")
				healAbsorbBar:Point(p2, frame.Health:GetStatusBarTexture(), p2)
				healAbsorbBar:Size(width, 0)

				if healPrediction.overAbsorb then
					healPrediction.overAbsorb:ClearAllPoints()
					healPrediction.overAbsorb:Point("TOP")
					healPrediction.overAbsorb:Point("BOTTOM")
					healPrediction.overAbsorb:Point(p1, frame.Health, p2)
					healPrediction.overAbsorb:Size(4, 0)
				end

				healPrediction.overHealAbsorb:ClearAllPoints()
				healPrediction.overHealAbsorb:Point("TOP")
				healPrediction.overHealAbsorb:Point("BOTTOM")
				healPrediction.overHealAbsorb:Point(p2, frame.Health, p1)
				healPrediction.overHealAbsorb:Size(4, 0)
			else
				local height = frame.Health:GetHeight()
				local p1 = reverseFill and "TOP" or "BOTTOM"
				local p2 = reverseFill and "BOTTOM" or "TOP"

				myBar:ClearAllPoints()
				myBar:Point("LEFT")
				myBar:Point("RIGHT")
				myBar:Point(p1, frame.Health:GetStatusBarTexture(), p2)
				myBar:Size(0, height)

				otherBar:ClearAllPoints()
				otherBar:Point("LEFT")
				otherBar:Point("RIGHT")
				otherBar:Point(p1, myBar:GetStatusBarTexture(), p2)
				otherBar:Size(0, height)

				absorbBar:ClearAllPoints()
				absorbBar:Point("LEFT")
				absorbBar:Point("RIGHT")

				if showAbsorbAmount then
					absorbBar:Point(p2, frame.Health, p2)
				else
					absorbBar:Point(p1, otherBar:GetStatusBarTexture(), p2)
				end

				absorbBar:Size(0, height)

				healAbsorbBar:ClearAllPoints()
				healAbsorbBar:Point("LEFT")
				healAbsorbBar:Point("RIGHT")
				healAbsorbBar:Point(p2, frame.Health:GetStatusBarTexture(), p2)
				healAbsorbBar:Size(0, height)

				if healPrediction.overAbsorb then
					healPrediction.overAbsorb:ClearAllPoints()
					healPrediction.overAbsorb:Point("LEFT")
					healPrediction.overAbsorb:Point("RIGHT")
					healPrediction.overAbsorb:Point(p1, frame.Health, p2)
					healPrediction.overAbsorb:Size(0, 4)
				end

				healPrediction.overHealAbsorb:ClearAllPoints()
				healPrediction.overHealAbsorb:Point("LEFT")
				healPrediction.overHealAbsorb:Point("RIGHT")
				healPrediction.overHealAbsorb:Point(p2, frame.Health, p1)
				healPrediction.overHealAbsorb:Size(0, 4)
			end

			myBar:SetReverseFill(reverseFill)
			otherBar:SetReverseFill(reverseFill)
			absorbBar:SetReverseFill(showAbsorbAmount and not reverseFill or reverseFill)
			healAbsorbBar:SetReverseFill(not reverseFill)
		end

		local c = self.db.colors.healPrediction

		myBar:SetStatusBarColor(c.personal.r, c.personal.g, c.personal.b, c.personal.a)
		otherBar:SetStatusBarColor(c.others.r, c.others.g, c.others.b, c.others.a)
		absorbBar:SetStatusBarColor(c.absorbs.r, c.absorbs.g, c.absorbs.b, c.absorbs.a)
		healAbsorbBar:SetStatusBarColor(c.healAbsorbs.r, c.healAbsorbs.g, c.healAbsorbs.b, c.healAbsorbs.a)

		if healPrediction.overAbsorb then
			healPrediction.overAbsorb:SetVertexColor(c.overabsorbs.r, c.overabsorbs.g, c.overabsorbs.b, c.overabsorbs.a)
		end

		healPrediction.overHealAbsorb:SetVertexColor(c.overhealabsorbs.r, c.overhealabsorbs.g, c.overhealabsorbs.b, c.overhealabsorbs.a)

		healPrediction.maxOverflow = 1 + (c.maxOverflow or 0)
	else
		if frame:IsElementEnabled('HealthPrediction') then
			frame:DisableElement('HealthPrediction')
		end
	end
end

function UF:UpdateHealComm(unit, _, _, _, _, hasOverAbsorb)
	local frame = self.parent
	if frame.db and frame.db.healPrediction and frame.db.healPrediction.showOverAbsorbs and frame.db.healPrediction.showAbsorbAmount then
		if hasOverAbsorb then
			self.absorbBar:SetValue(UnitGetTotalAbsorbs(unit))
		end
	end
end