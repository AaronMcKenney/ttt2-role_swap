local L = LANG.GetLanguageTableReference("zh_hans")

-- GENERAL ROLE LANGUAGE STRINGS
L[CURSED.name] = "诅咒者"
L["info_popup_" .. CURSED.name] = [[你被诅咒了!你赢不了!通过标记其他人来交换角色!

通过近距离与玩家互动或使用RoleSwap Deagle来交换角色.]]
L["body_found_" .. CURSED.abbr] = "他们是个诅咒者!"
L["search_role_" .. CURSED.abbr] = "这个人是个诅咒者!"
L["target_" .. CURSED.name] = "诅咒者"
L["ttt2_desc_" .. CURSED.name] = [[你被诅咒了!你赢不了!通过标记其他人来交换角色!

通过近距离与玩家互动或使用RoleSwap Deagle来交换角色.]]

-- OTHER ROLE LANGUAGE STRINGS
L["PRESS_TO_TAG_" .. CURSED.name] = "按{k}交换角色!"
L["NO_BACKSIES_" .. CURSED.name] = "没有后座!"
L["SAME_" .. CURSED.name] = "交换什么也没做!"
L["PROT_" .. CURSED.name] = "{name} 免受诅咒!"
L["NO_DET_" .. CURSED.name] = "你不能诅咒侦探!"
L["NO_DMG_" .. CURSED.name] = "现在不能伤害被诅咒的玩家."
L["ASSIST_WITH_IMMOLATION_" .. CURSED.name] = "按{k}自焚..."

-- ROLE SWAP DEAGLE
L["RECHARGED_" .. CURSED.name] = "您的RoleSwap Deagle已充电."
L["DEAGLE_NAME_" .. CURSED.name] = "RoleSwap Deagle"
L["DEAGLE_DESC_" .. CURSED.name] = "击中一名玩家与他们交换角色."

-- CONVAR STRINGS
--L["label_cursed_affect_det"] = "The Cursed can swap roles with Detectives"
--L["label_cursed_damage_immunity"] = "The Cursed is immune to all forms of damage"
--L["label_cursed_seconds_until_respawn"] = "Respawn time in seconds (<= 0 to disable respawn)"
--L["label_cursed_respawn_at_mapspawn"] = "Respawn at randomly selected location"
--L["label_cursed_tag_dist"] = "Range on the Cursed's tagging ability"
--L["label_cursed_backsies_timer"] = "Time until Cursed can tag their tagger (No backsies if 0)"
--L["label_cursed_no_dmg_backsies"] = "Players who were previously Cursed can't attack the new Cursed"
--L["label_cursed_self_immolate_mode"] = "Cursed's self-immolation ability"
--L["label_cursed_self_immolate_mode_0"] = "0: Cursed cannot self-immolate"
--L["label_cursed_self_immolate_mode_1"] = "1: Cursed can only set their corpse on fire"
--L["label_cursed_self_immolate_mode_2"] = "2: Cursed can self-immolate at all times"
--L["label_cursed_speed_multi"] = "Multiplier applied to the Cursed's speed"
--L["label_cursed_stamina_regen"] = "Multiplier appleid to the Cursed's stamina regeneration"
--L["label_cursed_stamina_drain"] = "Multiplier applied to the Cursed's stamina drain"
--L["label_role_swap_deagle_enable"] = "The Cursed spawns with a RoleSwap Deagle"
--L["label_role_swap_deagle_refill_time"] = "RoleSwap Deagle's cooldown (won't refill if <= 0)"
