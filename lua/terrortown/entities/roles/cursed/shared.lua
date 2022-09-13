if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_curs.vmt")
	util.AddNetworkString("TTT2CursedSendTagRequest")
	util.AddNetworkString("TTT2CursedSelfImmolateRequest")
	util.AddNetworkString("TTT2CursedSelfImmolateResponse")
end

function ROLE:PreInitialize()
	self.color = Color(48, 25, 52, 255)
	self.abbr = "curs"
	
	self.fallbackTable = {}
	self.unknownTeam = true --Disables team chat (among other things)
	
	--Scores have no meaning to the cursed (especially suicides).
	--Exception is bodyFoundMuliplier, as that is important for progressing the game for everyone.
	self.score.teamKillsMultiplier = 0
	self.score.killsMultiplier = 0
	self.score.bodyFoundMuliplier = 1
	self.score.surviveBonusMultiplier = 0
	self.score.survivePenaltyMultiplier = 0
	self.score.aliveTeammatesBonusMultiplier = 0
	self.score.allSurviveBonusMultiplier = 0
	self.score.timelimitMultiplier = 0
	self.score.suicideMultiplier = 0
	
	--Materialistic pleasures have no meaning to the cursed
	self.preventFindCredits = true
	
	--Winning, losing, and kinship among others have no meaning to the cursed
	self.defaultTeam = TEAM_NONE
	--The cursed cannot win if they stand alone.
	self.preventWin = true
	
	self.conVarData = {
		pct = 0.13,
		maximum = 1,
		minPlayers = 6,
		random = 30,
		traitorButton = 0,
		
		--Materialistic pleasures have no meaning to the cursed
		credits = 0,
		creditsAwardDeadEnable = 0,
		creditsAwardKillEnable = 0,
		shopFallback = SHOP_DISABLED,
		
		togglable = true
	}
end

local function IsInSpecDM(ply)
	if SpecDM and (ply.IsGhost and ply:IsGhost()) then
		return true
	end
	
	return false
end

if SERVER then
	local IMMOLATE_MODE = {NO = 0, CORPSE_ONLY = 1, WHENEVER = 2}
	
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		if GetConVar("ttt2_role_swap_deagle_enable"):GetBool() then
			ply:GiveEquipmentWeapon("weapon_ttt2_role_swap_deagle")
		end
	end
	
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		if GetConVar("ttt2_role_swap_deagle_enable"):GetBool() then
			--Hacky timer exists here because an internal SWEP:ShootBullet call will expect the owner of the role swap deagle to still be the owner after a successful shot.
			timer.Simple(0.2, function()
				ply:StripWeapon("weapon_ttt2_role_swap_deagle")
			end)
		end
	end
	
	hook.Add("EntityTakeDamage", "EntityTakeDamageCursed", function(target, dmg_info)
		if not IsValid(target) or not target:IsPlayer() then
			return
		end
		
		local attacker = dmg_info:GetAttacker()
		local attacker_is_cursed = (IsValid(attacker) and attacker:IsPlayer() and attacker:GetSubRole() == ROLE_CURSED and not IsInSpecDM(attacker))
		
		if attacker_is_cursed or (GetConVar("ttt2_cursed_damage_immunity"):GetBool() and target:GetSubRole() == ROLE_CURSED and not IsInSpecDM(target) and target:GetSubRoleData().preventWin) then
			--Cursed can't deal any damage to any player.
			--If damage_immunity is set, then the Cursed can't receive any damage either.
			dmg_info:SetDamage(0)
		elseif GetConVar("ttt2_cursed_no_dmg_backsies"):GetBool() and IsValid(attacker) and not IsInSpecDM(attacker) and attacker.curs_last_tagged and target:GetSubRole() == ROLE_CURSED then
			dmg_info:SetDamage(0)
			LANG.Msg(attacker, "NO_DMG_" .. CURSED.name, nil, MSG_MSTACK_WARN)
		end
	end)
	
	hook.Add("TTT2PostPlayerDeath", "TTT2PostPlayerDeathCursed", function(ply)
		local respawn_delay = GetConVar("ttt2_cursed_seconds_until_respawn"):GetInt()
		--Always attempt to revive the Cursed if they happen to die.
		--A slight exception: If preventWin is false, then DO NOT revive the Cursed, as it would force other teams to constantly check for and kill the Cursed in order to win.
		if ply:GetSubRole() == ROLE_CURSED and respawn_delay > 0 and ply:GetSubRoleData().preventWin and not IsInSpecDM(ply) then
			local spawn_pos = nil
			local spawn_eye_ang = nil
			if GetConVar("ttt2_cursed_respawn_at_mapspawn"):GetBool() then
				--This function will do many checks to ensure that the randomly selected spawn position is safe.
				local spawn_point = plyspawn.GetRandomSafePlayerSpawnPoint(ply)
				if spawn_point then
					spawn_pos = spawn_point.pos
					spawn_eye_ang = spawn_point.ang
				end
			end
			
			ply:Revive(respawn_delay, --Delay
				nil, --OnRevive function
				function(ply) --DoCheck function
					--Return false (do not go through with the revival) if doing so could cause issues
					return GetRoundState() == ROUND_ACTIVE and (not ply:Alive() or IsInSpecDM(ply))
				end,
				false, --needsCorpse
				REVIVAL_BLOCK_AS_ALIVE, --blocksRound (Prevents anyone from winning during respawn delay)
				nil, --OnFail function
				spawn_pos, --The player's respawn point (If nil, will be their corpse if present, and their point of death otherwise)
				spawn_eye_ang --spawnEyeAngle
			)
		end
	end)
	
	net.Receive("TTT2CursedSendTagRequest", function(len, ply)
		--Determine if the Cursed is looking at someone who can be "tagged", and swap roles if they can.
		local trace = ply:GetEyeTrace(MASK_SHOT_HULL)
		local dist = trace.StartPos:Distance(trace.HitPos)
		local tgt = trace.Entity
		CURS_DATA.AttemptSwap(ply, tgt, dist)
	end)
	
	net.Receive("TTT2CursedSelfImmolateRequest", function(len, ply)
		local mode = GetConVar("ttt2_cursed_self_immolate_mode"):GetInt()
		if ply:GetSubRole() ~= ROLE_CURSED or mode == IMMOLATE_MODE.NO or (mode == IMMOLATE_MODE.CORPSE_ONLY and ply:Alive()) or IsInSpecDM(ply) then
			return
		end
		
		--The following code is setup for "IgniteTarget", an internal function that the Flare Gun uses.
		--For some reason it's not a local function. It probably should be but I won't complain.
		local ply_or_corpse = ply
		if not ply:Alive() then
			ply_or_corpse = ply:FindCorpse()
			if not IsValid(ply_or_corpse) then
				--There is nothing to set on fire...
				return
			end
			
			if ply_or_corpse:WaterLevel() > 0 then
				--Setting the corpse on fire would do nothing, as the fire would put itself out immediately.
				--Instead remove the corpse with a puff of smoke.
				net.Start("TTT2CursedSelfImmolateResponse")
				net.WriteVector(ply_or_corpse:GetPos())
				net.Broadcast()
				
				--Force random world spawn location to be used for revival
				ply_or_corpse:Remove()
				ply:SetLastDeathPosition(nil)
				
				return
			end
			
			local time_until_respawn = 0
			if timer.Exists("TTT2RevivePlayer" .. ply:EntIndex()) then
				time_until_respawn = timer.TimeLeft("TTT2RevivePlayer" .. ply:EntIndex())
			end
			if time_until_respawn > 1 then
				--Corpse may not be removed before respawn is triggered. Force its removal shortly before they revive.
				timer.Simple(time_until_respawn - 0.5, function()
					if IsValid(ply_or_corpse) and IsValid(ply) and not ply:Alive() and not IsInSpecDM(ply) then
						--Remove the corpse in a puff of smoke.
						net.Start("TTT2CursedSelfImmolateResponse")
						net.WriteVector(ply_or_corpse:GetPos())
						net.Broadcast()
						
						--Force random world spawn location to be used for revival
						ply_or_corpse:Remove()
						ply:SetLastDeathPosition(nil)
					end
				end)
			end
		end
		
		local path = {Entity = ply_or_corpse}
		local dmg_info = DamageInfo()
		dmg_info:SetAttacker(ply)
		dmg_info:SetInflictor(ply)
		IgniteTarget(ply, path, dmg_info)
	end)
	
	hook.Add("TTT2PharaohPreventDamageToAnkh", "TTT2PharaohPreventDamageToAnkhCursed", function(attacker)
		if attacker:GetSubRole() == ROLE_CURSED then
			return true
		end
	end)
end

if CLIENT then
	--Model constants used for smoke generation effect
	local smokeparticles = {
		Model("particle/particle_smokegrenade"),
		Model("particle/particle_noisesphere")
	}
	
	hook.Add("TTTRenderEntityInfo", "TTTRenderEntityInfoCursed", function(tData)
		local client = LocalPlayer()
		local ent = tData:GetEntity()
		
		if client:GetSubRole() ~= ROLE_CURSED or IsInSpecDM(client) then
			return
		end
		
		--If the player can tag the player they're looking at, inform them by putting a notification
		--on the body. Also tell them which key they need to press.
		if CURS_DATA.CanSwapRoles(client, ent, tData:GetEntityDistance()) then
			local tag_key = string.upper(input.GetKeyName(bind.Find("CursedSendTagRequest")))
			
			if tData:GetAmountDescriptionLines() > 0 then
				tData:AddDescriptionLine()
			end
			
			tData:AddDescriptionLine(LANG.GetParamTranslation("PRESS_TO_TAG_" .. CURSED.name, {k = tag_key}), CURSED.color)
		elseif tData:GetAmountDescriptionLines() > 0 then
			tData:AddDescriptionLine()
		end
		
		--Also inform the player about the wonders of self-immolation
		local immolate_key = string.upper(input.GetKeyName(bind.Find("CursedSelfImmolateRequest")))
		tData:AddDescriptionLine(LANG.GetParamTranslation("ASSIST_WITH_IMMOLATION_" .. CURSED.name, {k = immolate_key}), CURSED.color)
	end)
	
	local function SendTagRequest()
		local client = LocalPlayer()
		if client:GetSubRole() ~= ROLE_CURSED or IsInSpecDM(client) then
			return
		end
		
		net.Start("TTT2CursedSendTagRequest")
		net.SendToServer()
	end
	bind.Register("CursedSendTagRequest", SendTagRequest, nil, "Cursed", "Tag", KEY_E)
	
	local function SelfImmolate()
		local client = LocalPlayer()
		if client:GetSubRole() ~= ROLE_CURSED or IsInSpecDM(client) then
			return
		end
		
		net.Start("TTT2CursedSelfImmolateRequest")
		net.SendToServer()
	end
	bind.Register("CursedSelfImmolateRequest", SelfImmolate, nil, "Cursed", "Self-Immolate", KEY_V)
	
	net.Receive("TTT2CursedSelfImmolateResponse", function()
		local pos = net.ReadVector()

		--Smoke spawn code by Alf21 (Taken from Pharaoh role)
		local em = ParticleEmitter(pos)
		local r = 1.5 * 64

		for i = 1, 75 do
			local prpos = VectorRand() * r
			prpos.z = prpos.z + 332
			prpos.z = math.min(prpos.z, 52)

			local p = em:Add(table.Random(smokeparticles), pos + prpos)
			if p then
				local gray = math.random(125, 255)
				p:SetColor(gray, gray, gray)
				p:SetStartAlpha(200)
				p:SetEndAlpha(0)
				p:SetVelocity(VectorRand() * math.Rand(900, 1300))
				p:SetLifeTime(0)

				p:SetDieTime(3)

				p:SetStartSize(math.random(140, 150))
				p:SetEndSize(math.random(1, 40))
				p:SetRoll(math.random(-180, 180))
				p:SetRollDelta(math.Rand(-0.1, 0.1))
				p:SetAirResistance(600)

				p:SetCollide(true)
				p:SetBounce(0.4)

				p:SetLighting(false)
			end
		end

		em:Finish()
	end)
end

------------
-- SHARED --
------------

hook.Add("TTTPlayerSpeedModifier", "TTTPlayerSpeedModifierCursed", function(ply, _, _, no_lag)
	if not IsValid(ply) or ply:GetSubRole() ~= ROLE_CURSED or IsInSpecDM(ply) then
		return
	end
	
	no_lag[1] = no_lag[1] * GetConVar("ttt2_cursed_speed_multi"):GetFloat()
end)

hook.Add("TTT2StaminaDrain", "TTT2StaminaDrainCursed", function(ply, stamina_drain_mod)
	if not IsValid(ply) or ply:GetSubRole() ~= ROLE_CURSED or IsInSpecDM(ply) then
		return
	end
	
	stamina_drain_mod[1] = stamina_drain_mod[1] * GetConVar("ttt2_cursed_stamina_drain"):GetFloat()
end)

hook.Add("TTT2StaminaRegen", "TTT2StaminaRegenCursed", function(ply, stamina_regen_mod)
	if not IsValid(ply) or ply:GetSubRole() ~= ROLE_CURSED or IsInSpecDM(ply) then
		return
	end
	
	stamina_regen_mod[1] = stamina_regen_mod[1] * GetConVar("ttt2_cursed_stamina_regen"):GetFloat()
end)