local ReincarnationMemory = Class(function(self, inst)
    assert(TheWorld.ismastersim, "ReincarnationMemory should not exist on client")
    assert(TheWorld.ismastershard, "ReincarnationMemory should not exist on slave shards")

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

return ReincarnationMemory
