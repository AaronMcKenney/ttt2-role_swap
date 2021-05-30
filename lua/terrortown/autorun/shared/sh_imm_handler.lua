if SERVER then
	AddCSLuaFile()
end

IMM_SWAP_DATA = {}

local function IsInSpecDM(ply)
	if SpecDM and (ply.IsGhost and ply:IsGhost()) then
		return true
	end
	
	return false
end

function IMM_SWAP_DATA.CanSwapRoles(imm, tgt, dist)
	if GetRoundState() == ROUND_ACTIVE and IsValid(imm) and imm:IsPlayer() and imm:Alive() and not IsInSpecDM(imm) and imm:GetSubRole() == ROLE_IMMORTAL and IsValid(tgt) and tgt:IsPlayer() and tgt:Alive() and not IsInSpecDM(tgt) and tgt.imm_last_tagged == nil and dist <= GetConVar("ttt2_immortal_tag_dist"):GetInt() then
		return true
	else
		return false
	end
end

if SERVER then
	function IMM_SWAP_DATA.SwapRoles(old_imm, tgt)
		--Return early if both players have the same role and team, making sure to inform the tagger so they don't think the role is broken
		--Edge case: Break off early if a Dop!Immortal tries to swap with a regular Immortal, as nothing would happen.
		if old_imm:GetSubRole() == tgt:GetSubRole() and (old_imm:GetTeam() == tgt:GetTeam() or (old_imm:GetTeam() == TEAM_DOPPELGANGER and tgt:GetTeam() == TEAM_NONE)) then
			LANG.Msg(ply, "SAME_" .. IMMORTAL.name, nil, MSG_MSTACK_WARN)
			return false
		end
		
		local old_imm_role = old_imm:GetSubRole()
		local old_imm_team = old_imm:GetTeam()
		local backsies_timer_len = GetConVar("ttt2_immortal_backsies_timer"):GetInt()
		
		--Immediately mark the Immortal with no backsies to prevent a counterswap.
		old_imm.imm_last_tagged = tgt:SteamID64()
		
		--Give the Immortal their new role/team first so as to not accidentally end the game due to preventWin
		if not (DOPPELGANGER and old_imm_team == TEAM_DOPPELGANGER) then
			old_imm:SetRole(tgt:GetSubRole(), tgt:GetTeam())
			tgt:SetRole(old_imm_role, old_imm_team)
		else
			--Edge case: If a Dop!Immortal tags a player, they shall keep their team, but change roles.
			--This is done because otherwise a Dop!Immortal is mechanically the same as a normal Immortal, due to preventWin making them useless.
			--This method is more fun for the Dop.
			old_imm:SetRole(tgt:GetSubRole(), old_imm_team)
			
			--Hardcode the tgt's team to TEAM_NONE, so that they are falsely lead to believe that they weren't tagged by a Doppelganger.
			tgt:SetRole(old_imm_role, TEAM_NONE)
		end
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
		
		return true
	end

	function IMM_SWAP_DATA.AttemptSwap(ply, tgt, dist)
		local did_swap = false
		
		if IMM_SWAP_DATA.CanSwapRoles(ply, tgt, dist) then
			did_swap = IMM_SWAP_DATA.SwapRoles(ply, tgt)
		elseif tgt.imm_last_tagged ~= nil then
			LANG.Msg(ply, "NO_BACKSIES_" .. IMMORTAL.name, nil, MSG_MSTACK_WARN)
		end
		
		return did_swap
	end
end