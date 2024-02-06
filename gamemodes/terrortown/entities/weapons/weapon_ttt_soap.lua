if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgui/ttt/icon_melonmine.png")

    util.PrecacheSound("soap/slip.wav")
end

SWEP.HoldType = "melee2"

if CLIENT then
    SWEP.PrintName = "Soap"
    SWEP.Slot = 7

    SWEP.ViewModelFOV = 70
    SWEP.ViewModelFlip = false

    SWEP.UseHands = true
    SWEP.ShowDefaultViewModel = false
    SWEP.ShowDefaultWorldModel = false

    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = [[Do not slip!
		You can pick it back up when pressing the use Button (Default: e)]],
    }

    SWEP.Icon = "vgui/ttt/icon_melonmine.png"
end

SWEP.Base = "weapon_tttbase"

SWEP.Author = "Blechkanne"

SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Primary.Delay = 0.9
SWEP.Primary.Damage = 7
SWEP.Primary.NumShots = 1
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:GetViewModelPosition(pos, ang)
    return pos + ang:Forward() * 12 + ang:Right() * 5 - ang:Up() * 6, ang
end

function SWEP:PrimaryAttack()
    if SERVER and self:CanPrimaryAttack() then
        local soap = ents.Create("ttt_soap")

        if soap:StickEntity(self:GetOwner(), Angle(90, 0, 0)) then
            self:Remove()
        end
    end
end

function SWEP:SecondaryAttack() end

if CLIENT then
    ---
    -- @realm client
    function SWEP:OnRemove()
        local owner = self:GetOwner()

        if IsValid(owner) and owner == LocalPlayer() and owner:IsTerror() then
            RunConsoleCommand("lastinv")
        end
    end

    function SWEP:AddToSettingsMenu(parent)
        local form = vgui.CreateTTT2Form(parent, "soap_addon_header")

        form:MakeHelp({
            label = "soap_help_menu",
        })

        form:MakeCheckBox({
            label = "label_soap_kick_props",
            serverConvar = "ttt_soap_kick_props",
        })

        form:MakeSlider({
            label = "label_soap_velocity",
            serverConvar = "ttt_soap_velocity",
            min = 0,
            max = 1000,
            decimal = 0,
        })
    end
end
