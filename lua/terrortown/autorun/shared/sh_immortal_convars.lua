--ConVar syncing
CreateConVar("ttt2_immortal_damage_immunity", "0", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_immortal_seconds_until_respawn", "10", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_immortal_respawn_at_mapspawn", "0", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_immortal_tag_dist", "150", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_immortal_backsies_timer", "0", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_immortal_speed_multi", "1.2", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_immortal_stamina_regen", "1.0", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_immortal_stamina_drain", "0.35", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicImmortalCVars", function(tbl)
	tbl[ROLE_IMMORTAL] = tbl[ROLE_IMMORTAL] or {}
	
	--# Is the Immortal immune to all forms of damage?
	--  ttt2_immortal_damage_immunity [0/1] (default: 0)
	table.insert(tbl[ROLE_IMMORTAL], {
		cvar = "ttt2_immortal_damage_immunity",
		checkbox = true,
		desc = "ttt2_immortal_damage_immunity (Def: 0)"
	})
	
	--# How many seconds must pass before the immortal respawns?
	--  ttt2_immortal_seconds_until_respawn [0..n] (default: 10)
	table.insert(tbl[ROLE_IMMORTAL], {
		cvar = "ttt2_immortal_seconds_until_respawn",
		slider = true,
		min = 3,
		max = 120,
		decimal = 0,
		desc = "ttt2_immortal_seconds_until_respawn (Def: 10)"
	})
	
	--# When the immortal respawns, will they respawn at a randomly selected player spawn?
	--  Note: If disabled, the immortal will respawn where they died.
	--  ttt2_immortal_respawn_at_mapspawn [0/1] (default: 0)
	table.insert(tbl[ROLE_IMMORTAL], {
		cvar = "ttt2_immortal_respawn_at_mapspawn",
		checkbox = true,
		desc = "ttt2_immortal_respawn_at_mapspawn (Def: 0)"
	})
	
	--# What is the range on the immortal's tagging ability?
	--  ttt2_immortal_tag_dist [0..n] (default: 150)
	table.insert(tbl[ROLE_IMMORTAL], {
		cvar = "ttt2_immortal_tag_dist",
		slider = true,
		min = 0,
		max = 1000,
		decimal = 0,
		desc = "ttt2_immortal_tag_dist (Def: 150)"
	})
	
	--# How long must the immortal wait before they can tag someone who tagged them (No backsies if 0)?
	--  ttt2_immortal_backsies_timer [0..n] (default: 0)
	table.insert(tbl[ROLE_IMMORTAL], {
		cvar = "ttt2_immortal_backsies_timer",
		slider = true,
		min = 0,
		max = 60,
		decimal = 0,
		desc = "ttt2_immortal_backsies_timer (Def: 0)"
	})
	
	--# This multiplier applies directly to the immortal's speed (ex. 2.0 means they move twice as fast).
	--  ttt2_immortal_speed_multi [0.0..n.m] (default: 1.2)
	table.insert(tbl[ROLE_IMMORTAL], {
		cvar = "ttt2_immortal_speed_multi",
		slider = true,
		min = 1.0,
		max = 3.0,
		decimal = 2,
		desc = "ttt2_immortal_speed_multi (Def: 1.2)"
	})
	
	--# This multiplier applies directly to the immortal's stamina regen (ex. 2.0 means the sprint bar fills up twice the normal speed).
	--  ttt2_immortal_stamina_regen [0.0..n.m] (default: 1.0)
	table.insert(tbl[ROLE_IMMORTAL], {
		cvar = "ttt2_immortal_stamina_regen",
		slider = true,
		min = 1.0,
		max = 3.0,
		decimal = 2,
		desc = "ttt2_immortal_stamina_regen (Def: 1.0)"
	})
	
	--# This multiplier applies directly to how fast the immortal's stamina bar depletes (ex. 0.5 means the sprint bar decays at half the normal speed).
	--  ttt2_immortal_stamina_drain [0.0..n.m] (default: 0.35)
	table.insert(tbl[ROLE_IMMORTAL], {
		cvar = "ttt2_immortal_stamina_drain",
		slider = true,
		min = 0.1,
		max = 1.0,
		decimal = 2,
		desc = "ttt2_immortal_stamina_drain (Def: 0.35)"
	})
end)

hook.Add("TTT2SyncGlobals", "AddImmortalGlobals", function()
	SetGlobalBool("ttt2_immortal_damage_immunity", GetConVar("ttt2_immortal_damage_immunity"):GetBool())
	SetGlobalInt("ttt2_immortal_seconds_until_respawn", GetConVar("ttt2_immortal_seconds_until_respawn"):GetInt())
	SetGlobalBool("ttt2_immortal_respawn_at_mapspawn", GetConVar("ttt2_immortal_respawn_at_mapspawn"):GetBool())
	SetGlobalInt("ttt2_immortal_tag_dist", GetConVar("ttt2_immortal_tag_dist"):GetInt())
	SetGlobalInt("ttt2_immortal_backsies_timer", GetConVar("ttt2_immortal_backsies_timer"):GetInt())
	SetGlobalFloat("ttt2_immortal_speed_multi", GetConVar("ttt2_immortal_speed_multi"):GetFloat())
	SetGlobalFloat("ttt2_immortal_stamina_regen", GetConVar("ttt2_immortal_stamina_regen"):GetFloat())
	SetGlobalFloat("ttt2_immortal_stamina_drain", GetConVar("ttt2_immortal_stamina_drain"):GetFloat())
end)

cvars.AddChangeCallback("ttt2_immortal_damage_immunity", function(name, old, new)
	SetGlobalBool("ttt2_immortal_damage_immunity", tobool(tonumber(new)))
end)
cvars.AddChangeCallback("ttt2_immortal_seconds_until_respawn", function(name, old, new)
	SetGlobalInt("ttt2_immortal_seconds_until_respawn", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_immortal_respawn_at_mapspawn", function(name, old, new)
	SetGlobalBool("ttt2_immortal_respawn_at_mapspawn", tobool(tonumber(new)))
end)
cvars.AddChangeCallback("ttt2_immortal_tag_dist", function(name, old, new)
	SetGlobalInt("ttt2_immortal_tag_dist", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_immortal_backsies_timer", function(name, old, new)
	SetGlobalInt("ttt2_immortal_backsies_timer", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_immortal_speed_multi", function(name, old, new)
	SetGlobalFloat("ttt2_immortal_speed_multi", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_immortal_stamina_regen", function(name, old, new)
	SetGlobalFloat("ttt2_immortal_stamina_regen", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_immortal_stamina_drain", function(name, old, new)
	SetGlobalFloat("ttt2_immortal_stamina_drain", tonumber(new))
end)
