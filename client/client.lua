local timeCycles = { -- add as many as you like
    'int_hanger_none',
    'int_GasStation',
    'int_extlight_none_dark',
    'int_carshowroom',
    'Hicksbar',
    'ReduceDrawDistanceMission',
    'NEW_tunnels_hole',
    'NEW_yellowtunnels',
    'NEW_tunnels',
    'new_stripper_changing',
    'new_station_unfinished',
    'New_sewers'
}

local savedOptions = {
    {label = 'Remove Low Priority Objects', description='Removes useless objects from the world.', icon = 'road', checked = false},
    {label = 'Reduce Shadows', description='Reduces the shadows.', icon = 'times-circle', checked = false},
    {label = 'Disable Shadows', description='Removes all shadows.', icon = 'times-circle', checked = false},
    {label = 'LOD Scaler', description='Scale your Level of detail.', icon = 'globe'},
    {label = 'Enable Timecycles', description='Control timecycles.', icon = 'eye', checked = false},
}


lib.registerMenu({
    id = 'fpsMenu',
    title = 'FPS Control',
    position = 'top-right',
    onCheck = function(selected, checked, args)
        saveOptions(selected, checked)
        FPSOptions(selected, checked, args)
    end,
    onClose = function(keyPressed)
        --print('hidden')
        lib.setMenuOptions('fpsMenu', savedOptions)
    end,
    onSideScroll = function(selected, scrollIndex, args)
        print(selected, scrollIndex, args)
        selectTimeCycle(scrollIndex)
    end,
    options = savedOptions
}, function(selected, scrollIndex, args)
    FPSOptions(selected)
end)

local optionActions = { -- don't judge me.
    function(checked)
        SetInstancePriorityHint(checked and 4 or 0)
    end,
    function(checked)
        CascadeShadowsEnableEntityTracker(checked)
    end,
    function(checked)
        CascadeShadowsSetCascadeBoundsScale(checked and 0.0 or 1.0)
    end,
    --CascadeShadowsSetCascadeBoundsScale() --0.0-1.0
    function()
        lib.hideMenu()
        local slider = lib.inputDialog('LOD Scale', {
            {type = 'slider', label = 'LOD Scale', description = 'Slide me!', required = true, min = 0.1, max = 1.0, default = 1.0, step=0.1},
        })
        if not slider then 
            OpenMenu()
            return
        end
        currentScale = slider[1]
        LODScaler()
        OpenMenu()
    end,
    function(checked)
        if checked then
            savedOptions[#savedOptions+1] = {label = 'Timecycles Effect', icon = 'arrows-alt-h', values=timeCycles}
            selectTimeCycle(1) -- we gonna load that first super ultra fps booster :sunglasses:
            lib.hideMenu()
            Wait(5) -- so menu doesn't buggy :P
            OpenMenu()
        else
            ClearTimecycleModifier()
            savedOptions[#savedOptions] = nil
            lib.hideMenu()
            Wait(5) -- so menu doesn't buggy :P
            OpenMenu()
        end
    end
}



local isScalerActive = false
local currentScale = 0.0
function LODScaler()
    if not isScalerActive then -- funky ways to prevent multiple calls :P
        CreateThread(function()
            isScalerActive = true
            while currentScale ~= 1.0 do
                Wait(0)
                Citizen.InvokeNative(0x9b8b94a1196f345f, currentScale)
            end
            isScalerActive = false
        end)
    end
end


function selectTimeCycle(id)
    ClearTimecycleModifier()
    SetTimecycleModifier(timeCycles[id])
    SetTimecycleModifierStrength(1.0)
end



function FPSOptions(selected, checked, args)
    if optionActions[selected] then
        optionActions[selected](checked)
    end
end

function saveOptions(id, toggle)
    savedOptions[id].checked = toggle
end

function OpenMenu()
    lib.setMenuOptions('fpsMenu', savedOptions)
    lib.showMenu('fpsMenu')
end

RegisterCommand('fps', function()
    OpenMenu()
end)