SWEP.Author = "Team Raw Lemons"
SWEP.Contact = "Your Email Address"
SWEP.Purpose = "What your SWep does."
SWEP.Instructions = "How to operate your SWep"
 
SWEP.Category = "Lambda"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.LeftDown = false
SWEP.RightDown = false

function SWEP:Think()
	local leftdown,rightdown = self.Owner:KeyDown(IN_ATTACK),self.Owner:KeyDown(IN_ATTACK2)
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
end

function SWEP:PrimaryAttack()
	self:Think()
end

function SWEP:SecondaryAttack()
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
end
