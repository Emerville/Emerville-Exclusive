return
{
	 {
        name = "blue_singlefirework",
        bank = "firework",
        build = "blue_fireworks",
        anim = "single_firework",
		lightoverride = true,
        sound = "dontstarve/common/shrine/sadwork_fire",
        sound2 = "dontstarve/common/shrine/sadwork_explo",
        sounddelay2 = 26/30,
        fn = function() TheWorld:PushEvent("screenflash", .65) end,
        fntime = 26/30,
		bloom = true,
    },
    {
        name = "blue_multifirework",
        bank = "firework",
        build = "blue_fireworks",
        anim = "multi_firework",
		lightoverride = true,
        sound = "dontstarve/common/shrine/sadwork_fire",
        sound2 = "dontstarve/common/shrine/firework_explo",
        sounddelay2 = 26/30,
        fn = function() TheWorld:PushEvent("screenflash", 1) end,
        fntime = 26/30,
		bloom = true,
    },
	{
        name = "red_singlefirework",
        bank = "firework",
        build = "red_fireworks",
        anim = "single_firework",
		lightoverride = true,
        sound = "dontstarve/common/shrine/sadwork_fire",
        sound2 = "dontstarve/common/shrine/sadwork_explo",
        sounddelay2 = 26/30,
        fn = function() TheWorld:PushEvent("screenflash", .65) end,
        fntime = 26/30,
		bloom = true,
    },
    {
        name = "red_multifirework",
        bank = "firework",
        build = "red_fireworks",
        anim = "multi_firework",
		lightoverride = true,
        sound = "dontstarve/common/shrine/sadwork_fire",
        sound2 = "dontstarve/common/shrine/firework_explo",
        sounddelay2 = 26/30,
        fn = function() TheWorld:PushEvent("screenflash", 1) end,
        fntime = 26/30,
		bloom = true,
    },
	{
        name = "purple_singlefirework",
        bank = "firework",
        build = "purple_fireworks",
        anim = "single_firework",
		lightoverride = true,
        sound = "dontstarve/common/shrine/sadwork_fire",
        sound2 = "dontstarve/common/shrine/sadwork_explo",
        sounddelay2 = 26/30,
        fn = function() TheWorld:PushEvent("screenflash", .65) end,
        fntime = 26/30,
		bloom = true,
    },
    {
        name = "purple_multifirework",
        bank = "firework",
        build = "purple_fireworks",
        anim = "multi_firework",
		lightoverride = true,
        sound = "dontstarve/common/shrine/sadwork_fire",
        sound2 = "dontstarve/common/shrine/firework_explo",
        sounddelay2 = 26/30,
        fn = function() TheWorld:PushEvent("screenflash", 1) end,
        fntime = 26/30,
		bloom = true,
    },
}