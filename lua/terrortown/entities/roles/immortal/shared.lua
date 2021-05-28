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
	
local function CanSwapRoles(imm, tgt, dist)
	if GetRoundState() == ROUND_ACTIVE and IsValid(imm) and imm:IsPlayer() and imm:Alive() and not IsInSpecDM(imm) and imm:GetSubRole() == ROLE_IMMORTAL and IsValid(tgt) and tgt:IsPlayer() and tgt:Alive() and not IsInSpecDM(tgt) and tgt.imm_last_tagged == nil and dist <= GetConVar("ttt2_immortal_tag_dist"):GetInt() then
		return true
	else
		return false
	end
end

if SERVER then
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
	
	local function SwapRoles(old_imm, tgt)
		--Return early if both players have the same role and team, making sure to inform the tagger so they don't think the role is broken
		if old_imm:GetSubRole() == tgt:GetSubRole() and old_imm:GetTeam() == tgt:GetTeam() then
			LANG.Msg(ply, "SAME_" .. IMMORTAL.name, nil, MSG_MSTACK_WARN)
			return
		end
		
		--Don't reference the old_imm's team directly in case some other addon futzes with it for good reason.
		local old_imm_team = old_imm:GetTeam()
		local backsies_timer_len = GetConVar("ttt2_immortal_backsies_timer"):GetInt()
		
		--Immediately mark the Immortal with no backsies to prevent a counterswap.
		old_imm.imm_last_tagged = tgt:SteamID64()
		
		--Give the Immortal their new role/team first so as to not accidentally end the game due to preventWin
		--TODO: Determine if UpdateTeam and multiple SendFullStateUpdate commands really need to be here (seems excessive).
		old_imm:SetRole(tgt:GetSubRole(), tgt:GetTeam())
		SendFullStateUpdate()
		old_imm:UpdateTeam(tgt:GetTeam())
		SendFullStateUpdate()
		--Note: Explicitly use ROLE_IMMORTAL here since that is precisely what old_imm's previous role is (otherwise this code would not execute)
		tgt:SetRole(ROLE_IMMORTAL, old_imm_team)
		SendFullStateUpdate()
		tgt:UpdateTeam(old_imm_team)
		SendFullStateUpdate()
		
		--Now that the roles/teams have been switched, unmark any player that is registered as having tagged the previous Immortal
		for _, ply in ipairs(player.GetAll()) do
			if ply.imm_last_tagged == old_imm:SteamID64() then
				ply.imm_last_tagged = nil
				STATUS:RemoveStatus(ply, "ttt2_imm_no_backsies")
			end
		end
		
		--Finally take care of ensuring no backsies occur.
		if backsies_timer_len > 0 then
			STATUS:AddTimedStatus(old_imm, "ttt2_imm_no_backsies", backsies_timer_len, true)
			timer.Simple(backsies_timer_len, function()
				old_imm.imm_last_tagged = nil
			end)
		else
			STATUS:AddStatus(old_imm, "ttt2_imm_no_backsies")
		end
	end
	
	net.Receive("TTT2ImmortalSendTagRequest", function(len, ply)
		--Determine if the immortal is looking at someone who can be "tagged", and swap roles if they can.
		local trace = ply:GetEyeTrace(MASK_SHOT_HULL)
		local dist = trace.StartPos:Distance(trace.HitPos)
		local tgt = trace.Entity
		if CanSwapRoles(ply, tgt, dist) then
			SwapRoles(ply, tgt)
		elseif tgt.imm_last_tagged ~= nil then
			LANG.Msg(ply, "NO_BACKSIES_" .. IMMORTAL.name, nil, MSG_MSTACK_WARN)
		end
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
		if CanSwapRoles(client, ent, tData:GetEntityDistance()) then
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