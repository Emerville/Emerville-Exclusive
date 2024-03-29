local des_unevenwater = Class(function(self, inst)
    self.inst = inst
    self.enabled = true
    self.radius = 3
    self.detectradius = 15
    self.detectperiod = .6
    self.detecttask = nil
    if not inst:IsAsleep() then
        self:Start()
    end
end)

local function OnNotifyNearbyPlayers(inst, self, rangesq)
    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(AllPlayers) do
        if not v:HasTag("playerghost") and v:GetDistanceSqToPoint(x, y, z) < rangesq then
            v:PushEvent("des_unevenwaterdetected", { inst = inst, radius = self.radius, period = self.detectperiod })
        end
    end
end

local function OnStartTask(inst, self)
    local rangesq = self.detectradius * self.detectradius
    self.detecttask = self.inst:DoPeriodicTask(self.detectperiod, OnNotifyNearbyPlayers, self.detectperiod * (.3 + .7 * math.random()), self, rangesq)
    OnNotifyNearbyPlayers(self.inst, self, rangesq)
end

function des_unevenwater:Start()
    if self.detecttask == nil then
        self.detecttask = self.inst:DoTaskInTime(0, OnStartTask, self)
    end
end

function des_unevenwater:Stop()
    if self.detecttask ~= nil then
        self.detecttask:Cancel()
        self.detecttask = nil
    end
end

function des_unevenwater:Enable()
    if not self.enabled then
        self.enabled = true
        if not self.inst:IsAsleep() then
            self:Start()
        end
    end
end

function des_unevenwater:Disable()
    if self.enabled then
        self.enabled = false
        self:Stop()
    end
end

function des_unevenwater:OnEntityWake()
    if self.enabled then
        self:Start()
    end
end

des_unevenwater.OnEntitySleep = des_unevenwater.Stop
des_unevenwater.OnRemoveFromEntity = des_unevenwater.Stop

return des_unevenwater
