-- MikzDrift - Drift Preset Script for Lexis
-- Applies drift handling to the vehicle you're driving
-- Full controller support following GTA 5's controller layout

local natives = require('natives')

-- ============================================================
-- PERMISSIONS CHECK
-- ============================================================

if this.permissions() & permission.natives == 0 then
    notify.push('MikzDrift', 'Script requires natives permission. Unloading.')
    this.unload()
    return
end

-- ============================================================
-- DRIFT PRESETS
-- ============================================================

local PRESETS = {
    {
        name = 'Light Drift',
        tractionCurveMin    = 1.8,
        tractionCurveMax    = 2.0,
        tractionBiasFront   = 0.48,
        tractionLossMult    = 0.8,
        lowSpeedTractionLoss = 0.6,
        driveBiasFront      = 0.0,
        driveForce          = 0.35,
        steeringLock        = 45.0,
        brakeForce          = 0.90,
        handBrakeForce      = 0.8,
        suspensionForce     = 2.2,
        antiRollBarForce    = 0.8,
        suspCompDamp        = 1.4,
        suspReboundDamp     = 2.2,
    },
    {
        name = 'Medium Drift',
        tractionCurveMin    = 1.4,
        tractionCurveMax    = 1.6,
        tractionBiasFront   = 0.50,
        tractionLossMult    = 1.0,
        lowSpeedTractionLoss = 0.8,
        driveBiasFront      = 0.0,
        driveForce          = 0.38,
        steeringLock        = 50.0,
        brakeForce          = 0.85,
        handBrakeForce      = 1.0,
        suspensionForce     = 2.0,
        antiRollBarForce    = 0.6,
        suspCompDamp        = 1.2,
        suspReboundDamp     = 2.0,
    },
    {
        name = 'Heavy Drift',
        tractionCurveMin    = 1.0,
        tractionCurveMax    = 1.2,
        tractionBiasFront   = 0.52,
        tractionLossMult    = 1.3,
        lowSpeedTractionLoss = 1.0,
        driveBiasFront      = 0.0,
        driveForce          = 0.42,
        steeringLock        = 55.0,
        brakeForce          = 0.80,
        handBrakeForce      = 1.2,
        suspensionForce     = 1.8,
        antiRollBarForce    = 0.4,
        suspCompDamp        = 1.0,
        suspReboundDamp     = 1.8,
    },
    {
        name = 'Extreme Drift',
        tractionCurveMin    = 0.6,
        tractionCurveMax    = 0.9,
        tractionBiasFront   = 0.55,
        tractionLossMult    = 1.6,
        lowSpeedTractionLoss = 1.2,
        driveBiasFront      = 0.0,
        driveForce          = 0.50,
        steeringLock        = 60.0,
        brakeForce          = 0.75,
        handBrakeForce      = 1.5,
        suspensionForce     = 1.6,
        antiRollBarForce    = 0.3,
        suspCompDamp        = 0.8,
        suspReboundDamp     = 1.6,
    },
}

-- ============================================================
-- NATIVE HASHES
-- ============================================================

local PLAYER_PED_ID                 = 0xD80958FC74E988A6
local IS_PED_IN_ANY_VEHICLE         = 0x997ABD671D25CA0B
local GET_VEHICLE_PED_IS_IN         = 0x9A9112A0FE9A4713
local GET_ENTITY_SPEED              = 0xD5037BA82E12416F
local GET_ENTITY_COORDS             = 0x3FEF770D40960D5A
local GET_ENTITY_HEADING            = 0xE83D4F9BA2A38914
local GET_ENTITY_VELOCITY           = 0x4805D2B1D8CF94A9
local APPLY_FORCE_TO_ENTITY         = 0xC5F68BE9613E2D18
local GET_VEHICLE_HANDLING_FLOAT    = 0x642FC12F36B74811
local SET_VEHICLE_HANDLING_FLOAT    = 0x488C86D2B073C895
local IS_USING_KEYBOARD_AND_MOUSE   = 0xA571D46727E2B718
local GET_CONTROL_NORMAL            = 0xEC3C9B8D5327B563
local IS_CONTROL_JUST_PRESSED       = 0x580417101DDB492F

-- ============================================================
-- STATE
-- ============================================================

local currentPreset = 1
local driftActive = false
local originalHandling = nil
local lastVehicle = nil
local counterSteerEnabled = true
local hudEnabled = true

-- ============================================================
-- GTA 5 CONTROLLER INPUT (via input.pad)
-- Controller uses GTA 5 default layout:
--   RT / R2       = Accelerate
--   LT / L2       = Brake / Reverse
--   Left Stick    = Steering
--   A / Cross     = Handbrake
--   D-Pad Up/Down = Cycle presets (handled via input.pad)
-- ============================================================

-- GTA 5 controller input IDs for input.pad()
local PAD_DPAD_UP    = 0x8FD015D8  -- D-Pad Up
local PAD_DPAD_DOWN  = 0x9137C510  -- D-Pad Down
local PAD_DPAD_LEFT  = 0xA65EBAB4  -- D-Pad Left
local PAD_DPAD_RIGHT = 0xDEB34313  -- D-Pad Right
local PAD_RB         = 0xE30CD707  -- RB / R1
local PAD_LB         = 0xFD1F1CF3  -- LB / L1

-- ============================================================
-- HANDLING HELPERS
-- ============================================================

local HANDLING_FIELDS = {
    { field = 'fTractionCurveMin',        key = 'tractionCurveMin' },
    { field = 'fTractionCurveMax',        key = 'tractionCurveMax' },
    { field = 'fTractionBiasFront',       key = 'tractionBiasFront' },
    { field = 'fTractionLossMult',        key = 'tractionLossMult' },
    { field = 'fLowSpeedTractionLossMult', key = 'lowSpeedTractionLoss' },
    { field = 'fDriveBiasFront',          key = 'driveBiasFront' },
    { field = 'fInitialDriveForce',       key = 'driveForce' },
    { field = 'fSteeringLock',            key = 'steeringLock' },
    { field = 'fBrakeForce',              key = 'brakeForce' },
    { field = 'fHandBrakeForce',          key = 'handBrakeForce' },
    { field = 'fSuspensionForce',         key = 'suspensionForce' },
    { field = 'fAntiRollBarForce',        key = 'antiRollBarForce' },
    { field = 'fSuspensionCompDamp',      key = 'suspCompDamp' },
    { field = 'fSuspensionReboundDamp',   key = 'suspReboundDamp' },
}

local function getPlayerVehicle()
    local ped = invoker.call(PLAYER_PED_ID).int
    local inVehicle = invoker.call(IS_PED_IN_ANY_VEHICLE, ped, false).bool
    if inVehicle then
        return invoker.call(GET_VEHICLE_PED_IS_IN, ped, false).int
    end
    return nil
end

local function saveHandling(vehicle)
    local saved = {}
    for _, entry in ipairs(HANDLING_FIELDS) do
        saved[entry.key] = invoker.call(GET_VEHICLE_HANDLING_FLOAT, vehicle, joaat('CHandlingData'), joaat(entry.field)).float
    end
    return saved
end

local function applyPreset(vehicle, preset)
    for _, entry in ipairs(HANDLING_FIELDS) do
        invoker.call(SET_VEHICLE_HANDLING_FLOAT, vehicle, joaat('CHandlingData'), joaat(entry.field), preset[entry.key])
    end
end

local function restoreHandling(vehicle)
    if originalHandling then
        applyPreset(vehicle, originalHandling)
        originalHandling = nil
        driftActive = false
    end
end

-- ============================================================
-- COUNTER-STEER ASSIST
-- Helps controller players maintain drift angle
-- ============================================================

local function doCounterSteerAssist(vehicle)
    if not counterSteerEnabled then return end

    local usingKBM = invoker.call(IS_USING_KEYBOARD_AND_MOUSE, 0).bool
    if usingKBM then return end

    local speed = invoker.call(GET_ENTITY_SPEED, vehicle).float
    if speed < 5.0 then return end

    local vel = invoker.call(GET_ENTITY_VELOCITY, vehicle).scr_vec3
    local heading = invoker.call(GET_ENTITY_HEADING, vehicle).float
    local moveAngle = math.deg(math.atan(vel.x, vel.y))
    local drift = heading - moveAngle

    if drift > 180.0 then drift = drift - 360.0 end
    if drift < -180.0 then drift = drift + 360.0 end

    local steerInput = invoker.call(GET_CONTROL_NORMAL, 0, 59).float
    local absDrift = math.abs(drift)

    if absDrift > 10.0 and absDrift < 90.0 then
        local force = drift * 0.0008 * speed
        force = math.max(-1.5, math.min(1.5, force))

        if math.abs(steerInput) > 0.3 then
            force = force * 0.3
        end

        invoker.call(APPLY_FORCE_TO_ENTITY,
            vehicle, 1,
            force, 0.0, 0.0,
            0.0, -1.5, 0.0,
            0, true, true, true, false, true
        )
    end
end

-- ============================================================
-- HUD
-- ============================================================

local function drawHUD()
    if not hudEnabled or not driftActive then return end

    local vehicle = getPlayerVehicle()
    if not vehicle then return end

    local speed = invoker.call(GET_ENTITY_SPEED, vehicle).float * 2.237
    local preset = PRESETS[currentPreset]
    local res = game.resolution()

    local bgX = res.x * 0.5 - 140.0
    local bgY = 8.0

    gui.rect(vec2(bgX, bgY), vec2(280.0, 32.0))
        :filled()
        :color(color(0, 0, 0, 160))
        :rounding(6.0)
        :draw()

    gui.text('MIKZDRIFT')
        :position(vec2(bgX + 8.0, bgY + 6.0))
        :color(color(80, 160, 255, 255))
        :scale(0.9)
        :draw()

    gui.text(preset.name)
        :position(vec2(bgX + 100.0, bgY + 6.0))
        :color(color(255, 220, 50, 255))
        :scale(0.9)
        :draw()

    gui.text(string.format('%.0f MPH', speed))
        :position(vec2(bgX + 220.0, bgY + 6.0))
        :color(color(80, 255, 80, 255))
        :scale(0.9)
        :draw()
end

-- ============================================================
-- MENU SETUP
-- ============================================================

local root = menu.root()
local driftMenu = root:submenu('MikzDrift')

-- Preset selector
local presetList = {}
for i, p in ipairs(PRESETS) do
    presetList[i] = { p.name, i }
end

local presetCombo = driftMenu:combo_int('Preset', presetList, menu.type.scroll)
    :tooltip('Select drift intensity preset')
    :event(menu.event.click, function(opt)
        currentPreset = opt.list:at(opt.value).value
        if driftActive then
            local vehicle = getPlayerVehicle()
            if vehicle then
                applyPreset(vehicle, PRESETS[currentPreset])
                notify.push('MikzDrift', 'Switched to ' .. PRESETS[currentPreset].name)
            end
        end
    end)

-- Enable/Disable toggle
local driftToggle = driftMenu:toggle('Enable Drift')
    :tooltip('Toggle drift handling on your current vehicle')
    :event(menu.event.click, function(opt)
        local vehicle = getPlayerVehicle()
        if not vehicle then
            opt.value = false
            notify.push('MikzDrift', 'You must be in a vehicle!')
            return
        end

        if opt.value then
            originalHandling = saveHandling(vehicle)
            lastVehicle = vehicle
            applyPreset(vehicle, PRESETS[currentPreset])
            driftActive = true
            notify.push('MikzDrift', 'Drift ON - ' .. PRESETS[currentPreset].name)
        else
            if lastVehicle then
                restoreHandling(lastVehicle)
            end
            driftActive = false
            lastVehicle = nil
            notify.push('MikzDrift', 'Drift OFF - Original handling restored')
        end
    end)

-- Counter-steer assist toggle
driftMenu:toggle('Counter-Steer Assist')
    :tooltip('Helps maintain drift angle on controller (auto-detects controller)')
    :event(menu.event.click, function(opt)
        counterSteerEnabled = opt.value
        notify.push('MikzDrift', 'Counter-steer assist: ' .. (opt.value and 'ON' or 'OFF'))
    end)

-- HUD toggle
driftMenu:toggle('Show HUD')
    :tooltip('Show drift status bar at the top of screen')
    :event(menu.event.click, function(opt)
        hudEnabled = opt.value
    end)

-- Restore button
driftMenu:button('Restore Original')
    :tooltip('Restore original vehicle handling and disable drift')
    :event(menu.event.click, function()
        if lastVehicle and originalHandling then
            restoreHandling(lastVehicle)
            driftActive = false
            driftToggle.value = false
            lastVehicle = nil
            notify.push('MikzDrift', 'Original handling restored')
        else
            notify.push('MikzDrift', 'No drift preset is active')
        end
    end)

-- Set initial toggle states
counterSteerEnabled = true
hudEnabled = true

-- ============================================================
-- CONTROLLER HOTKEYS (D-Pad while in vehicle)
-- Follows GTA 5 default controller layout:
--   D-Pad Left  = Toggle drift on/off
--   D-Pad Up    = Previous preset
--   D-Pad Down  = Next preset
-- ============================================================

local padCooldown = 0

local function handleControllerInput()
    local now = util.get_tick_count()
    if now < padCooldown then return end

    local vehicle = getPlayerVehicle()
    if not vehicle then return end

    -- D-Pad Left: Toggle drift
    local dpadLeft = input.pad(PAD_DPAD_LEFT)
    if dpadLeft.just_pressed then
        if not driftActive then
            originalHandling = saveHandling(vehicle)
            lastVehicle = vehicle
            applyPreset(vehicle, PRESETS[currentPreset])
            driftActive = true
            driftToggle.value = true
            notify.push('MikzDrift', 'Drift ON - ' .. PRESETS[currentPreset].name)
        else
            restoreHandling(lastVehicle or vehicle)
            driftActive = false
            driftToggle.value = false
            lastVehicle = nil
            notify.push('MikzDrift', 'Drift OFF')
        end
        padCooldown = now + 300
    end

    -- D-Pad Up: Previous preset
    local dpadUp = input.pad(PAD_DPAD_UP)
    if dpadUp.just_pressed then
        currentPreset = currentPreset - 1
        if currentPreset < 1 then currentPreset = #PRESETS end
        if driftActive then
            applyPreset(vehicle, PRESETS[currentPreset])
        end
        notify.push('MikzDrift', 'Preset: ' .. PRESETS[currentPreset].name)
        padCooldown = now + 250
    end

    -- D-Pad Down: Next preset
    local dpadDown = input.pad(PAD_DPAD_DOWN)
    if dpadDown.just_pressed then
        currentPreset = currentPreset + 1
        if currentPreset > #PRESETS then currentPreset = 1 end
        if driftActive then
            applyPreset(vehicle, PRESETS[currentPreset])
        end
        notify.push('MikzDrift', 'Preset: ' .. PRESETS[currentPreset].name)
        padCooldown = now + 250
    end
end

-- ============================================================
-- MAIN THREAD
-- ============================================================

notify.push('MikzDrift', 'Loaded! Use the menu or D-Pad to control drift.', { time = 5000 })

util.create_thread(function()
    while true do
        handleControllerInput()

        if driftActive then
            local vehicle = getPlayerVehicle()
            if vehicle then
                doCounterSteerAssist(vehicle)
            else
                -- Player left the vehicle
                driftActive = false
                driftToggle.value = false
                originalHandling = nil
                lastVehicle = nil
                notify.push('MikzDrift', 'Left vehicle - drift disabled')
            end
        end

        drawHUD()
        util.yield()
    end
end)
