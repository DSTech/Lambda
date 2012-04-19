include("shared.lua");
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

TeamColorTable = {
	[1]=Color(255,	0,		0,		255),
	[2]=Color(0,		0,		255,	255),
	[3]=Color(0,		255,	0,		255),
	[4]=Color(255,	255,	0,		255),
	[5]=Color(255,	0,		255,	255),
	[6]=Color(0,		255,	255,	255),
	nil
}

function ENT:SpawnFunction(ply, tr)
	if ( !tr.Hit ) then return end
 
	local SpawnPos = tr.HitPos + tr.HitNormal * 36
 
	local ent = ents.Create( "lambda_base" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self.MaxMoveSpeed = 5
	self.MaxMoveForce = 1000
	self.Gravity = true
	self.Radius = 8.25
	self.NextAttack = CurTime()
	self.TeamColor = TeamColorTable[2]
	self.MelonModel = "models/props_junk/watermelon01.mdl"
	if self.Move ~= nil && self.TargetVec == nil then
		self.TargetVec = { }
	end
	self:SetModel(self.MelonModel)
	self:PhysicsInitSphere(self.Radius)
	self:SetCollisionBounds(Vector(-self.Radius,-self.Radius,-self.Radius),Vector(self.Radius,self.Radius,self.Radius))
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetMaterial("models/debug/debugwhite");
	local physics = self.Entity:GetPhysicsObject();
	if (physics:IsValid()) then
		physics:Wake();
		physics:SetBuoyancyRatio(0.2)
		physics:EnableGravity(self.Gravity);
		physics:SetDamping(0.75,0.75)
		self.Entity:SetColor(self.TeamColor)
	end
end

function ENT:Think()
end

function ENT:OnRemove()
end
