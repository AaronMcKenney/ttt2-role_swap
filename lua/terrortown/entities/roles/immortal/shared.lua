if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_imm.vmt")
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
	self.preventWin = true --Cannot win unless the immortal switches roles
	
	self.conVarData = {
		pct = 0.13,
		maximum = 1,
		minPlayers = 8,
		random = 10,
		minKarma = 800, --Don't give RDM-ers access to this most nihilistic of roles.
		traitorButton = 0,
		
		--Materialistic pleasures have no meaning to the immortal
		credits = 0,
		creditsTraitorKill = 0,
		creditsTraitorDead = 0,
		shopFallback = SHOP_DISABLED,
		
		togglable = true
	}
end

if SERVER then
	hook.Add("TTT2PostPlayerDeath", "TTT2PostPlayerDeathHookForImmortal", function(ply)
		if ply:GetSubRole() == ROLE_IMMORTAL then
			ply:Revive(GetConVar("ttt2_immortal_seconds_until_respawn"):GetInt(),
				nil, --OnRevive function
				nil --DoCheck function
			)
		end
	end)
end
