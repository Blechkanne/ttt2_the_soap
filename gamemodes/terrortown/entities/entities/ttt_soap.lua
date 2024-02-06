if SERVER then
    AddCSLuaFile()
end

ENT.Base = "ttt_base_placeable"

if CLIENT then
    ENT.PrintName = "Seife"
    ENT.Icon = "vgui/ttt/icon_soap"
end

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.CanUseKey = true
ENT.pickupWeaponClass = "weapon_ttt_soap"

if SERVER then
    local cvKickProps = CreateConVar("ttt_soap_kick_props", "0", { FCVAR_NOTIFY, FCVAR_ARCHIVE })
    local cvVelocity = CreateConVar("ttt_soap_velocity", "300", { FCVAR_NOTIFY, FCVAR_ARCHIVE })

    local soundSlip = Sound("soap/slip.wav")

    function ENT:Initialize()
        self:SetModel("models/soap.mdl")

        self.BaseClass.Initialize(self)

        -- enables ENT:Touch
        self:SetSolidFlags(FSOLID_TRIGGER)

        self:SetHealth(100)
    end

    function ENT:PlayerCanPickupWeapon(activator)
        return self:GetOriginator():GetTeam() == activator:GetTeam()
    end

    function ENT:Touch(toucher)
        if not IsValid(toucher) then
            return
        end

        if toucher:IsPlayer() then
            self:EmitSound(soundSlip)

            local velocityNormalized = toucher:GetVelocity():GetNormalized()
            local newVelocity =
                Vector(velocityNormalized.x, velocityNormalized.y, velocityNormalized.z + 1)
            toucher:SetVelocity(newVelocity * cvVelocity:GetInt())
        elseif cvKickProps:GetBool() then
            self:EmitSound(soundSlip)

            local velocityToucher = toucher:GetVelocity()
            local newVelocity = Vector(velocityToucher.x, velocityToucher.y, velocityToucher.z + 1)
            local physObj = toucher:GetPhysicsObject()

            physObj:ApplyForceCenter(newVelocity * cvVelocity:GetInt())
        end
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
        self:CreateShadow()
    end
end
