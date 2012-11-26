include("shared.lua");
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

ENT.MaxMoveSpeed = 5
ENT.MaxMoveForce = 1000
ENT.Gravity = true
ENT.Radius = 8.25
ENT.Mass = nil
ENT.MelonModel = "models/props_junk/watermelon01.mdl"

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
	self.curtime = CurTime()
	self.lasttime = self.curtime - (self.Delay or 0.25)
	self.NextAttack = self.curtime
	if(self.color == "TeamColor")then--Replace the flag with the color of the team
		self.color = dTeams:getTeamColor(self)
	elseif(type(self.color) == "function")then--Assuming color is a function of TeamColor
		self.color = self.color(dTeams:getTeamColor(self))
	end

	self:SetModel(self.MelonModel)
	self:PhysicsInitSphere(self.Radius)
	self:SetCollisionBounds(Vector(-self.Radius,-self.Radius,-self.Radius),Vector(self.Radius,self.Radius,self.Radius))
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMaterial("models/debug/debugwhite")
	local physics = self.Entity:GetPhysicsObject()
	if(physics:IsValid())then
		physics:Wake()
		physics:SetBuoyancyRatio(0.2)
		physics:EnableGravity(self.Gravity)
		physics:SetDamping(0.75,0.75)
		self.Entity:SetColor(self.color)
		if(self.Mass)then
			physics:SetMass(self.Mass)
		end
	end
	self:initOrders()
	self:initMovement()
end

function ENT:Think()
	self.curtime = CurTime()
	self.deltaTime = self.curtime - self.lasttime
	self:performMovement()
	self:NextThink(self.curtime+(self.Delay or 0.25))
	self.lasttime = self.curtime
	return true
end

function ENT:OnRemove()
	self.move = nil
	self.orders = nil
end

function ENT:initOrders()
	self.activeOrder = false
	self.orders = {}
end

function ENT:order(order)
	if(order.queue)then
		table.insert(self.orders, order)
		if not(self.activeOrder)then
			self:fetchOrder()--Begin new order
		end
	else
		self.orders = {}
		self:clearMoveTarget()
		table.insert(self.orders, order)
		self:fetchOrder()--Begin new order
	end
end

function ENT:fetchOrder()
	if(#self.orders == 0)then
		return
	end
	local order = table.remove(self.orders, 1)
	if(order.type == "move")then
		if(order.patrol)then
			local pos = order.pos
			self:setMoveTarget(order.pos, function(self)
				self:clearMoveTarget()
				self:order({type="move", patrol=true, queue=true, pos=pos})
				self.activeOrder = false
				return self:fetchOrder()
			end)
			self.activeOrder = true
		else
			self:setMoveTarget(order.pos, function(self)
				self:clearMoveTarget()
				self.activeOrder = false
				return self:fetchOrder()
			end)
			self.activeOrder = true
		end
	end
end

local defaultMoveTable = {
	Target = nil;
	OnTarget = false;
	TargetThreshold = 25;
	MaxForce = 450;
}

function ENT:initMovement()
	self.move = {}
	for k,v in pairs(defaultMoveTable)do
		self.move[k] = v
	end
end

function ENT:setMoveTarget(pos, callback)
	local move = self.move
	move.Callback = callback
	move.Target = pos
end

function ENT:clearMoveTarget()
	self.move.Callback = nil
	self.move.Target = nil
end

function ENT:mustMove()
	local move = self.move
	if move.Target == nil then return nil end
	move.OnTarget = (move.Target - self:GetPos()):LengthSqr() < math.pow(move.TargetThreshold, 2)
	if(move.OnTarget and move.Target)then
		local oldtarg, Callback = move.Target, move.Callback
		self:clearMoveTarget()
		if(self.Arrival)then self:Arrival(oldtarg, Callback) end
	end
	return ( not move.OnTarget )
end

function ENT:performMovement()
	if(self:mustMove())then
		local move = self.move
		local deltaTime = self.deltaTime
		local force
		if(isvector(move.Target))then
			force = move.Target - self:GetPos()
		elseif(isentity(move.Target))then
			force = move.Target:GetPos() - self:GetPos()
		else
			return
		end
		force = force:GetNormal() * self.move.MaxForce * self.deltaTime
		local physobject = self:GetPhysicsObject()
		physobject:ApplyForceCenter(force)
		physobject:SetDamping(2, 0)
	else
		self:holdPosition()
	end
end

function ENT:holdPosition()
	local physobject = self:GetPhysicsObject()
	if not physobject then
		return
	end
	local curvel = physobject:GetVelocity()
	self.Entity:SetVelocity(self.Entity:GetVelocity() * 0.05)
	--physobject:ApplyForceCenter((-curvel):GetNormal() * math.min((curvel * physobject:GetMass()):Length(), self.move.MaxForce*self.deltaTime))
	--physobject:AddAngleVelocity(-physobject:GetAngleVelocity())
	physobject:SetDamping(2, 2)
end

function ENT:Arrival(pos, callback)
	return callback(self, pos)
end
