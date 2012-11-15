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
	self:initMovement()
end

function ENT:Think()
	if(self:mustMove())then
		self:performMovement()
	else
		self:holdPosition()
	end
	self:NextThink(CurTime()+0.03)
	return true
end

function ENT:OnRemove()
end

function ENT:Order(command)
	if(command.type == "move")then
		self:setMoveTarget(command.pos)
	end
end

local defaultMoveTable = {
	Target = nil,
	OnTarget = false,
	TargetThreshold = 20,
	MaxSpeed = 100,
	MaxForce = 450,
	UserData = nil,
	P=100,
	I=0.01,
	D=-2,
	LE = Vector(0,0,0),
	TE = Vector(0,0,0),
	DE = Vector(0,0,0)
}

function ENT:initMovement()
	self._move = {}
	for k,v in pairs(defaultMoveTable)do
		self._move[k] = v
	end
end

function ENT:setMoveTarget(pos, udata)
	local _move = self._move
	_move.UserData = udata
	_move.Target = pos
	_move.TE = Vector(0,0,0)
	_move.DE = Vector(0,0,0)
	_move.LE = Vector(0,0,0)
end

function ENT:clearMoveTarget()
	self._move.UserData = nil
	self._move.Target = nil
end

function ENT:mustMove()
	local _move = self._move
	if _move.Target == nil then return nil end
	_move.OnTarget = (_move.Target - self:GetPos()):LengthSqr() < math.pow(_move.TargetThreshold, 2)
	if(_move.OnTarget and _move.Target)then
		local oldtarg, udata = _move.Target, _move.UserData
		self:clearMoveTarget()
		if(self.Arrival)then self:Arrival(oldtarg, udata) end
	end
	return ( not _move.OnTarget )
end

function ENT:performMovement()
	local time = FrameTime()
	local _move = self._move
	local error = _move.Target - self:GetPos()
	_move.TE = _move.TE + error/time
	_move.DE = error/time - _move.LE - error:GetNormal()*_move.MaxSpeed
	_move.LE = error/time
	local force = _move.P*error + _move.I*_move.TE + _move.D*_move.DE
	force = force:GetNormal() * math.min(force:Length(), _move.MaxForce*time)
	self:GetPhysicsObject():ApplyForceCenter(force)
end

function ENT:holdPosition()
	local physobject = self:GetPhysicsObject()
	if not physobject then
		return
	end
	local curvel = physobject:GetVelocity()
	physobject:ApplyForceCenter((-curvel):GetNormal() * math.min(curvel:Length(), self._move.MaxForce*FrameTime()))
	physobject:AddAngleVelocity(-physobject:GetAngleVelocity())
end

function ENT:Arrival(pos, udata)
	print("I have arrived at "..tostring(pos).."!")
end
