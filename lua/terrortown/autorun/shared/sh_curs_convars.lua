--ConVar syncing
CreateConVar("ttt2_cursed_damage_immunity", "0", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_cursed_seconds_until_respawn", "10", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_cursed_respawn_at_mapspawn", "0", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_cursed_tag_dist", "150", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_cursed_backsies_timer", "0", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_cursed_speed_multi", "1.2", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_cursed_stamina_regen", "1.0", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_cursed_stamina_drain", "0.35", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_role_swap_deagle_enable", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_role_swap_deagle_refill_time", "30", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicCursedCVars", function(tbl)
	tbl[ROLE_CURSED] = tbl[ROLE_CURSED] or {}
	
	--# Is the cursed immune to all forms of damage?
	--  ttt2_cursed_damage_immunity [0/1] (default: 0)
	table.insert(tbl[ROLE_CURSED], {
		cvar = "ttt2_cursed_damage_immunity",
		checkbox = true,
		desc = "ttt2_cursed_damage_immunity (Def: 0)"
	})
	
	--# How many seconds must pass before the cursed respawns (Respawning disabled if <= 0)?
	--  ttt2_cursed_seconds_until_respawn [0..n] (default: 10)
	table.insert(tbl[ROLE_CURSED], {
		cvar = "ttt2_cursed_seconds_until_respawn",
		slider = true,
		min = 0,
		max = 120,
		decimal = 0,
		desc = "ttt2_cursed_seconds_until_respawn (Def: 10)"
	})
	
	--# When the cursed respawns, will they respawn at a randomly selected player spawn?
	--  Note: If disabled, the cursed will respawn where they died.
	--  ttt2_cursed_respawn_at_mapspawn [0/1] (default: 0)
	table.insert(tbl[ROLE_CURSED], {
		cvar = "ttt2_cursed_respawn_at_mapspawn",
		checkbox = true,
		desc = "ttt2_cursed_respawn_at_mapspawn (Def: 0)"
	})
	
	--# What is the range on the cursed's tagging ability (close range role swap via interaction)?
	--  ttt2_cursed_tag_dist [0..n] (default: 150)
	table.insert(tbl[ROLE_CURSED], {
		cvar = "ttt2_cursed_tag_dist",
		slider = true,
		min = 0,
		max = 1000,
		decimal = 0,
		desc = "ttt2_cursed_tag_dist (Def: 150)"
	})
	
	--# How long must the cursed wait before they can tag someone who tagged them (No backsies if 0)?
	--  ttt2_cursed_backsies_timer [0..n] (default: 0)
	table.insert(tbl[ROLE_CURSED], {
		cvar = "ttt2_cursed_backsies_timer",
		slider = true,
		min = 0,
		max = 60,
		decimal = 0,
		desc = "ttt2_cursed_backsies_timer (Def: 0)"
	})
	
	--# This multiplier applies directly to the cursed's speed (ex. 2.0 means they move twice as fast).
	--  ttt2_cursed_speed_multi [0.0..n.m] (default: 1.2)
	table.insert(tbl[ROLE_CURSED], {
		cvar = "ttt2_cursed_speed_multi",
		slider = true,
		min = 1.0,
		max = 3.0,
		decimal = 2,
		desc = "ttt2_cursed_speed_multi (Def: 1.2)"
	})
	
	--# This multiplier applies directly to the cursed's stamina regen (ex. 2.0 means the sprint bar fills up twice the normal speed).
	--  ttt2_cursed_stamina_regen [0.0..n.m] (default: 1.0)
	table.insert(tbl[ROLE_CURSED], {
		cvar = "ttt2_cursed_stamina_regen",
		slider = true,
		min = 1.0,
		max = 3.0,
		decimal = 2,
		desc = "ttt2_cursed_stamina_regen (Def: 1.0)"
	})
	
	--# This multiplier applies directly to how fast the cursed's stamina bar depletes (ex. 0.5 means the sprint bar decays at half the normal speed).
	--  ttt2_cursed_stamina_drain [0.0..n.m] (default: 0.35)
	table.insert(tbl[ROLE_CURSED], {
		cvar = "ttt2_cursed_stamina_drain",
		slider = true,
		min = 0.1,
		max = 1.0,
		decimal = 2,
		desc = "ttt2_cursed_stamina_drain (Def: 0.35)"
	})
	
	--# Should the cursed spawn with a RoleSwap deagle, for long-range swapping?
	--  ttt2_role_swap_deagle_enable [0/1] (default: 1)
	table.insert(tbl[ROLE_CURSED], {
		cvar = "ttt2_role_swap_deagle_enable",
		checkbox = true,
		desc = "ttt2_role_swap_deagle_enable (Def: 1)"
	})
	
	--# How long does it take for the RoleSwap deagle to refill its ammo (Won't refill if <= 0)?
	--  ttt2_role_swap_deagle_refill_time [0..n] (default: 30)
	table.insert(tbl[ROLE_CURSED], {
		cvar = "ttt2_role_swap_deagle_refill_time",
		slider = true,
		min = 1,
		max = 120,
		decimal = 0,
		desc = "ttt2_role_swap_deagle_refill_time (Def: 30)"
	})
end)

hook.Add("TTT2SyncGlobals", "AddCursedGlobals", function()
	SetGlobalBool("ttt2_cursed_damage_immunity", GetConVar("ttt2_cursed_damage_immunity"):GetBool())
	SetGlobalInt("ttt2_cursed_seconds_until_respawn", GetConVar("ttt2_cursed_seconds_until_respawn"):GetInt())
	SetGlobalBool("ttt2_cursed_respawn_at_mapspawn", GetConVar("ttt2_cursed_respawn_at_mapspawn"):GetBool())
	SetGlobalInt("ttt2_cursed_tag_dist", GetConVar("ttt2_cursed_tag_dist"):GetInt())
	SetGlobalInt("ttt2_cursed_backsies_timer", GetConVar("ttt2_cursed_backsies_timer"):GetInt())
	SetGlobalFloat("ttt2_cursed_speed_multi", GetConVar("ttt2_cursed_speed_multi"):GetFloat())
	SetGlobalFloat("ttt2_cursed_stamina_regen", GetConVar("ttt2_cursed_stamina_regen"):GetFloat())
	SetGlobalFloat("ttt2_cursed_stamina_drain", GetConVar("ttt2_cursed_stamina_drain"):GetFloat())
	SetGlobalBool("ttt2_role_swap_deagle_enable", GetConVar("ttt2_role_swap_deagle_enable"):GetBool())
	SetGlobalInt("ttt2_role_swap_deagle_refill_time", GetConVar("ttt2_role_swap_deagle_refill_time"):GetInt())
end)

cvars.AddChangeCallback("ttt2_cursed_damage_immunity", function(name, old, new)
	SetGlobalBool("ttt2_cursed_damage_immunity", tobool(tonumber(new)))
end)
cvars.AddChangeCallback("ttt2_cursed_seconds_until_respawn", function(name, old, new)
	SetGlobalInt("ttt2_cursed_seconds_until_respawn", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_cursed_respawn_at_mapspawn", function(name, old, new)
	SetGlobalBool("ttt2_cursed_respawn_at_mapspawn", tobool(tonumber(new)))
end)
cvars.AddChangeCallback("ttt2_cursed_tag_dist", function(name, old, new)
	SetGlobalInt("ttt2_cursed_tag_dist", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_cursed_backsies_timer", function(name, old, new)
	SetGlobalInt("ttt2_cursed_backsies_timer", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_cursed_speed_multi", function(name, old, new)
	SetGlobalFloat("ttt2_cursed_speed_multi", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_cursed_stamina_regen", function(name, old, new)
	SetGlobalFloat("ttt2_cursed_stamina_regen", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_cursed_stamina_drain", function(name, old, new)
	SetGlobalFloat("ttt2_cursed_stamina_drain", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_role_swap_deagle_enable", function(name, old, new)
	SetGlobalBool("ttt2_role_swap_deagle_enable", tobool(tonumber(new)))
end)
cvars.AddChangeCallback("ttt2_role_swap_deagle_refill_time", function(name, old, new)
	SetGlobalInt("ttt2_role_swap_deagle_refill_time", tonumber(new))
end)
