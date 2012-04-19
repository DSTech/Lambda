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
	self.cursel.mode = ((self.Owner:KeyDown(IN_RUN) and 2) or (self.Owner:KeyDown(IN_WALK) and 3)) or 1;
	self.Owner:ChatPrint("Mode was: "..self.cursel.mode)	
	local entlist = self:ShapeSelect(self.cursel.startpos, self.cursel.endpos, self.cursel.shape, self.cursel.mode)
	self.cursel = nil
	self.Owner:ChatPrint("Selected "..#entlist)
end

function SWEP:CancelSelect()
	self.cursel = nil
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
		self.selection = {};
		for k,v in pairs(entlist) do
			self.selection[v]=v;
		end
	elseif(mode==2)then
		for k,v in pairs(entlist) do
			self.selection[v]=v;
		end
	else--(mode==3)
		for k,v in pairs(entlist) do
			self.selection[v]=nil;
		end
	end
	return self.selection
end

function SWEP:IsCommandable(ent)
	return((string.Left(ent:GetClass(),7)=="lambda_") and self:IsAlliedEnt(ent))
end

function SWEP:IsAlliedEnt(ent)
	return dteams.isAlly(self.Owner, ent)
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
