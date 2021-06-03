local L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[SWAPPER.name] = "Swapper"
L["info_popup_" .. SWAPPER.name] = [[You are a Swapper! You cannot win, deal damage, or die permanently. Swap roles by tagging someone else!]]
L["body_found_" .. SWAPPER.abbr] = "They were a Swapper!"
L["search_role_" .. SWAPPER.abbr] = "This person was a Swapper!"
L["target_" .. SWAPPER.name] = "Swapper"
L["ttt2_desc_" .. SWAPPER.name] = [[You are a Swapper! You cannot win, deal damage, or die permanently. Swap roles by tagging someone else!]]

-- OTHER ROLE LANGUAGE STRINGS
L["PRESS_TO_TAG_" .. SWAPPER.name] = "Press {k} to tag!"
L["NO_BACKSIES_" .. SWAPPER.name] = "No backsies!"
L["SAME_" .. SWAPPER.name] = "The swap did nothing!"

-- ROLE SWAP DEAGLE
L["RECHARGED_" .. SWAPPER.name] = "Your Sidekick Deagle has been recharged."
L["DEAGLE_NAME_" .. SWAPPER.name] = "RoleSwap Deagle"
L["DEAGLE_DESC_" .. SWAPPER.name] = "Shoot a player to swap roles with them."