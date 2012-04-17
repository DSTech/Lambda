include("shared.lua")
SWEP.PrintName = "Lambda Commander"
SWEP.Slot = 1
SWEP.SlotPos = 4

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.LaserMat = Material("cable/cable2")
SWEP.LaserColor = Color(0,0,255,255)

SWEP.curSelect = nil
function SWEP:StartSelect(pos)
	self.curSelect = {
		startpos = pos
	}
end

function SWEP:EndSelect(pos,shape)
	self.curSelect = nil
end

function SWEP:CancelSelect()
	self.curSelect = nil
end

function SWEP:DrawHUD()
	if(self.curSelect)then
		local tr = self.Owner:GetEyeTrace() if(tr.Hit)then self:DrawSelection(self.curSelect.startpos, tr.HitPos) end
	end
end

function SWEP:DrawSelection(startpos, endpos, shape)
	shape = shape or "radial"
	if(shape=="radial")then
		return self:DrawRadialSelection(startpos, endpos)
	end
end

function SWEP:DrawRadialSelection(center, edge)
	local len = center:Distance(edge)
	
	local LaserColor = self.LaserColor;
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
