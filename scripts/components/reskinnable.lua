local Reskinnable = Class(function(self, inst)
    self.inst = inst
    self.name = nil
end)

function Reskinnable:SetReskin(name)
    local reskin = name or self.inst.prefab

    self.inst.AnimState:SetBank(reskin)
    self.inst.AnimState:SetBuild(reskin)

    self.name = name
end

function Reskinnable:GetReskin()
    return self.name
end

function Reskinnable:OnSave()
    local data = {}

    if self.name ~= nil then
        data.name = self.name
    end

    return data
end

function Reskinnable:OnLoad(data)
    if data ~= nil then
        self:SetReskin(data.name)
    end
end

return Reskinnable
