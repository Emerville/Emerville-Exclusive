local function opened_l(self, isopen)
    if isopen then
        self.inst:AddTag("opened")
    else
        self.inst:RemoveTag("opened")
    end
end

local LockedWallGates = Class(function(self, inst)
	self.inst = inst
	self.openwallfn = nil
	self.closewallfn = nil
	self.isopen = false
	self.owner = nil
end,
nil,
{
    isopen = opened_l,
})

function LockedWallGates:OnSave()
	local data = {}	
	data.isopen = self.isopen
	data.owner = self.owner
	return data
end

function LockedWallGates:OnLoad(data)
	if data then
		self.isopen = data.isopen
		if self:IsOpen() then self:OpenWall() else self:CloseWall() end
		self.owner = data.owner
		if self.owner then
		self:Tag(self.owner)
		end
	end
end

function LockedWallGates:Tag(tag)
self.inst:AddTag(tag)
end

function LockedWallGates:AddOwner(owner)
self.owner = owner
end

function LockedWallGates:OpenWall()
	if self.openwallfn then
		self.openwallfn(self.inst)
	end
	self.isopen = true
end

function LockedWallGates:CanInteract()
	if self.inst:HasTag("broken") then
		return false
	else 
		return true
	end
end
function LockedWallGates:CloseWall()
	if self.closewallfn then
		self.closewallfn(self.inst)
	end
	self.isopen = false
end

function LockedWallGates:IsOpen()
	return self.isopen
end

return LockedWallGates