AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:StartSelect(pos)
end

function SWEP:EndSelect(pos,shape)
end

function SWEP:CancelSelect()
end

function SWEP:GenericSelect(startpos, endpos, shape, mode)
	mode = mode or 1;
	local entlist
	if(shape=="radial")then
		entlist = self:SphereSelect(startpos, endpos)
	else
		entlist = {}
	end

	for k,v in pairs(entlist) do
		if(string.Left(v:GetClass(), 6)~="three_")then
			entlist[k]=nil;
		end
	end

	self.selection = {} or self.selection;
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

function SWEP:SphereSelect(startpos, endpos)
end
