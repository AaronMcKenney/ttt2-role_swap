if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_swap.vmt")
	util.AddNetworkString("TTT2SwapperSendTagRequest")
end

function ROLE:PreInitialize()
	self.color = Color(195, 144, 155, 255)
	self.abbr = "swap"
	
	self.fallbackTable = {}
	self.unknownTeam = true --Disables team chat (among other things)
	
	--Scores have no meaning to the swapper
	self.scoreKillsMultiplier = 0
	self.scoreTeamKillsMultiplier = 0
	
	--Materialistic pleasures have no meaning to the swapper
	self.preventFindCredits = true
	self.preventKillCredits = true
	self.preventTraitorAloneCredits = true
	
	--Winning, losing, and kinship among others have no meaning to the swapper
	self.defaultTeam = TEAM_NONE
	--The swapper cannot win if they stand alone.
	self.preventWin = true
	
	self.conVarData = {
		pct = 0.13,
		maximum = 1,
		minPlayers = 8,
		random = 10,
		traitorButton = 0,
		
		--Materialistic pleasures have no meaning to the swapper
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
	
	hook.Add("TTT2PostPlayerDeath", "TTT2PostPlayerDeathSwapper", function(ply)
		--Always attempt to revive the Swapper if they happen to die.
		--A slight exception: If preventWin is false, then DO NOT revive the Swapper, as it would force other teams to constantly check for and kill the Swapper in order to win.
		if ply:GetSubRole() == ROLE_SWAPPER and ply:GetSubRoleData().preventWin and not IsInSpecDM(ply) then
			local spawn_pos = nil
			if GetConVar("ttt2_swapper_respawn_at_mapspawn"):GetBool() then
				--This function will do many checks to ensure that the randomly selected spawn position is safe.
				local spawn_entity = spawn.GetRandomPlayerSpawnEntity(ply)
				if spawn_entity then
					spawn_pos = spawn_entity:GetPos()
				end
			end
			
			ply:Revive(GetConVar("ttt2_swapper_seconds_until_respawn"):GetInt(), --Delay
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
	
	hook.Add("EntityTakeDamage", "EntityTakeDamageSwapper", function(target, dmg_info)
		if not IsValid(target) or not target:IsPlayer() then
			return
		end
		
		local attacker = dmg_info:GetAttacker()
		local attacker_is_swapper = (IsValid(attacker) and attacker:IsPlayer() and attacker:GetSubRole() == ROLE_SWAPPER and not IsInSpecDM(attacker))
		
		--Swapper can't deal any damage to any player.
		--If damage_immunity is set, then the Swapper can't receive any damage either.
		if attacker_is_swapper or (GetConVar("ttt2_swapper_damage_immunity"):GetBool() and target:GetSubRole() == ROLE_SWAPPER and not IsInSpecDM(target) and target:GetSubRoleData().preventWin) then
			dmg_info:SetDamage(0)
		end
	end)
	
	hook.Add("TTTEndRound", "TTTEndRoundSwapper", function()
		for _, ply in ipairs(player.GetAll()) do
			ply.swap_last_tagged = nil
		end
	end)
	
	net.Receive("TTT2SwapperSendTagRequest", function(len, ply)
		--Determine if the Swapper is looking at someone who can be "tagged", and swap roles if they can.
		local trace = ply:GetEyeTrace(MASK_SHOT_HULL)
		local dist = trace.StartPos:Distance(trace.HitPos)
		local tgt = trace.Entity
		SWAP_DATA.AttemptSwap(ply, tgt, dist)
	end)
end

if CLIENT then
	hook.Add("Initialize", "InitializeSwapper", function()
		STATUS:RegisterStatus("ttt2_swap_no_backsies", {
			hud = Material("materials/vgui/ttt/dynamic/roles/icon_swap.vmt"),
			type = "good"
		})
	end)
	
	hook.Add("TTTRenderEntityInfo", "TTTRenderEntityInfoSwapper", function(tData)
		local client = LocalPlayer()
		local ent = tData:GetEntity()
		
		--If the player can tag the player they're looking at, inform them by putting a notification
		--on the body. Also tell them which key they need to press.
		if SWAP_DATA.CanSwapRoles(client, ent, tData:GetEntityDistance()) then
			local tag_key = string.upper(input.GetKeyName(bind.Find("SwapperSendTagRequest")))
			
			if tData:GetAmountDescriptionLines() > 0 then
				tData:AddDescriptionLine()
			end
			
			tData:AddDescriptionLine(LANG.GetParamTranslation("PRESS_TO_TAG_" .. SWAPPER.name, {k = tag_key}), SWAPPER.color)
		end
	end)
	
	local function SendTagRequest()
		local client = LocalPlayer()
		if IsInSpecDM(client) then
			return
		end
		
		net.Start("TTT2SwapperSendTagRequest")
		net.SendToServer()
	end
	bind.Register("SwapperSendTagRequest", SendTagRequest, nil, "Swapper", "Tag", KEY_E)
end

------------
-- SHARED --
------------

hook.Add("TTTPlayerSpeedModifier", "TTTPlayerSpeedModifierSwapper", function(ply, _, _, no_lag)
	if not IsValid(ply) or ply:GetSubRole() ~= ROLE_SWAPPER or IsInSpecDM(ply) then
		return
	end
	
	no_lag[1] = no_lag[1] * GetConVar("ttt2_swapper_speed_multi"):GetFloat()
end)

hook.Add("TTT2StaminaDrain", "TTT2StaminaDrainSwapper", function(ply, stamina_drain_mod)
	if not IsValid(ply) or ply:GetSubRole() ~= ROLE_SWAPPER or IsInSpecDM(ply) then
		return
	end
	
	stamina_drain_mod[1] = stamina_drain_mod[1] * GetConVar("ttt2_swapper_stamina_drain"):GetFloat()
end)

hook.Add("TTT2StaminaRegen", "TTT2StaminaRegenSwapper", function(ply, stamina_regen_mod)
	if not IsValid(ply) or ply:GetSubRole() ~= ROLE_SWAPPER or IsInSpecDM(ply) then
		return
	end
	
	stamina_regen_mod[1] = stamina_regen_mod[1] * GetConVar("ttt2_swapper_stamina_regen"):GetFloat()
end)