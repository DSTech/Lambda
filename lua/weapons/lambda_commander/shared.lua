SWEP.Author = "Team Raw Lemons"
SWEP.Contact = "Your Email Address"
SWEP.Purpose = "What your SWep does."
SWEP.Instructions = "How to operate your SWep"
 
SWEP.Category = "Lambda"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.LeftDown = false
SWEP.RightDown = false
SWEP.ReloadDown = false

function SWEP:Think()
	local leftdown,rightdown,reloaddown = self.Owner:KeyDown(IN_ATTACK),self.Owner:KeyDown(IN_ATTACK2),self.Owner:KeyDown(IN_RELOAD)
	if(leftdown and (not self.LeftDown))then
		self.LeftDown=true;
		self:StartLeftClick();
	elseif((not leftdown) and self.LeftDown)then
		self.LeftDown=false;
		self:EndLeftClick();
	end
	if(rightdown and (not self.RightDown))then
		self.RightDown=true;
		self:StartRightClick();
	elseif((not rightdown) and self.RightDown)then
		self.RightDown=false;
		self:EndRightClick();
	end
	if(reloaddown and (not self.ReloadDown))then
		self.ReloadDown=true;
		self:StartReload();
	elseif((not reloaddown) and self.ReloadDown)then
		self.ReloadDown=false;
		self:EndReload();
	end
end

function SWEP:PrimaryAttack()
	self:Think()
end

function SWEP:SecondaryAttack()
	self:Think()
end

function SWEP:Reload()
	self:Think()
end
--------------------------------------------------------

function SWEP:StartLeftClick()
	local tr = self.Owner:GetEyeTrace() if(tr.Hit)then self:StartSelect(tr.HitPos) end
end
function SWEP:EndLeftClick()
	local tr = self.Owner:GetEyeTrace() if(tr.Hit)then self:EndSelect(tr.HitPos, "radial") else self:CancelSelect() end
end

function SWEP:StartRightClick()
end
function SWEP:EndRightClick()
	local tr = self.Owner:GetEyeTrace()
	if(tr.Hit)then
		self:Order({type="move",pos=tr.HitPos})
	end
end

function SWEP:StartReload()
	self:ClearSelection(true)
end
function SWEP:EndReload()
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
		self:ClearSelection(false)
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
	self:SelectionChanged()
end

function SWEP:CancelSelect()
	self.cursel = nil
end
