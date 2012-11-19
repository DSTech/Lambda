AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:PrimaryAttack()
	self:Think()
end

function SWEP:SecondaryAttack()
	self:Think()
end

function SWEP:Reload()
	self:Think()
end

function SWEP:Think()
end
