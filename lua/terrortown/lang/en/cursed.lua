local L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[CURSED.name] = "Cursed"
L["info_popup_" .. CURSED.name] = [[YOU ARE CURSED! You cannot win! Swap roles by tagging someone else!

Swap roles by interacting with a player up close, or by shooting them with the RoleSwap Deagle.]]
L["body_found_" .. CURSED.abbr] = "They are Cursed!"
L["search_role_" .. CURSED.abbr] = "This person is Cursed!"
L["target_" .. CURSED.name] = "Cursed"
L["ttt2_desc_" .. CURSED.name] = [[YOU ARE CURSED! You cannot win! Swap roles by tagging someone else!

Swap roles by interacting with a player up close, or by shooting them with the RoleSwap Deagle.]]

-- OTHER ROLE LANGUAGE STRINGS
L["PRESS_TO_TAG_" .. CURSED.name] = "Press {k} to swap roles!"
L["NO_BACKSIES_" .. CURSED.name] = "No backsies!"
L["SAME_" .. CURSED.name] = "The swap did nothing!"
L["PROT_" .. CURSED.name] = "{name} is protected from curses!"
L["NO_DET_" .. CURSED.name] = "You can't curse Detectives!"
L["NO_DMG_" .. CURSED.name] = "Can't damage Cursed players right now."
L["ASSIST_WITH_IMMOLATION_" .. CURSED.name] = "Press {k} to self-immolate..."

-- ROLE SWAP DEAGLE
L["RECHARGED_" .. CURSED.name] = "Your RoleSwap Deagle has been recharged."
L["DEAGLE_NAME_" .. CURSED.name] = "RoleSwap Deagle"
L["DEAGLE_DESC_" .. CURSED.name] = "Shoot a player to swap roles with them."

-- CONVAR STRINGS
L["label_cursed_affect_det"] = "The Cursed can swap roles with Detectives"
L["label_cursed_damage_immunity"] = "The Cursed is immune to all forms of damage"
L["label_cursed_seconds_until_respawn"] = "Respawn time in seconds (<= 0 to disable respawn)"
L["label_cursed_respawn_at_mapspawn"] = "Respawn at randomly selected location"
L["label_cursed_tag_dist"] = "Range on the Cursed's tagging ability"
L["label_cursed_backsies_timer"] = "Time until Cursed can tag their tagger (No backsies if 0)"
L["label_cursed_no_dmg_backsies"] = "Players who were previously Cursed can't attack the new Cursed"
L["label_cursed_self_immolate_mode"] = "Cursed's self-immolation ability"
L["label_cursed_self_immolate_mode_0"] = "0: Cursed cannot self-immolate"
L["label_cursed_self_immolate_mode_1"] = "1: Cursed can only set their corpse on fire"
L["label_cursed_self_immolate_mode_2"] = "2: Cursed can self-immolate at all times"
L["label_cursed_speed_multi"] = "Multiplier applied to the Cursed's speed"
L["label_cursed_stamina_regen"] = "Multiplier appleid to the Cursed's stamina regeneration"
L["label_cursed_stamina_drain"] = "Multiplier applied to the Cursed's stamina drain"
L["label_role_swap_deagle_enable"] = "The Cursed spawns with a RoleSwap Deagle"
L["label_role_swap_deagle_refill_time"] = "RoleSwap Deagle's cooldown (won't refill if <= 0)"
