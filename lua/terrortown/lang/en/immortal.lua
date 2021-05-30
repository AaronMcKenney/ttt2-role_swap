local L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[IMMORTAL.name] = "Immortal"
L["info_popup_" .. IMMORTAL.name] = [[You are Immortal! You cannot win, deal damage, or die permanently. Swap roles by tagging someone else!]]
L["body_found_" .. IMMORTAL.abbr] = "They are Immortal!"
L["search_role_" .. IMMORTAL.abbr] = "This person is Immortal!"
L["target_" .. IMMORTAL.name] = "Immortal"
L["ttt2_desc_" .. IMMORTAL.name] = [[You are Immortal! You cannot win, deal damage, or die permanently. Swap roles by tagging someone else!]]

-- OTHER ROLE LANGUAGE STRINGS
L["PRESS_TO_TAG_" .. IMMORTAL.name] = "Press {k} to tag!"
L["NO_BACKSIES_" .. IMMORTAL.name] = "No backsies!"
L["SAME_" .. IMMORTAL.name] = "The swap did nothing!"

-- ROLE SWAP DEAGLE
L["RECHARGED_" .. IMMORTAL.name] = "Your Sidekick Deagle has been recharged."
L["DEAGLE_NAME_" .. IMMORTAL.name] = "RoleSwap Deagle"
L["DEAGLE_DESC_" .. IMMORTAL.name] = "Shoot a player to swap roles with them."