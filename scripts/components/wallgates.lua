local function opened(self, isopen)
    if isopen then
        self.inst:AddTag("opened")
    else
        self.inst:RemoveTag("opened")
    end
end

local WallGates = Class(function(self, inst)
	self.inst = inst
	self.openwallfn = nil
	self.closewallfn = nil
	self.isopen = false
	self.caninteractfn = nil
	
end,
nil,
{
    isopen = opened,
})

function WallGates:OnSave()
	local data = {}	
	data.isopen = self.isopen
	return data
end

function WallGates:OnLoad(data)
	if data then
		self.isopen = data.isopen
		if self:IsOpen() then self:OpenWall() else self:CloseWall() end
	end
end

function WallGates:OpenWall()
	if self.openwallfn then
		self.openwallfn(self.inst)
	end
	self.isopen = true
end

function WallGates:CanInteract()
	if self.inst:HasTag("broken") then
		return false
	else 
		return true
	end
end

function WallGates:CloseWall()
	if self.closewallfn then
		self.closewallfn(self.inst)
	end
	self.isopen = false
end

function WallGates:IsOpen()
	return self.isopen
end

return WallGates