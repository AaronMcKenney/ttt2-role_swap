--ConVar syncing
CreateConVar("ttt2_immortal_seconds_until_respawn", "60", {FCVAR_ARCHIVE, FCVAR_NOTFIY})

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicImmortalCVars", function(tbl)
	tbl[ROLE_IMMORTAL] = tbl[ROLE_IMMORTAL] or {}
	
	--# How many seconds must pass before the immortal respawns?
	--  ttt2_immortal_seconds_until_respawn [0..n] (default: 60)
	table.insert(tbl[ROLE_IMMORTAL], {
		cvar = "ttt2_immortal_seconds_until_respawn",
		slider = true,
		min = 3,
		max = 300,
		decimal = 0,
		desc = "ttt2_immortal_seconds_until_respawn (Def: 1)"
	})
end)

hook.Add("TTT2SyncGlobals", "AddImmortalGlobals", function()
	SetGlobalInt("ttt2_immortal_seconds_until_respawn", GetConVar("ttt2_immortal_seconds_until_respawn"):GetInt())
end)

cvars.AddChangeCallback("ttt2_immortal_seconds_until_respawn", function(name, old, new)
	SetGlobalInt("ttt2_immortal_seconds_until_respawn", tonumber(new))
end)
