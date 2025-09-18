log.info("Successfully loaded " .. _ENV["!guid"] .. ".")
mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto(true)
mods.on_all_mods_loaded(function()
    for k, v in pairs(mods) do
        if type(v) == "table" and v.tomlfuncs then
            Toml = v
        end
    end
    params = {
        DropChance = 500,
        EnabledAspects = {
            artifactBoss = true,
            blazing = true,
            blighted = true,
            frenzied = true,
            leeching = true,
            overloading = true,
            volatile = true
        }
    }
    params = Toml.config_update(_ENV["!guid"], params) -- Load Save
end)
PATH = _ENV["!plugins_mod_folder_path"] .. "/Assets/"

Initialize(function()
    local Elites = Global.class_elite
    local RecordPickups = false
    local RecordedPickups = {}

    for i, elite in ipairs(Elites) do
        local Aspect = Equipment.new("OnyxEliteAspects", elite[2], true)
        local AspectName = string.sub(Language.translate_token(elite[3]), 1, -4)
        Aspect:toggle_loot(false)
        Aspect.token_name = AspectName .. " Aspect"
        Aspect.token_text = "Become a " .. AspectName .. " aspect"
        if elite[2] == "blazing" then
            Aspect:set_sprite(Resources.sprite_load("Onyx", "blazingAspect", PATH .. "petroleumHeart.png", 2, 16, 16))
            Aspect.token_name = "Petroleu mHeart"
        elseif elite[2] == "frenzied" then
            Aspect:set_sprite(Resources.sprite_load("Onyx", "frenziedAspect", PATH .. "quantumTransmitter.png", 2, 16, 16))
            Aspect.token_name = "Quantum Transmitter"
        elseif elite[2] == "blighted" then
            Aspect:set_sprite(Resources.sprite_load("Onyx", "blightedAspect", PATH .. "blackenedFragment.png", 2, 16, 16))
            Aspect.token_name = "Blackened Fragment"
        elseif elite[2] == "poison" then
            Aspect:set_sprite(Resources.sprite_load("Onyx", "poisonAspect", PATH .. "rancidOyster.png", 2, 16, 16))
            Aspect.token_name = "Rancid Oyster"
        elseif elite[2] == "volatile" then
            Aspect:set_sprite(Resources.sprite_load("Onyx", "volatileAspect", PATH .. "eyeOfSpite.png", 2, 16, 16))
            Aspect.token_name = "Eye of Spite"
        elseif elite[2] == "leeching" then
            Aspect:set_sprite(Resources.sprite_load("Onyx", "leechingAspect", PATH .. "parasiticGrowth.png", 2, 16, 16))
            Aspect.token_name = "Parasitic Growth"
        elseif elite[2] == "overloading" then
            Aspect:set_sprite(Resources.sprite_load("Onyx", "overloadingAspect", PATH .. "runeMagnet.png", 2, 16, 16))
            Aspect.token_name = "Rune Magnet"
        else
            Aspect:set_sprite(elite[6])
        end
        Aspect:set_passive(true)
        Aspect:set_loot_tags(Item.LOOT_TAG.equipment_blacklist_enigma, Item.LOOT_TAG.equipment_blacklist_activator)

        if i == 3 or i == 7 then
            Aspect:set_passive(false)
            Aspect:set_cooldown(10)
        end
        Aspect:add_callback("onPickup", function(actor, stack)
            RecordPickups = true
            GM.elite_set(actor, i - 1)
            actor.elite_type = -1
            local function DisablePickupRecording(arg1, arg2)
                RecordPickups = false
            end
            Alarm.create(DisablePickupRecording, 1)
        end)
        Aspect:add_callback("onDrop", function(actor, stack)
            for _, item in ipairs(RecordedPickups) do
                actor:item_remove(item)
            end
            RecordedPickups = {}
        end)
    end
    gm.post_script_hook(gm.constants.item_give, function(self, other, result, args)
        if RecordPickups then
            table.insert(RecordedPickups, args[2].value)
        end
    end)

    Equipment.find("OnyxEliteAspects", "blazing"):add_callback("onPickup", function(actor)
        actor:item_give(Item.find("ror", "eliteOrbFireTrail"))
    end)

    Equipment.find("OnyxEliteAspects", "leeching"):add_callback("onPickup", function(actor)
        actor:item_give(Item.find("ror", "elitePassiveLeeching"))
        actor:item_give(Item.find("ror", "eliteOrbLifesteal"))
        actor:get_data().HealCooldown = 0
        actor:get_data().CircleX = actor.x
        actor:get_data().CircleY = actor.y
        actor:get_data().NextCooldown = math.random(30, 1200)
    end)

    Equipment.find("OnyxEliteAspects", "overloading"):add_callback("onPickup", function(actor)
        actor:item_give(Item.find("ror", "eliteOrbLightning"))
        actor:item_give(Item.find("ror", "elitePassiveOverloading"))
        actor:get_data().LightningTimer = 60
        actor:get_data().Sparknum = 0
    end)

    Equipment.find("OnyxEliteAspects", "volatile"):add_callback("onPickup", function(actor)
        actor:item_give(Item.find("ror", "eliteOrbExplosiveShot"))
        actor:item_give(Item.find("ror", "elitePassiveVolatile"))
        actor:get_data().MissleTimer = math.random(120, 600)
        actor:get_data().MissleNum = math.random(1, 3)
    end)

    Equipment.find("OnyxEliteAspects", "blighted"):add_callback("onPickup", function(actor)
        actor:item_give(Item.find("ror", "eliteOrbExplosiveShot"))
        actor:item_give(Item.find("ror", "elitePassiveVolatile"))
        actor:item_give(Item.find("ror", "eliteOrbLightning"))
        actor:item_give(Item.find("ror", "elitePassiveOverloading"))
        actor:item_give(Item.find("ror", "elitePassiveLeeching"))
        actor:item_give(Item.find("ror", "eliteOrbLifesteal"))
        actor:item_give(Item.find("ror", "eliteOrbAttackSpeed"))
        actor:item_give(Item.find("ror", "eliteOrbMoveSpeed"))
        actor:item_give(Item.find("ror", "elitePassiveTeleport"))
        actor:item_give(Item.find("ror", "eliteOrbFireTrail"))
        actor:get_data().HealCooldown = 0
        actor:get_data().CircleX = actor.x
        actor:get_data().CircleY = actor.y
        actor:get_data().NextCooldown = math.random(30, 1200)
        actor:get_data().MissleTimer = math.random(120, 600)
        actor:get_data().MissleNum = math.random(1, 3)
        actor:get_data().LightningTimer = 60
        actor:get_data().Sparknum = 0
    end)

    local function FrenzyTeleport(actor)
        local Target = actor:find_target_nearest(actor.x, actor.y)
        if Target and Target ~= -4 then
            actor.x = Target.x
            actor.y = Target.y
        end
    end
    Equipment.find("OnyxEliteAspects", "frenzied"):add_callback("onUse", function(actor)
        FrenzyTeleport(actor)
    end)
    Equipment.find("OnyxEliteAspects", "blighted"):add_callback("onUse", function(actor)
        FrenzyTeleport(actor)
    end)

    local function OverloadingLightning(actor)
        local actorData = actor:get_data()
        actorData.LightningTimer = actorData.LightningTimer - 1
        if actorData.LightningTimer == 0 then
            actorData.Sparknum = actorData.Sparknum + 1
            if actorData.Sparknum < 3 then
                local Lightning = Object.wrap(gm.constants.oEfLightningWarning):create(actor.x, actor.y)
                Object.wrap(gm.constants.oEfOverloadingSparking):create(actor.x + 20, actor.y - 20)
                Lightning.team = 1
                Lightning.range = 200
                Lightning.rTarget = actor:find_target_nearest(actor.x, actor.y)
                actorData.LightningTimer = 30
            else
                if Mod.find("RandomCatDude-DeerectorsCut") == nil then
                    Object.wrap(gm.constants.oChainLightning):create(actor.x, actor.y)
                end
                actorData.LightningTimer = math.random(60, 120)
                actorData.Sparknum = 0
            end
        end
    end
    Equipment.find("OnyxEliteAspects", "overloading"):add_callback("onPostStep", function(actor, new_equipment)
        OverloadingLightning(actor)
    end)

    local function VolatileMissle(actor)
        local actorData = actor:get_data()
        actorData.MissleTimer = actorData.MissleTimer - 1
        if actorData.MissleTimer == 0 then
            if actorData.MissleNum > 0 then
                actorData.MissleTimer = 30
                local Missle = Object.wrap(gm.constants.oEfMissileEnemy):create(actor.x, actor.y)
                Missle.team = 1
                actorData.MissleNum = actorData.MissleNum - 1
            else
                actorData.MissleTimer = math.random(60, 600)
                actorData.MissleNum = math.random(1, 3)
            end
        end
    end
    Equipment.find("OnyxEliteAspects", "volatile"):add_callback("onPostStep", function(actor, new_equipment)
        VolatileMissle(actor)
    end)
    Equipment.find("OnyxEliteAspects", "blighted"):add_callback("onPostStep", function(actor, new_equipment)
        VolatileMissle(actor)
        OverloadingLightning(actor)
    end)

    local function LeechingHealRing(actor)
        local actordata = actor:get_data()
        actordata.HealCooldown = actordata.HealCooldown + 1
        if actordata.HealCooldown == actordata.NextCooldown then
            actordata.CircleX = actor.x
            actordata.CircleY = actor.y
            actordata.HealCooldown = 0
            actordata.NextCooldown = math.random(30, 1200)
            local friends = List.new()
            actor:collision_circle_list(actor.x, actor.y, 70, gm.constants.pActor, false, false, friends, false)
            for _, friend in ipairs(friends) do
                friend = Instance.wrap(friend)
                if friend.team == actor.team and not friend:same(actor) then
                    friend:heal(friend.maxhp * 0.25)
                end
            end
        end
        gm.draw_set_alpha(1 - actordata.HealCooldown / 15)
        gm.draw_circle_colour(actordata.CircleX, actordata.CircleY, 70 * actordata.HealCooldown / 15, 11337629,
            11337629, true)
    end
    Equipment.find("OnyxEliteAspects", "leeching"):add_callback("onPostDraw", function(actor, new_equipment)
        LeechingHealRing(actor)
    end)
    Equipment.find("OnyxEliteAspects", "blighted"):add_callback("onPostDraw", function(actor, new_equipment)
        LeechingHealRing(actor)
    end)

    local function FrenzySpeedBoost(actor)
        actor.pHmax = actor.pHmax * 1.25
        actor.pHmax_raw = actor.pHmax_raw * 1.25
        actor.attack_speed = actor.attack_speed * 1.3
    end
    Equipment.find("OnyxEliteAspects", "frenzied"):add_callback("onPostStatRecalc", function(actor)
        FrenzySpeedBoost(actor)
    end)

    Equipment.find("OnyxEliteAspects", "blazing"):add_callback("onPostStatRecalc", function(actor)
        actor.pHmax = actor.pHmax * 1.2
        actor.pHmax_raw = actor.pHmax_raw * 1.2
    end)
    Equipment.find("OnyxEliteAspects", "blighted"):add_callback("onPostStatRecalc", function(actor)
        FrenzySpeedBoost(actor)
    end)

    Equipment.find("OnyxEliteAspects", "artifactBoss"):add_callback("onPickup", function(actor)
        actor:item_give(Item.find("ror", "barbedWire"))
        actor:item_give(Item.find("ror", "panicMines"))
        actor:item_give(Item.find("ror", "medkit"))
    end)
    Equipment.find("OnyxEliteAspects", "artifactBoss"):add_callback("onPostStatRecalc", function(actor)
        actor.pHmax = actor.pHmax * 1.5
        actor.pHmax_raw = actor.pHmax_raw * 1.5
    end)
    Equipment.find("OnyxEliteAspects", "artifactBoss"):add_callback("onPostStep", function(actor, new_equipment)
        VolatileMissle(actor)
    end)

    Callback.add(Callback.TYPE.onKillProc, "OnyxDropableAspects-onKillProc", function(victim, killer)
        if GM.actor_is_elite(victim) and math.random(1, params.DropChance) == params.DropChance then
            -- Block cognant
            if victim.elite_type ~= 7 and params.EnabledAspects[Global.class_elite[victim.elite_type + 1][2]] then
                Equipment.find("OnyxEliteAspects", Elites[victim.elite_type + 1][2]):create(victim.x, victim.y)
            end
        end
    end)

    -- gm.post_script_hook(gm.constants.enemy_stats_init, function(self, other, result, args)
    --     GM.elite_set(self, 4)
    --     local function myFunc(self)
    --         self.hp = 1
    --     end
    --     Alarm.create(myFunc, 10, self)
    -- end)
end, true)

-- Add ImGui window
gui.add_to_menu_bar(function()
    ImGui.Text("Drop Chance 1 in")
        params.DropChance = ImGui.DragFloat("", params.DropChance, 5, 1, 2000)
        for i, elite in ipairs(Global.class_elite) do
            if elite[2] ~= "cognant" then
                if params.EnabledAspects[elite[2]] == nil then
                    params.EnabledAspects[elite[2]] = false
                end
                params.EnabledAspects[elite[2]] = ImGui.Checkbox(
                    string.sub(Language.translate_token(elite[3]), 1, -4) .. " Aspect", params.EnabledAspects[elite[2]])
            end
        end
    Toml.save_cfg(_ENV["!guid"], params)
end)
gui.add_imgui(function()
    if ImGui.Begin("Elite Aspects") then
        ImGui.Text("Drop Chance 1 in")
        params.DropChance = ImGui.DragFloat("", params.DropChance, 5, 1, 2000)
        for i, elite in ipairs(Global.class_elite) do
            if elite[2] ~= "cognant" then
                if params.EnabledAspects[elite[2]] == nil then
                    params.EnabledAspects[elite[2]] = false
                end
                params.EnabledAspects[elite[2]] = ImGui.Checkbox(
                    string.sub(Language.translate_token(elite[3]), 1, -4) .. " Aspect", params.EnabledAspects[elite[2]])
            end
        end
        Toml.save_cfg(_ENV["!guid"], params)
    end
    ImGui.End()
end)
