AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.selection = {}

function SWEP:SelectionChanged()
end

function SWEP:ClearSelection(notify)
	self.selection = {}
end

function SWEP:AssignOrder(ent, command)
	if(ent.Order)then ent:Order(command) end
end

function SWEP:DistributeOrder(entlist, command)
	for k,v in pairs(entlist)do
		self:AssignOrder(v, command)
	end
end

function SWEP:Order(command)
	self:DistributeOrder(self.selection, command)
end
