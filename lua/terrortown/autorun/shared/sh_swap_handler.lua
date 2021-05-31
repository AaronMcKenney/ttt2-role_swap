if SERVER then
	AddCSLuaFile()
end

SWAP_DATA = {}

local function IsInSpecDM(ply)
	if SpecDM and (ply.IsGhost and ply:IsGhost()) then
		return true
	end
	
	return false
end

function SWAP_DATA.CanSwapRoles(ply, tgt, dist)
	if GetRoundState() == ROUND_ACTIVE and IsValid(ply) and ply:IsPlayer() and ply:Alive() and not IsInSpecDM(ply) and ply:GetSubRole() == ROLE_SWAPPER and IsValid(tgt) and tgt:IsPlayer() and tgt:Alive() and not IsInSpecDM(tgt) and tgt.swap_last_tagged == nil and dist <= GetConVar("ttt2_swapper_tag_dist"):GetInt() then
		return true
	else
		return false
	end
end

if SERVER then
	function SWAP_DATA.SwapRoles(old_swapper, tgt)
		--Return early if both players have the same role and team, making sure to inform the tagger so they don't think the role is broken
		--Edge case: Break off early if a Dop!Swapper tries to swap with a regular Swapper, as nothing would happen.
		if old_swapper:GetSubRole() == tgt:GetSubRole() and (old_swapper:GetTeam() == tgt:GetTeam() or (old_swapper:GetTeam() == TEAM_DOPPELGANGER and tgt:GetTeam() == TEAM_NONE)) then
			LANG.Msg(old_swapper, "SAME_" .. SWAPPER.name, nil, MSG_MSTACK_WARN)
			return false
		end
		
		local old_swapper_role = old_swapper:GetSubRole()
		local old_swapper_team = old_swapper:GetTeam()
		local backsies_timer_len = GetConVar("ttt2_swapper_backsies_timer"):GetInt()
		
		--Immediately mark the Swapper with no backsies to prevent a counterswap.
		old_swapper.swap_last_tagged = tgt:SteamID64()
		
		--Give the Swapper their new role/team first so as to not accidentally end the game due to preventWin
		if not (DOPPELGANGER and old_swapper_team == TEAM_DOPPELGANGER) then
			old_swapper:SetRole(tgt:GetSubRole(), tgt:GetTeam())
			tgt:SetRole(old_swapper_role, old_swapper_team)
		else
			--Edge case: If a Dop!Swapper tags a player, they shall keep their team, but change roles.
			--This is done because otherwise a Dop!Swapper is mechanically the same as a normal Swapper, due to preventWin making them useless.
			--This method is more fun for the Dop.
			old_swapper:SetRole(tgt:GetSubRole(), old_swapper_team)
			
			--Hardcode the tgt's team to TEAM_NONE, so that they are falsely lead to believe that they weren't tagged by a Doppelganger.
			tgt:SetRole(old_swapper_role, TEAM_NONE)
		end
		SendFullStateUpdate()
		
		--Now that the roles/teams have been switched, unmark any player that is registered as having tagged the previous Swapper
		for _, ply in ipairs(player.GetAll()) do
			if ply.swap_last_tagged == old_swapper:SteamID64() then
				ply.swap_last_tagged = nil
				STATUS:RemoveStatus(ply, "ttt2_swap_no_backsies")
			end
		end
		
		--Finally take care of ensuring no backsies occur.
		if backsies_timer_len > 0 then
			STATUS:AddTimedStatus(old_swapper, "ttt2_swap_no_backsies", backsies_timer_len, true)
			timer.Simple(backsies_timer_len, function()
				old_swapper.swap_last_tagged = nil
			end)
		else
			STATUS:AddStatus(old_swapper, "ttt2_swap_no_backsies")
		end
		
		return true
	end

	function SWAP_DATA.AttemptSwap(ply, tgt, dist)
		local did_swap = false
		
		if SWAP_DATA.CanSwapRoles(ply, tgt, dist) then
			did_swap = SWAP_DATA.SwapRoles(ply, tgt)
		elseif tgt.swap_last_tagged ~= nil then
			LANG.Msg(ply, "NO_BACKSIES_" .. SWAPPER.name, nil, MSG_MSTACK_WARN)
		end
		
		return did_swap
	end
end