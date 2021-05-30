if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_imm.vmt")
	util.AddNetworkString("TTT2ImmortalSendTagRequest")
end

function ROLE:PreInitialize()
	self.color = Color(128, 128, 128, 255)
	self.abbr = "imm"
	
	self.fallbackTable = {}
	self.unknownTeam = true --Disables team chat (among other things)
	
	--Scores have no meaning to the immortal
	self.scoreKillsMultiplier = 0
	self.scoreTeamKillsMultiplier = 0
	
	--Materialistic pleasures have no meaning to the immortal
	self.preventFindCredits = true
	self.preventKillCredits = true
	self.preventTraitorAloneCredits = true
	
	--Winning, losing, and kinship among others have no meaning to the immortal
	self.defaultTeam = TEAM_NONE
	--The Immortal cannot win if they stand alone.
	self.preventWin = true
	
	self.conVarData = {
		pct = 0.13,
		maximum = 1,
		minPlayers = 8,
		random = 10,
		traitorButton = 0,
		
		--Materialistic pleasures have no meaning to the immortal
		credits = 0,
		creditsTraitorKill = 0,
		creditsTraitorDead = 0,
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
	
	hook.Add("TTT2PostPlayerDeath", "TTT2PostPlayerDeathHookForImmortal", function(ply)
		--Always attempt to revive the Immortal if they happen to die.
		--A slight exception: If preventWin is false, then DO NOT revive the Immortal, as it would force other teams to constantly check for and kill the Immortal in order to win.
		if ply:GetSubRole() == ROLE_IMMORTAL and ply:GetSubRoleData().preventWin and not IsInSpecDM(ply) then
			local spawn_pos = nil
			if GetConVar("ttt2_immortal_respawn_at_mapspawn"):GetBool() then
				--This function will do many checks to ensure that the randomly selected spawn position is safe.
				local spawn_entity = spawn.GetRandomPlayerSpawnEntity(ply)
				if spawn_entity then
					spawn_pos = spawn_entity:GetPos()
				end
			end
			
			ply:Revive(GetConVar("ttt2_immortal_seconds_until_respawn"):GetInt(), --Delay
				nil, --OnRevive function
				function(ply) --DoCheck function
					--Return false (do not go through with the revival) if doing so could cause issues
					return GetRoundState() == ROUND_ACTIVE and (not ply:Alive() or IsInSpecDM(ply))
				end,
				false, --needsCorpse
				false, --blocksRound (Prevents anyone from winning during respawn delay)
				nil, --OnFail function
				spawn_pos, --The player's respawn point (If nil, will be their corpse if present, and their point of death otherwise)
				nil --spawnEyeAngle
			)
		end
	end)
	
	hook.Add("EntityTakeDamage", "ImmortalModifyDamage", function(target, dmg_info)
		if not IsValid(target) or not target:IsPlayer() then
			return
		end
		
		local attacker = dmg_info:GetAttacker()
		local attacker_is_immortal = (IsValid(attacker) and attacker:IsPlayer() and attacker:GetSubRole() == ROLE_IMMORTAL and not IsInSpecDM(attacker))
		
		--Immortal can't deal any damage to any player.
		--If damage_immunity is set, then the Immortal can't receive any damage either.
		if attacker_is_immortal or (GetConVar("ttt2_immortal_damage_immunity"):GetBool() and target:GetSubRole() == ROLE_IMMORTAL and not IsInSpecDM(target) and target:GetSubRoleData().preventWin) then
			dmg_info:SetDamage(0)
		end
	end)
	
	hook.Add("TTTEndRound", "ImmortalEndRoundForServer", function()
		for _, ply in ipairs(player.GetAll()) do
			ply.imm_last_tagged = nil
		end
	end)
	
	net.Receive("TTT2ImmortalSendTagRequest", function(len, ply)
		--Determine if the immortal is looking at someone who can be "tagged", and swap roles if they can.
		local trace = ply:GetEyeTrace(MASK_SHOT_HULL)
		local dist = trace.StartPos:Distance(trace.HitPos)
		local tgt = trace.Entity
		IMM_SWAP_DATA.AttemptSwap(ply, tgt, dist)
	end)
end

if CLIENT then
	hook.Add("Initialize", "ImmortalInitialize", function()
		STATUS:RegisterStatus("ttt2_imm_no_backsies", {
			hud = Material("materials/vgui/ttt/dynamic/roles/icon_imm.vmt"),
			type = "good"
		})
	end)
	
	hook.Add("TTTRenderEntityInfo", "ImmortalRenderEntityInfo", function(tData)
		local client = LocalPlayer()
		local ent = tData:GetEntity()
		
		--If the player can tag the player they're looking at, inform them by putting a notification
		--on the body. Also tell them which key they need to press.
		if IMM_SWAP_DATA.CanSwapRoles(client, ent, tData:GetEntityDistance()) then
			local tag_key = string.upper(input.GetKeyName(bind.Find("ImmortalSendTagRequest")))
			
			if tData:GetAmountDescriptionLines() > 0 then
				tData:AddDescriptionLine()
			end
			
			tData:AddDescriptionLine(LANG.GetParamTranslation("PRESS_TO_TAG_" .. IMMORTAL.name, {k = tag_key}), IMMORTAL.color)
		end
	end)
	
	local function SendTagRequest()
		local client = LocalPlayer()
		if IsInSpecDM(client) then
			return
		end
		
		net.Start("TTT2ImmortalSendTagRequest")
		net.SendToServer()
	end
	bind.Register("ImmortalSendTagRequest", SendTagRequest, nil, "Immortal", "Tag", KEY_E)
end

------------
-- SHARED --
------------

hook.Add("TTTPlayerSpeedModifier", "ImmortalModifySpeed", function(ply, _, _, no_lag)
	if not IsValid(ply) or ply:GetSubRole() ~= ROLE_IMMORTAL or IsInSpecDM(ply) then
		return
	end
	
	no_lag[1] = no_lag[1] * GetConVar("ttt2_immortal_speed_multi"):GetFloat()
end)

hook.Add("TTT2StaminaDrain", "BankerModifyStaminaDrain", function(ply, stamina_drain_mod)
	if not IsValid(ply) or ply:GetSubRole() ~= ROLE_IMMORTAL or IsInSpecDM(ply) then
		return
	end
	
	stamina_drain_mod[1] = stamina_drain_mod[1] * GetConVar("ttt2_immortal_stamina_drain"):GetFloat()
end)

hook.Add("TTT2StaminaRegen", "BankerModifyStaminaRegen", function(ply, stamina_regen_mod)
	if not IsValid(ply) or ply:GetSubRole() ~= ROLE_IMMORTAL or IsInSpecDM(ply) then
		return
	end
	
	stamina_regen_mod[1] = stamina_regen_mod[1] * GetConVar("ttt2_immortal_stamina_regen"):GetFloat()
end)