include("shared.lua");
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

function ENT:SpawnFunction(ply, tr)
	if ( !tr.Hit ) then return end
 
	local SpawnPos = tr.HitPos + tr.HitNormal * 36
 
	local teamToSpawnOn = dTeams:getTeam(ply)
	if not(teamToSpawnOn)then
		ply:ChatPrint("Please choose a team before spawning Lambda Entities.")
		return
	end
	local ent = ents.Create( "lambda_base" )
	ent:SetPos( SpawnPos )
	dTeams:setTeam(ent, teamToSpawnOn)
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
	self.TeamColor = dTeams:getTeamColor(self)
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
