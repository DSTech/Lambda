AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.selection = {}
SWEP.cursel = nil

function SWEP:StartSelect(pos)
	if self.cursel then
		return
	end
	self.cursel = {startpos = pos}
end

function SWEP:EndSelect(pos,shape)
	if not self.cursel then
		return
	end
	self.cursel.shape = "radial"
	self.cursel.endpos = pos
	self.cursel.mode = ((self.Owner:KeyDown(IN_SPEED) and 2) or (self.Owner:KeyDown(IN_WALK) and 3)) or 1;
	local entlist = self:ShapeSelect(self.cursel.startpos, self.cursel.endpos, self.cursel.shape, self.cursel.mode)
	self.cursel = nil
	local count = 0
	for k,v in pairs(entlist) do
		count = count + 1
	end
	self.Owner:ChatPrint(count.." Unit"..((count==1 and " is")or"s are").." Selected.")
end

function SWEP:CancelSelect()
	self.cursel = nil
end

function SWEP:ClearSelection()
	self.selection = {}
end

function SWEP:ShapeSelect(startpos, endpos, shape, mode)
	mode = mode or 1;
	shape = shape or "radial";
	local entlist
	if(shape=="radial")then
		entlist = self:SphereSelect(startpos, endpos)
	else
		entlist = {}
	end

	self.selection = self.selection or {};
	if(mode==1)then
		self:ClearSelection()
		for k,v in pairs(entlist) do
			self.selection[v]=v;
		end
	elseif(mode==2)then
		for k,v in pairs(entlist) do
			self.selection[v]=v;
		end
	elseif(mode==3)then
		for k,v in pairs(entlist) do
			self.selection[v]=nil;
		end
	end
	return self.selection
end

function SWEP:IsCommandable(ent)
	return((string.Left(ent:GetClass(),7)=="lambda_") and self:IsOwnedEnt(ent))
end

function SWEP:IsOwnedEnt(ent)
	local ownerTeam = dTeams:getTeam(self.Owner)
	return (ownerTeam and ownerTeam == dTeams:getTeam(ent))
end

function SWEP:SphereSelect(startpos, endpos)
	local entlist = ents.FindInSphere(startpos, math.max(startpos:Distance(endpos), 1))
	local outlist = {}
	for k,v in pairs(entlist)do
		if(self:IsCommandable(v) and (v:GetClass() ~= "lambda_commander"))then
			table.insert(outlist, v)
		end
	end
	return outlist
end

function SWEP:AssignOrder(ent, command)
	ent:Order(command)
end

function SWEP:DistributeOrder(entlist, command)
	for k,v in pairs(entlist)do
		self:AssignCommand(ent, command)
	end
end
