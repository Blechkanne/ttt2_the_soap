CreateConVar("ttt_soap_velocity", "300", {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED})
CreateConVar("ttt_soap_scale", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED})
CreateConVar("ttt_soap_kick_props", "0", {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED})
CreateConVar("ttt_soap_distance", "80", {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED})

local distance = GetConVar( "ttt_soap_distance" ):GetInt() or 80
local soapscale = GetConVar( "ttt_soap_scale" ):GetFloat() or 1

SWEP.PrintName = "Soap"
SWEP.Author = "Blechkanne"
SWEP.Instructions = "Leftclick to place soap (WARNING: Slippery)"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/soap.mdl"
SWEP.WorldModel = "models/soap.mdl"
SWEP.AutoSwitchTo = true

-- TTT Customisation
if (engine.ActiveGamemode() == "terrortown") then
	SWEP.Base = "weapon_tttbase"
	SWEP.Kind = WEAPON_EQUIP1
	SWEP.AutoSpawnable = false
	SWEP.CanBuy = { ROLE_TRAITOR, ROLE_JACKAL }
	SWEP.LimitedStock = true
	SWEP.Slot = 7
	SWEP.Icon = "VGUI/icon_soap"
	SWEP.ViewModelFlip = true
	SWEP.EquipMenuData = {
		type = "item_weapon",
		name = "Soap",
		desc = [[Do not slip!
		You can pick it back up when pressing the use Button (Default: e)]]
	}
end

function SWEP:Initialize()
	self:SetHoldType("melee2")

	self.m_bInitialized = true
end

function SWEP:Think()
	if not self.m_bInitialized then
		self:Initialize()
	end
end

function SWEP:GetViewModelPosition(pos, ang)
	return pos + ang:Forward() * 12 + ang:Right() * 5 - ang:Up() * 6, ang
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() )

	if CLIENT then return end
	local model = "models/soap.mdl"
	local owner = self:GetOwner()

	local trace = util.TraceLine({
		start = owner:GetShootPos(),
		endpos = owner:GetShootPos() + owner:GetAimVector() * distance,
		filter = owner
	})

	if trace.HitWorld then
		local ent = ents.Create("ttt_soap")
		local ang = owner:LocalEyeAngles()

		ent:SetModel(model)
		ent:SetPos(trace.HitPos)
		ent:SetAngles(Angle(0, ang.y, 0))
		ent:Spawn()
		ent.Owner = owner
		ent.fingerprints = self.fingerprints
		self:Remove()
	end

	cleanup.Add( owner, "props", ent )
	undo.Create( "Soap" )
		undo.AddEntity( ent )
		undo.SetPlayer( owner )
	undo.Finish()
end

function SWEP:SecondaryAttack()
end


local material = Material("vgui/white")
local mat_color = Color(255, 0, 0, 30)

function SWEP:PostDrawViewModel()
	if not CLIENT then return end

	local player = LocalPlayer()
	local eyetrace = player:GetEyeTrace()
	local tracelength = (eyetrace.HitPos - eyetrace.StartPos):Length()
	local ang = player:LocalEyeAngles()

	if not eyetrace.HitWorld or eyetrace.HitSky or tracelength > distance then return end

	mat_color = Color(0, 255, 0, 30)
	cam.Start3D()
	render.SetMaterial(material)
	render.SetColorMaterial()
	render.DrawBox(eyetrace.HitPos,
		Angle(0, ang.y, 0),
		-Vector(5 / 2, 5 / 4, 0) * soapscale,
		Vector(5 / 2, 5 / 4, 2) * soapscale,
		mat_color
	)
	render.DrawWireframeBox(eyetrace.HitPos,
		Angle(0, ang.y, 0),
		-Vector(5 / 2, 5 / 4, 0) * soapscale,
		Vector(5 / 2, 5 / 4, 2) * soapscale,
		mat_color,
		true)
	cam.End3D()

end

if SERVER then
	resource.AddFile("materials/VGUI/icon_soap.vmt")
	resource.AddFile("materials/VGUI/icon_soap.vtf")
	resource.AddFile("sound/slip.wav")
	resource.AddFile("models/soap.dx80.vtx")
	resource.AddFile("models/soap.dx90.vtx")
	resource.AddFile("models/soap.mdl")
	resource.AddFile("models/soap.sw.vtx")
	resource.AddFile("models/soap.vvd")
	resource.AddFile("materials/models/soap.vmt")
	resource.AddFile("materials/models/soap.vtf")
end

cvars.AddChangeCallback("ttt_soap_distance", function(convar, oldValue, newValue)
	distance = tonumber(newValue)
end )

cvars.AddChangeCallback("ttt_soap_scale", function(convar, oldValue, newValue)
	soapscale = tonumber(newValue)
end )

if CLIENT then
	function SWEP:AddToSettingsMenu(parent)
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
end