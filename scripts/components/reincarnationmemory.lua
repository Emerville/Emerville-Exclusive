local ReincarnationMemory = Class(function(self, inst)
    assert(TheWorld.ismastersim, "ReincarnationMemory should not exist on client")
    assert(TheWorld.ismastershard, "ReincarnationMemory should not exist on slave shards")

    self.inst = inst

    self.memory = {}

    inst:ListenForEvent("ms_playerdespawnanddelete",
                        function (inst, player)
                            self:StorePlayer(player)
                        end,
                        TheWorld)
    -- Untested; this could be used instead of replacing OnNewSpawn in
    -- modmain.lua with the drawback of losing functionality in every
    -- non-fixed spawning game mode. See SpawnAtLocation() in
    -- components/playerspawner.lua.
    --~ inst:ListenForEvent("ms_newplayercharacterspawned",
    --~                     function (inst, data)
    --~                         self:RestorePlayer(data.player)
    --~                     end,
    --~                     TheWorld)
    -- Untested; this will restore memory for every spawn, causing unwanted
    -- behaviour when the memory is inconsistent.
    --~ inst:ListenForEvent("ms_playerspawn",
    --~                     function (inst, player)
    --~                         self:RestorePlayer(player)
    --~                     end,
    --~                     TheWorld)
end)

function ReincarnationMemory:Set(key, value)
    self.memory[key] = value
end

function ReincarnationMemory:Get(key)
    return self.memory[key]
end

function ReincarnationMemory:Delete(key)
    self.memory[key] = nil
end

function ReincarnationMemory:StorePlayer(inst)
    local position = {inst.Transform:GetWorldPosition()}
    local age = nil
    local builder_data = nil
    local inventory_data = nil
    local maps = nil
--    local petleash = nil

    if inst.components.age ~= nil then
        age = inst.components.age:OnSave()
    end

    if inst.components.builder ~= nil then
        builder_data = inst.components.builder:OnSave()
    end

    if inst.components.inventory ~= nil then
        inventory_data = inst.components.inventory:OnSave()
    end

    if inst.player_classified ~= nil and
       inst.player_classified.MapExplorer ~= nil and
       inst.player_classified.MapExplorer.RecordAllMaps ~= nil then
        maps = inst.player_classified.MapExplorer:RecordAllMaps()
    end

--    if inst.components.petleash ~= nil then
--        petleash = inst.components.petleash:OnSave()
--    end

    self:Set(inst.userid,
             {
                 position = position,
                 age = age,
                 builder_data = builder_data,
                 inventory_data = inventory_data,
                 maps = maps,
--                 petleash = petleash,
             })
end

function ReincarnationMemory:GetPlayer(inst)
    return self:Get(inst.userid)
end

function ReincarnationMemory:RestorePlayer(inst)
    local player_memory = self:GetPlayer(inst)

    if player_memory ~= nil then
        local position = player_memory.position
        local age = player_memory.age
        local builder_data = player_memory.builder_data
        local inventory_data = player_memory.inventory_data
        local maps = player_memory.maps
 --       local petleash = player_memory.petleash

        if position ~= nil then
            inst:DoTaskInTime(0,
                              function(inst)
                                  local unpack = unpack or table.unpack
                                  local x, y, z = unpack(position)
                                  if x == nil or y == nil or z == nil then
                                      return
                                  end
                                  inst.Physics:Teleport(x, y, z)

                                  -- Spawn a light if it's dark
                                  if not TheWorld.state.isday and
                                     #TheSim:FindEntities(x, y, z, 4,
                                                          {"spawnlight"}) <= 0 then
                                      local light = SpawnPrefab("spawnlight_multiplayer")
                                      if light ~= nil then
                                          light.Transform:SetPosition(x, y, z)
                                      end
                                  end
                              end)
        end
        if age ~= nil and
           inst.components.age ~= nil then
            inst.components.age:OnLoad(age)
        end
        if builder_data ~= nil and
           inst.components.builder ~= nil then
            inst.components.builder:OnLoad(builder_data)
        end
        if inventory_data ~= nil and
           inst.components.inventory ~= nil then
            -- This has to be delayed until the player is at his actual
            -- position, otherwise items that can't be hold will be spawned
            -- at (0,0,0) or at the portal.
            inst:DoTaskInTime(0.1,
                              function(inst)
                                  inst.components.inventory:OnLoad(inventory_data)
                              end)
        end
        if maps ~= nil then
            -- Queueing without delay seems to lead to a race condition,
            -- let's hope 0.5 seconds is enough to avoid it.
            inst:DoTaskInTime(0.5,
                              function(inst)
                                  if inst.player_classified ~= nil and
                                     inst.player_classified.MapExplorer ~= nil and
                                     inst.player_classified.MapExplorer.LearnAllMaps ~= nil then
                                      inst.player_classified.MapExplorer:LearnAllMaps(maps)
                                  end
                              end)
        end
 ---       if petleash ~= nil and
--           inst.components.petleash ~= nil then
--            inst.components.petleash:OnLoad(petleash)
 --       end

        self:ForgetPlayer(inst)
    end
end

function ReincarnationMemory:ForgetPlayer(inst)
    return self:Delete(inst.userid)
end

function ReincarnationMemory:OnSave()
    return {
               memory = self.memory,
           }
end

function ReincarnationMemory:OnLoad(data)
    if data ~= nil and data.memory ~= nil then
        self.memory = data.memory
    end
end

function ReincarnationMemory:GetDebugString()
    local s = "Reincarnation memory for:\n"
    for key, value in pairs(self.memory) do
        s = s.." - "..tostring(key)..": "..json.encode(value).."\n"
    end
    return s
end

return ReincarnationMemory
