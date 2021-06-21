local L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[CURSED.name] = "Cursed"
L["info_popup_" .. CURSED.name] = [[YOU ARE CURSED! You cannot win! Swap roles by tagging someone else!

Swap roles by interacting with a player up close, or by shooting with the RoleSwap Deagle!]]
L["body_found_" .. CURSED.abbr] = "They are Cursed!"
L["search_role_" .. CURSED.abbr] = "This person is Cursed!"
L["target_" .. CURSED.name] = "Cursed"
L["ttt2_desc_" .. CURSED.name] = [[YOU ARE CURSED! You cannot win! Swap roles by tagging someone else!

Swap roles by interacting with a player up close, or by shooting with the RoleSwap Deagle!]]

-- OTHER ROLE LANGUAGE STRINGS
L["PRESS_TO_TAG_" .. CURSED.name] = "Press {k} to swap roles!"
L["NO_BACKSIES_" .. CURSED.name] = "No backsies!"
L["SAME_" .. CURSED.name] = "The swap did nothing!"

-- ROLE SWAP DEAGLE
L["RECHARGED_" .. CURSED.name] = "Your RoleSwap Deagle has been recharged."
L["DEAGLE_NAME_" .. CURSED.name] = "RoleSwap Deagle"
L["DEAGLE_DESC_" .. CURSED.name] = "Shoot a player to swap roles with them."