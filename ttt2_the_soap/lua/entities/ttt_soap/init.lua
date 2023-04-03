AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

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

local velocity = GetConVar( "ttt_soap_velocity" ):GetInt() or 300
local entityscale = GetConVar( "ttt_soap_scale" ):GetFloat() or 1
local kickprops = GetConVar( "ttt_soap_kick_props" ):GetBool() or 0

function ENT:Initialize()
	self:SetModel("models/soap.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetModelScale(entityscale)
    local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		self:GetPhysicsObject():EnableMotion(false)
	end
end


function ENT:Use( activator, caller )
	if not activator:IsPlayer() then return end
	activator:Give("weapon_soap")
	self:Remove()
end

function ENT:Touch(toucher)
	if CLIENT then return end
	if not IsValid(toucher) then return end

	if toucher:IsPlayer() then
		self:EmitSound(Sound("slip.wav"))
		local velocityNormalized = toucher:GetVelocity():GetNormalized()
		local newVelocity = Vector(velocityNormalized.x, velocityNormalized.y, velocityNormalized.z + 1)
		toucher:SetVelocity(newVelocity * velocity);

	else
		if kickprops then
			self:EmitSound(Sound("slip.wav"))
			local velocityToucher = toucher:GetVelocity()
			local newVelocity = Vector(velocityToucher.x, velocityToucher.y, velocityToucher.z + 1)
			local physObj = toucher:GetPhysicsObject()

			physObj:ApplyForceCenter(newVelocity * velocity)
		end
	end
end

cvars.AddChangeCallback("ttt_soap_velocity", function(convar, oldValue, newValue)
	velocity = tonumber(newValue)
end )

cvars.AddChangeCallback("ttt_soap_scale", function(convar, oldValue, newValue)
	entityscale = tonumber(newValue)
end )

cvars.AddChangeCallback("ttt_soap_kick_props", function(convar, oldValue, newValue)
	kickprops = tobool(newValue)
end )