CLGAMEMODESUBMENU.base = "base_gamemodesubmenu"
CLGAMEMODESUBMENU.title = "soap_addon_info"

function CLGAMEMODESUBMENU:Populate(parent)
	local form = vgui.CreateTTT2Form(parent, "soap_addon_header")

	form:MakeHelp({
		label = "soap_help_menu"
	})

    form:MakeCheckBox({
		label = "label_soap_kick_props",
		serverConvar = "ttt_soap_kick_props"
	})

    form:MakeSlider({
		label = "label_soap_velocity",
		serverConvar = "ttt_soap_velocity",
		min = 0,
		max = 1000,
		decimal = 0
	})

    form:MakeSlider({
		label = "label_soap_distance",
		serverConvar = "ttt_soap_distance",
		min = 0,
		max = 200,
		decimal = 0
	})

    form:MakeSlider({
		label = "label_soap_scale",
		serverConvar = "ttt_soap_scale",
		min = 0.5,
		max = 10,
		decimal = 1
	})
end
