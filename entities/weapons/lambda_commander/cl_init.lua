include("shared.lua")
SWEP.PrintName = "Lambda Commander"
SWEP.Slot = 1
SWEP.SlotPos = 4

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

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
	local tr = self.Owner:GetEyeTrace()
	if(tr.Hit)then
		local cursel = {}--New selection storage
		for k,v in pairs(self.selection)do
			table.insert(cursel,v)--Copy over selection to numeric style
		end
		self:Order({type="move",pos=tr.HitPos}, cursel)--Send new copy of selection alongside the order
	end
end
function SWEP:EndRightClick()
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
	return(ent.lambda==true)
end

function SWEP:IsOwnedEnt(ent)
	local ownerTeam = dTeams:getTeam(self.Owner)
	return (ownerTeam and ownerTeam == dTeams:getTeam(ent))
end

function SWEP:SphereSelect(startpos, endpos)
	local entlist = ents.FindInSphere(startpos, math.max(startpos:Distance(endpos), 1))
	local outlist = {}
	for k,v in pairs(entlist)do
		if(self:IsCommandable(v) and self:IsOwnedEnt(v))then
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
	self.cursel.shape = shape or "radial"
	self.cursel.endpos = pos
	self.cursel.mode = ((self.Owner:KeyDown(IN_SPEED) and 2) or (self.Owner:KeyDown(IN_WALK) and 3)) or 1;
	local entlist = self:ShapeSelect(self.cursel.startpos, self.cursel.endpos, self.cursel.shape, self.cursel.mode)
	self.cursel = nil
	self:SelectionChanged()
end

function SWEP:CancelSelect()
	self.cursel = nil
end


SWEP.LaserMat = Material("cable/cable2")
SWEP.LaserColor = Color(0,0,255,255)

function SWEP:SelectionChanged()
	local count = 0
	for k,v in pairs(self.selection) do
		count = count + 1
	end
	self.Owner:ChatPrint(count.." Unit"..((count==1 and " is")or"s are").." Selected.")
end

function SWEP:ClearSelection(notify)
	if(notify)then self.Owner:ChatPrint("Selection cleared.") end
	self.selection = {}
end

function SWEP:DrawHUD()
	if(self.cursel)then
		local tr = self.Owner:GetEyeTrace() if(tr.Hit)then self:DrawSelection(self.cursel.startpos, tr.HitPos) end
	else
		self:DrawCurrentSelection()
	end
end

function SWEP:DrawSelection(startpos, endpos, shape)
	shape = shape or "radial"
	if(shape=="radial")then
		return self:DrawRadialSelection(startpos, endpos)
	end
end

local pos,material,white = Vector(0,0,0), Material( "sprites/splodesprite" ),Color(255,255,255,255)
function SWEP:DrawCurrentSelection()
end

function SWEP:DrawRadialSelection(center, edge)
	local len = center:Distance(edge)
	
	local LaserColor = self.LaserColor;--dTeams:getTeamColor(dTeams:getTeam(self.Owner));--To be added when dTeams syncs with client.
	render.SetMaterial(self.LaserMat)
	cam.Start3D(LocalPlayer():GetShootPos(), LocalPlayer():GetAngles())
	render.DrawBeam(center, edge, 2,1,1, LaserColor)
	render.DrawBeam(center, center+Vector(0,0,len), 2,1,1, LaserColor)
	render.DrawBeam(center, center+Vector(0,0,-len), 2,1,1, LaserColor)
	render.DrawBeam(center, center+Vector(0,len,0), 2,1,1, LaserColor)
	render.DrawBeam(center, center+Vector(0,-len,0), 2,1,1, LaserColor)
	render.DrawBeam(center, center+Vector(len,0,0), 2,1,1, LaserColor)
	render.DrawBeam(center, center+Vector(-len,0,0), 2,1,1, LaserColor)
	
	local numLines = 4*4
	for i=1,numLines do
		local strtdeg = (2*math.pi/numLines) * (i-1)
		local enddeg = (2*math.pi/numLines) * i
		render.DrawBeam(center+Vector(len*math.cos(strtdeg),len*math.sin(strtdeg),0), center+Vector(len*math.cos(enddeg),len*math.sin(enddeg),0), 2,1,1, LaserColor)
	end
	
	render.DrawBeam(center+Vector(0,0,edge.z-center.z),edge,2,1,1,LaserColor)
	
	render.DrawBeam(center+Vector(0,0,len), Vector(edge.x, edge.y, center.z+len),2,1,1,LaserColor)
	render.DrawBeam(Vector(edge.x, edge.y, center.z+len), edge,2,1,1,LaserColor)
	
	local tempStrps = center+Vector();
	local tempEndps = edge+Vector();
	tempStrps.z = 0;
	tempEndps.z = 0;
	render.DrawBeam(center, center+(tempEndps-tempStrps):GetNormal()*len,2,1,1,LaserColor)
	
	cam.End3D()
end

function SWEP:Order(command, units)
	if not(command and units and #units > 0)then
		return false
	end
	local cmdstring = von.serialize(command)
	local unitarr = {}
	for k,v in pairs(units)do
		if(IsValid(v))then
			table.insert(unitarr, v)
		end
	end
	net.Start("Lambda Order")
	net.WriteString(cmdstring)
	net.WriteUInt(#unitarr, 16)
	for k,v in pairs(unitarr)do
		net.WriteEntity(v)
	end
	net.SendToServer()
	return true
end
