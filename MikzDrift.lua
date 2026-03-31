-- ============================================================
-- MikzDrift v2.1 - FiveM-Style Drift Preset Script for Lexis
-- Multiplier-based system: works on every car in GTA Online
-- Full controller support (GTA 5 layout)
-- ============================================================

local natives = require('natives')

if this.permissions() & permission.natives == 0 then
    notify.push('MikzDrift', 'Script requires natives permission. Unloading.')
    this.unload()
    return
end

-- ============================================================
-- NATIVE HASHES
-- ============================================================

local N = {
    PLAYER_PED_ID                   = 0xD80958FC74E988A6,
    IS_PED_IN_ANY_VEHICLE           = 0x997ABD671D25CA0B,
    GET_VEHICLE_PED_IS_IN           = 0x9A9112A0FE9A4713,
    GET_ENTITY_SPEED                = 0xD5037BA82E12416F,
    GET_ENTITY_HEADING              = 0xE83D4F9BA2A38914,
    GET_ENTITY_VELOCITY             = 0x4805D2B1D8CF94A9,
    GET_ENTITY_COORDS               = 0x3FEF770D40960D5A,
    GET_ENTITY_ROTATION             = 0xAFBD61CC738D9EB9,
    GET_ENTITY_SPEED_VECTOR         = 0x9A8D700A51CB7B0D,
    GET_ENTITY_FORWARD_VECTOR       = 0x0A794A5A57F8DF91,
    APPLY_FORCE_TO_ENTITY           = 0xC5F68BE9613E2D18,
    SET_ENTITY_MAX_SPEED            = 0x916A733C5BFFD6DF,
    GET_VEHICLE_HANDLING_FLOAT      = 0x642FC12F36B74811,
    SET_VEHICLE_HANDLING_FLOAT      = 0x488C86D2B073C895,
    SET_VEHICLE_HANDLING_INT        = 0x4BA96F93E61C8016,
    GET_VEHICLE_HANDLING_INT        = 0x27396CF7F08B429E,
    MODIFY_VEHICLE_TOP_SPEED        = 0x93A3996368C94158,
    SET_VEHICLE_CHEAT_POWER_INCREASE = 0xB59E4BD37AE292DB,
    IS_VEHICLE_ON_ALL_WHEELS        = 0xB104CD1BABF302E2,
    SET_VEHICLE_REDUCE_GRIP         = 0x222FF6A823D122E2,
    SET_VEHICLE_BURNOUT             = 0xFB8794444A7D60FB,
    IS_VEHICLE_IN_BURNOUT           = 0x1297A88E081430EB,
    GET_VEHICLE_WHEEL_SPEED         = 0x149C9DA0E06E4B63,
    SET_VEHICLE_TYRE_SMOKE_COLOR    = 0xB5BA80F839791C56,
    IS_USING_KEYBOARD_AND_MOUSE     = 0xA571D46727E2B718,
    GET_CONTROL_NORMAL              = 0xEC3C9B8D5327B563,
    IS_CONTROL_JUST_PRESSED         = 0x580417101DDB492F,
    IS_CONTROL_PRESSED              = 0xF3A21BCD95725A4A,
    USE_PARTICLE_FX_ASSET           = 0x6C38AF3693A69A91,
    REQUEST_NAMED_PTFX_ASSET        = 0xB80D8756B4668AB6,
    HAS_NAMED_PTFX_ASSET_LOADED     = 0x8702FAD857104A22,
    START_PARTICLE_FX_LOOPED_ON_ENTITY = 0x1AE42C1660FD6517,
    STOP_PARTICLE_FX_LOOPED         = 0x8F75B0F96A21CD8A,
    SET_PARTICLE_FX_LOOPED_SCALE    = 0xB44250AAA456492B,
    SET_PARTICLE_FX_LOOPED_COLOUR   = 0x7F8F65877F88783B,
    GET_ENTITY_BONE_INDEX_BY_NAME   = 0xFB71170B7E76ACBA,
    START_PARTICLE_FX_NON_LOOPED_ON_ENTITY = 0x0D53A3B8DA0809D2,
    SET_PARTICLE_FX_NON_LOOPED_COLOUR = 0x26143A59EF48B262,
    GET_GAME_TIMER                  = 0x9CD27B0045628463,
    PLAY_SOUND_FROM_ENTITY          = 0xE65F427EB70AB1ED,
    GET_SOUND_ID                    = 0x430386F9BF80B45C,
    RELEASE_SOUND_ID                = 0x353FC880830B88FA,
}

-- ============================================================
-- HANDLING FIELD MAP (expanded for FiveM-style tuning)
-- ============================================================

local HANDLING_FIELDS = {
    -- Traction
    { field = 'fTractionCurveMin',         key = 'tractionMin' },
    { field = 'fTractionCurveMax',         key = 'tractionMax' },
    { field = 'fTractionCurveLateral',     key = 'tractionLateral' },
    { field = 'fTractionBiasFront',        key = 'tractionBiasFront' },
    { field = 'fTractionLossMult',         key = 'tractionLossMult' },
    { field = 'fLowSpeedTractionLossMult', key = 'lowSpeedTractionLoss' },
    -- Drivetrain
    { field = 'fDriveBiasFront',           key = 'driveBiasFront' },
    { field = 'fInitialDriveForce',        key = 'driveForce' },
    { field = 'fDriveInertia',             key = 'driveInertia' },
    { field = 'fInitialDriveMaxFlatVel',   key = 'topSpeed' },
    -- Steering
    { field = 'fSteeringLock',             key = 'steeringLock' },
    -- Brakes
    { field = 'fBrakeForce',               key = 'brakeForce' },
    { field = 'fBrakeBiasFront',           key = 'brakeBiasFront' },
    { field = 'fHandBrakeForce',           key = 'handBrakeForce' },
    -- Suspension
    { field = 'fSuspensionForce',          key = 'suspForce' },
    { field = 'fSuspensionCompDamp',       key = 'suspCompDamp' },
    { field = 'fSuspensionReboundDamp',    key = 'suspReboundDamp' },
    { field = 'fSuspensionUpperLimit',     key = 'suspUpperLimit' },
    { field = 'fSuspensionLowerLimit',     key = 'suspLowerLimit' },
    { field = 'fSuspensionBiasFront',      key = 'suspBiasFront' },
    { field = 'fAntiRollBarForce',         key = 'antiRollBar' },
    { field = 'fAntiRollBarBiasFront',     key = 'antiRollBiasFront' },
    -- Aero / weight
    { field = 'fDownforceModifier',        key = 'downforce' },
    { field = 'fInitialDragCoeff',         key = 'dragCoeff' },
    { field = 'fCamberStiffnesss',         key = 'camberStiffness' },
    { field = 'fRollCentreHeightFront',    key = 'rollCenterFront' },
    { field = 'fRollCentreHeightRear',     key = 'rollCenterRear' },
    -- Mass
    { field = 'fMass',                     key = 'mass' },
    { field = 'fPercentSubmerged',         key = 'percentSubmerged' },
}

-- ============================================================
-- FiveM-STYLE DRIFT PRESETS (multiplier-based)
--
-- All values are MULTIPLIERS applied to the car's stock handling.
-- 1.0 = stock, 0.5 = half, 1.5 = 150% of stock, etc.
-- Some fields use 'set' mode (forced to an exact value regardless
-- of stock) — marked with _set suffix. This ensures stuff like
-- driveBiasFront is always 0.0 (RWD) no matter what car you're in.
-- ============================================================

local PRESETS = {
    -- 1) STREET — beginner-friendly, stable slides, forgiving
    {
        name            = 'Street',
        desc            = 'Beginner | Stable slides, easy recovery',
        mult = {
            tractionMin         = 0.85,     -- slight grip reduction
            tractionMax         = 0.88,
            tractionLateral     = 0.95,
            tractionBiasFront   = 1.05,     -- nudge traction to front
            tractionLossMult    = 1.30,     -- more traction loss
            lowSpeedTractionLoss = 1.40,
            driveForce          = 1.10,     -- slight power bump
            driveInertia        = 1.05,
            topSpeed            = 1.00,     -- keep stock top speed
            steeringLock        = 1.15,     -- wider steering angle
            brakeForce          = 0.95,
            brakeBiasFront      = 1.05,
            handBrakeForce      = 1.30,     -- stronger handbrake for initiation
            suspForce           = 1.15,     -- stiffer suspension
            suspCompDamp        = 1.10,
            suspReboundDamp     = 1.15,
            suspUpperLimit      = 0.80,     -- lower ride height
            suspLowerLimit      = 0.90,
            suspBiasFront       = 1.00,
            antiRollBar         = 0.85,     -- softer anti-roll = more body roll
            antiRollBiasFront   = 1.05,
            downforce           = 0.60,     -- reduce downforce for slides
            dragCoeff           = 0.90,
            camberStiffness     = 0.80,
            rollCenterFront     = 1.00,
            rollCenterRear      = 0.95,
            mass                = 0.95,     -- slightly lighter
            percentSubmerged    = 1.00,
        },
        set = {
            driveBiasFront      = 0.0,      -- force RWD
        },
        assistStrength  = 0.65,
        assistAngleMin  = 8.0,
        assistAngleMax  = 70.0,
    },

    -- 2) TOUGE — mountain pass style, snappy transitions
    {
        name            = 'Touge',
        desc            = 'Mountain pass | Quick transitions, tight lines',
        mult = {
            tractionMin         = 0.72,
            tractionMax         = 0.76,
            tractionLateral     = 0.90,
            tractionBiasFront   = 1.08,
            tractionLossMult    = 1.50,
            lowSpeedTractionLoss = 1.60,
            driveForce          = 1.18,
            driveInertia        = 1.10,
            topSpeed            = 1.00,
            steeringLock        = 1.30,
            brakeForce          = 0.90,
            brakeBiasFront      = 1.00,
            handBrakeForce      = 1.50,
            suspForce           = 1.20,
            suspCompDamp        = 1.15,
            suspReboundDamp     = 1.20,
            suspUpperLimit      = 0.75,
            suspLowerLimit      = 0.85,
            suspBiasFront       = 0.97,
            antiRollBar         = 0.72,
            antiRollBiasFront   = 1.02,
            downforce           = 0.40,
            dragCoeff           = 0.85,
            camberStiffness     = 0.65,
            rollCenterFront     = 0.95,
            rollCenterRear      = 0.90,
            mass                = 0.92,
            percentSubmerged    = 1.00,
        },
        set = {
            driveBiasFront      = 0.0,
        },
        assistStrength  = 0.55,
        assistAngleMin  = 10.0,
        assistAngleMax  = 75.0,
    },

    -- 3) TANDEM — close-follow competitive, predictable and smooth
    {
        name            = 'Tandem',
        desc            = 'Competitive | Smooth angle, proximity control',
        mult = {
            tractionMin         = 0.62,
            tractionMax         = 0.66,
            tractionLateral     = 0.88,
            tractionBiasFront   = 1.10,
            tractionLossMult    = 1.65,
            lowSpeedTractionLoss = 1.75,
            driveForce          = 1.25,
            driveInertia        = 1.15,
            topSpeed            = 1.02,
            steeringLock        = 1.40,
            brakeForce          = 0.88,
            brakeBiasFront      = 0.97,
            handBrakeForce      = 1.65,
            suspForce           = 1.25,
            suspCompDamp        = 1.20,
            suspReboundDamp     = 1.25,
            suspUpperLimit      = 0.70,
            suspLowerLimit      = 0.80,
            suspBiasFront       = 0.95,
            antiRollBar         = 0.60,
            antiRollBiasFront   = 1.00,
            downforce           = 0.25,
            dragCoeff           = 0.80,
            camberStiffness     = 0.55,
            rollCenterFront     = 0.92,
            rollCenterRear      = 0.88,
            mass                = 0.90,
            percentSubmerged    = 1.00,
        },
        set = {
            driveBiasFront      = 0.0,
        },
        assistStrength  = 0.50,
        assistAngleMin  = 12.0,
        assistAngleMax  = 80.0,
    },

    -- 4) MISSILE — high speed, aggressive angle, raw power
    {
        name            = 'Missile',
        desc            = 'Advanced | High speed, big angle, raw power',
        mult = {
            tractionMin         = 0.50,
            tractionMax         = 0.55,
            tractionLateral     = 0.82,
            tractionBiasFront   = 1.14,
            tractionLossMult    = 1.85,
            lowSpeedTractionLoss = 2.00,
            driveForce          = 1.40,
            driveInertia        = 1.20,
            topSpeed            = 1.05,
            steeringLock        = 1.55,
            brakeForce          = 0.82,
            brakeBiasFront      = 0.93,
            handBrakeForce      = 1.85,
            suspForce           = 1.30,
            suspCompDamp        = 1.25,
            suspReboundDamp     = 1.30,
            suspUpperLimit      = 0.65,
            suspLowerLimit      = 0.75,
            suspBiasFront       = 0.93,
            antiRollBar         = 0.45,
            antiRollBiasFront   = 0.97,
            downforce           = 0.15,
            dragCoeff           = 0.72,
            camberStiffness     = 0.40,
            rollCenterFront     = 0.88,
            rollCenterRear      = 0.82,
            mass                = 0.87,
            percentSubmerged    = 1.00,
        },
        set = {
            driveBiasFront      = 0.0,
        },
        assistStrength  = 0.40,
        assistAngleMin  = 12.0,
        assistAngleMax  = 85.0,
    },

    -- 5) COMPETITION — FD / D1 pro-style, max angle max speed
    {
        name            = 'Competition',
        desc            = 'Pro | FD/D1 style, max angle & commitment',
        mult = {
            tractionMin         = 0.38,
            tractionMax         = 0.44,
            tractionLateral     = 0.78,
            tractionBiasFront   = 1.18,
            tractionLossMult    = 2.10,
            lowSpeedTractionLoss = 2.30,
            driveForce          = 1.55,
            driveInertia        = 1.25,
            topSpeed            = 1.08,
            steeringLock        = 1.70,
            brakeForce          = 0.78,
            brakeBiasFront      = 0.90,
            handBrakeForce      = 2.10,
            suspForce           = 1.35,
            suspCompDamp        = 1.30,
            suspReboundDamp     = 1.35,
            suspUpperLimit      = 0.60,
            suspLowerLimit      = 0.70,
            suspBiasFront       = 0.90,
            antiRollBar         = 0.35,
            antiRollBiasFront   = 0.95,
            downforce           = 0.05,
            dragCoeff           = 0.65,
            camberStiffness     = 0.30,
            rollCenterFront     = 0.85,
            rollCenterRear      = 0.78,
            mass                = 0.85,
            percentSubmerged    = 1.00,
        },
        set = {
            driveBiasFront      = 0.0,
        },
        assistStrength  = 0.30,
        assistAngleMin  = 15.0,
        assistAngleMax  = 90.0,
    },

    -- 6) GYMKHANA — low speed tricks, huge lock, instant response
    {
        name            = 'Gymkhana',
        desc            = 'Freestyle | Huge angle, donuts, trick lines',
        mult = {
            tractionMin         = 0.28,
            tractionMax         = 0.35,
            tractionLateral     = 0.72,
            tractionBiasFront   = 1.22,
            tractionLossMult    = 2.50,
            lowSpeedTractionLoss = 2.80,
            driveForce          = 1.70,
            driveInertia        = 1.35,
            topSpeed            = 0.90,     -- cap top speed for control
            steeringLock        = 1.90,     -- massive steering angle
            brakeForce          = 0.75,
            brakeBiasFront      = 0.88,
            handBrakeForce      = 2.50,
            suspForce           = 1.40,
            suspCompDamp        = 1.35,
            suspReboundDamp     = 1.40,
            suspUpperLimit      = 0.55,
            suspLowerLimit      = 0.65,
            suspBiasFront       = 0.88,
            antiRollBar         = 0.25,
            antiRollBiasFront   = 0.93,
            downforce           = 0.00,
            dragCoeff           = 0.60,
            camberStiffness     = 0.20,
            rollCenterFront     = 0.80,
            rollCenterRear      = 0.72,
            mass                = 0.82,
            percentSubmerged    = 1.00,
        },
        set = {
            driveBiasFront      = 0.0,
        },
        assistStrength  = 0.25,
        assistAngleMin  = 8.0,
        assistAngleMax  = 120.0,
    },
}

-- ============================================================
-- STATE
-- ============================================================

local currentPreset     = 1
local driftActive       = false
local originalHandling  = nil
local lastVehicle       = nil

-- Feature toggles
local counterSteerEnabled = true
local hudEnabled          = true
local tireSmokeEnabled    = true
local angleTrackEnabled   = true
local throttleModEnabled  = true

-- Drift angle state
local currentAngle      = 0.0
local peakAngle         = 0.0
local isDrifting        = false
local driftStartTime    = 0
local driftDuration     = 0.0
local driftScore        = 0
local comboMultiplier   = 1.0
local comboTimer        = 0
local totalScore        = 0
local bestAngle         = 0.0
local bestCombo         = 0

-- Smoke FX state
local smokeHandles      = {}
local ptfxLoaded        = false
local smokeColor        = { r = 255, g = 255, b = 255 }

-- Controller pad IDs (GTA 5 layout)
local PAD_DPAD_UP       = 0x8FD015D8
local PAD_DPAD_DOWN     = 0x9137C510
local PAD_DPAD_LEFT     = 0xA65EBAB4
local PAD_DPAD_RIGHT    = 0xDEB34313
local PAD_RB            = 0xE30CD707
local PAD_LB            = 0xFD1F1CF3

-- ============================================================
-- CORE HELPERS
-- ============================================================

local function getPlayerVehicle()
    local ped = invoker.call(N.PLAYER_PED_ID).int
    if invoker.call(N.IS_PED_IN_ANY_VEHICLE, ped, false).bool then
        return invoker.call(N.GET_VEHICLE_PED_IS_IN, ped, false).int
    end
    return nil
end

local function getGameTime()
    return invoker.call(N.GET_GAME_TIMER).int
end

local function saveHandling(vehicle)
    local saved = {}
    for _, e in ipairs(HANDLING_FIELDS) do
        saved[e.key] = invoker.call(N.GET_VEHICLE_HANDLING_FLOAT, vehicle, joaat('CHandlingData'), joaat(e.field)).float
    end
    return saved
end

-- Apply a drift preset using multipliers against the car's stock handling.
-- preset.mult[key] = multiplier applied to stock value (1.0 = no change)
-- preset.set[key]  = forced absolute value (overrides stock entirely)
local function applyDriftPreset(vehicle, preset)
    if not originalHandling then return end

    for _, e in ipairs(HANDLING_FIELDS) do
        local stockVal = originalHandling[e.key]
        if stockVal then
            local newVal = stockVal

            -- Check for forced absolute value first
            if preset.set and preset.set[e.key] ~= nil then
                newVal = preset.set[e.key]
            -- Then apply multiplier
            elseif preset.mult and preset.mult[e.key] then
                newVal = stockVal * preset.mult[e.key]
            end

            invoker.call(N.SET_VEHICLE_HANDLING_FLOAT, vehicle, joaat('CHandlingData'), joaat(e.field), newVal)
        end
    end
end

-- Restore stock handling values directly (no multiplier math)
local function restoreHandling(vehicle)
    if originalHandling then
        for _, e in ipairs(HANDLING_FIELDS) do
            if originalHandling[e.key] then
                invoker.call(N.SET_VEHICLE_HANDLING_FLOAT, vehicle, joaat('CHandlingData'), joaat(e.field), originalHandling[e.key])
            end
        end
        originalHandling = nil
        driftActive = false
    end
end

local function clamp(val, lo, hi)
    return math.max(lo, math.min(hi, val))
end

local function lerp(a, b, t)
    return a + (b - a) * clamp(t, 0.0, 1.0)
end

local function normalizeAngle(a)
    while a > 180.0 do a = a - 360.0 end
    while a < -180.0 do a = a + 360.0 end
    return a
end

-- ============================================================
-- DRIFT ANGLE TRACKER & SCORING
-- ============================================================

local DRIFT_ANGLE_THRESHOLD = 5.0     -- min angle to count as drifting
local COMBO_TIMEOUT         = 1500    -- ms before combo resets
local SCORE_MULTIPLIER      = 1.0     -- base score per tick

local function calcDriftAngle(vehicle)
    local vel = invoker.call(N.GET_ENTITY_VELOCITY, vehicle).scr_vec3
    local speed = invoker.call(N.GET_ENTITY_SPEED, vehicle).float

    if speed < 3.0 then return 0.0 end

    local heading = invoker.call(N.GET_ENTITY_HEADING, vehicle).float
    local moveAngle = math.deg(math.atan(vel.x, vel.y))
    local angle = normalizeAngle(heading - moveAngle)

    return angle
end

local function updateDriftTracking(vehicle)
    if not angleTrackEnabled then
        currentAngle = 0.0
        return
    end

    local rawAngle = calcDriftAngle(vehicle)
    -- Smooth the angle display
    currentAngle = lerp(currentAngle, rawAngle, 0.15)

    local absAngle = math.abs(currentAngle)
    local now = getGameTime()
    local speed = invoker.call(N.GET_ENTITY_SPEED, vehicle).float
    local speedMPH = speed * 2.237

    if absAngle >= DRIFT_ANGLE_THRESHOLD and speed > 5.0 then
        if not isDrifting then
            isDrifting = true
            driftStartTime = now
            -- Continue combo if within timeout
            if now - comboTimer > COMBO_TIMEOUT then
                comboMultiplier = 1.0
                driftScore = 0
            end
        end

        -- Track peak angle this drift
        if absAngle > peakAngle then
            peakAngle = absAngle
        end
        if absAngle > bestAngle then
            bestAngle = absAngle
        end

        -- Scoring: angle * speed * combo
        driftDuration = (now - driftStartTime) / 1000.0
        local tickScore = (absAngle / 10.0) * (speedMPH / 30.0) * comboMultiplier * SCORE_MULTIPLIER
        driftScore = driftScore + tickScore

        -- Grow combo over time
        if driftDuration > 2.0 then
            comboMultiplier = clamp(1.0 + (driftDuration - 2.0) * 0.15, 1.0, 5.0)
        end
    else
        if isDrifting then
            isDrifting = false
            comboTimer = now
            totalScore = totalScore + math.floor(driftScore)

            if math.floor(driftScore) > bestCombo then
                bestCombo = math.floor(driftScore)
            end

            peakAngle = 0.0
        end

        -- Reset combo after timeout
        if now - comboTimer > COMBO_TIMEOUT and not isDrifting then
            if driftScore > 0 then
                driftScore = 0
                comboMultiplier = 1.0
            end
        end
    end
end

-- ============================================================
-- TIRE SMOKE SYSTEM
-- ============================================================

local PTFX_DICT  = 'core'
local PTFX_NAME  = 'exp_grd_bzgas_smoke'
local WHEEL_BONES = { 'wheel_lr', 'wheel_rr' }

local function loadPtfx()
    if ptfxLoaded then return true end
    invoker.call(N.REQUEST_NAMED_PTFX_ASSET, PTFX_DICT)
    if invoker.call(N.HAS_NAMED_PTFX_ASSET_LOADED, PTFX_DICT).bool then
        ptfxLoaded = true
        return true
    end
    return false
end

local function startSmoke(vehicle)
    if not tireSmokeEnabled then return end
    if #smokeHandles > 0 then return end
    if not loadPtfx() then return end

    for _, boneName in ipairs(WHEEL_BONES) do
        local boneIdx = invoker.call(N.GET_ENTITY_BONE_INDEX_BY_NAME, vehicle, boneName).int
        if boneIdx ~= -1 then
            invoker.call(N.USE_PARTICLE_FX_ASSET, PTFX_DICT)
            local handle = invoker.call(N.START_PARTICLE_FX_LOOPED_ON_ENTITY,
                PTFX_NAME, vehicle,
                0.0, 0.0, -0.3,      -- offset
                0.0, 0.0, 0.0,       -- rotation
                0.6,                  -- scale
                false, false, false,
                boneIdx, false, false, false
            ).int

            if handle and handle ~= 0 then
                invoker.call(N.SET_PARTICLE_FX_LOOPED_COLOUR, handle,
                    smokeColor.r / 255.0, smokeColor.g / 255.0, smokeColor.b / 255.0, false)
                table.insert(smokeHandles, handle)
            end
        end
    end
end

local function stopSmoke()
    for _, handle in ipairs(smokeHandles) do
        invoker.call(N.STOP_PARTICLE_FX_LOOPED, handle, false)
    end
    smokeHandles = {}
end

local function updateSmokeScale(absAngle, speed)
    if #smokeHandles == 0 then return end
    -- Scale smoke intensity with drift angle and speed
    local angleFactor = clamp(absAngle / 60.0, 0.2, 1.0)
    local speedFactor = clamp(speed / 25.0, 0.3, 1.0)
    local scale = 0.3 + (angleFactor * speedFactor * 1.2)
    for _, handle in ipairs(smokeHandles) do
        invoker.call(N.SET_PARTICLE_FX_LOOPED_SCALE, handle, scale)
    end
end

local function updateTireSmoke(vehicle)
    if not tireSmokeEnabled or not driftActive then
        stopSmoke()
        return
    end

    local absAngle = math.abs(currentAngle)
    local speed = invoker.call(N.GET_ENTITY_SPEED, vehicle).float

    if absAngle > 12.0 and speed > 5.0 then
        startSmoke(vehicle)
        updateSmokeScale(absAngle, speed)
    else
        stopSmoke()
    end
end

-- ============================================================
-- COUNTER-STEER ASSIST (per-preset tuning)
-- ============================================================

local function doCounterSteerAssist(vehicle)
    if not counterSteerEnabled or not driftActive then return end

    local usingKBM = invoker.call(N.IS_USING_KEYBOARD_AND_MOUSE, 0).bool
    if usingKBM then return end

    local preset = PRESETS[currentPreset]
    local speed = invoker.call(N.GET_ENTITY_SPEED, vehicle).float
    if speed < 4.0 then return end

    local angle = calcDriftAngle(vehicle)
    local absAngle = math.abs(angle)

    local minA = preset.assistAngleMin or 10.0
    local maxA = preset.assistAngleMax or 80.0
    local strength = preset.assistStrength or 0.50

    if absAngle > minA and absAngle < maxA then
        local steerInput = invoker.call(N.GET_CONTROL_NORMAL, 0, 59).float

        -- Force proportional to angle, speed, and preset strength
        local force = angle * 0.0006 * speed * strength
        force = clamp(force, -2.0, 2.0)

        -- Reduce if player is already counter-steering
        if math.abs(steerInput) > 0.25 then
            force = force * 0.25
        end

        invoker.call(N.APPLY_FORCE_TO_ENTITY,
            vehicle, 1,
            force, 0.0, 0.0,
            0.0, -1.5, 0.0,
            0, true, true, true, false, true
        )
    end
end

-- ============================================================
-- THROTTLE MODULATION (controller)
-- Prevents full-throttle spinout, scales power to angle
-- ============================================================

local function doThrottleModulation(vehicle)
    if not throttleModEnabled or not driftActive then return end

    local usingKBM = invoker.call(N.IS_USING_KEYBOARD_AND_MOUSE, 0).bool
    if usingKBM then return end

    local absAngle = math.abs(currentAngle)
    local speed = invoker.call(N.GET_ENTITY_SPEED, vehicle).float

    -- At high angles with lots of throttle, reduce rear grip slightly to maintain slide
    -- instead of snapping back
    if absAngle > 30.0 and speed > 8.0 then
        local throttle = invoker.call(N.GET_CONTROL_NORMAL, 0, 71).float -- RT / R2
        if throttle > 0.8 then
            -- Small forward push to maintain speed through the drift
            local pushForce = clamp(throttle * 0.15 * (absAngle / 60.0), 0.0, 0.4)
            invoker.call(N.APPLY_FORCE_TO_ENTITY,
                vehicle, 1,
                0.0, pushForce, 0.0,
                0.0, 0.0, 0.0,
                0, true, true, true, false, true
            )
        end
    end
end

-- ============================================================
-- HUD RENDERING
-- ============================================================

local function getAngleColor(absAngle)
    if absAngle < 15.0 then
        return color(180, 180, 180, 220)
    elseif absAngle < 30.0 then
        return color(80, 255, 80, 240)
    elseif absAngle < 50.0 then
        return color(255, 220, 50, 240)
    elseif absAngle < 70.0 then
        return color(255, 140, 30, 240)
    else
        return color(255, 50, 50, 255)
    end
end

local function drawHUD()
    if not hudEnabled or not driftActive then return end

    local vehicle = getPlayerVehicle()
    if not vehicle then return end

    local res = game.resolution()
    local speed = invoker.call(N.GET_ENTITY_SPEED, vehicle).float
    local speedMPH = speed * 2.237
    local absAngle = math.abs(currentAngle)
    local preset = PRESETS[currentPreset]

    -- Main bar background
    local barW = 420.0
    local barH = 44.0
    local barX = res.x * 0.5 - barW * 0.5
    local barY = 10.0

    gui.rect(vec2(barX, barY), vec2(barW, barH))
        :filled()
        :color(color(10, 10, 10, 180))
        :rounding(8.0)
        :draw()

    -- Border glow when drifting
    if isDrifting then
        gui.rect(vec2(barX, barY), vec2(barW, barH))
            :outline()
            :color(getAngleColor(absAngle))
            :rounding(8.0)
            :draw()
    end

    -- Title
    gui.text('MIKZDRIFT')
        :position(vec2(barX + 10.0, barY + 4.0))
        :color(color(80, 160, 255, 255))
        :scale(0.85)
        :draw()

    -- Preset name
    gui.text(preset.name)
        :position(vec2(barX + 10.0, barY + 22.0))
        :color(color(200, 200, 200, 180))
        :scale(0.65)
        :draw()

    -- Speed
    gui.text(string.format('%.0f MPH', speedMPH))
        :position(vec2(barX + 120.0, barY + 6.0))
        :color(color(80, 255, 80, 230))
        :scale(0.95)
        :draw()

    -- Drift angle (big display)
    if angleTrackEnabled then
        local angleStr = string.format('%.1f', absAngle)
        gui.text(angleStr .. '\xC2\xB0')
            :position(vec2(barX + 230.0, barY + 2.0))
            :color(getAngleColor(absAngle))
            :scale(1.3)
            :draw()
    end

    -- Score / combo
    if angleTrackEnabled and (isDrifting or driftScore > 0) then
        local scoreStr = string.format('%d', math.floor(driftScore))
        gui.text(scoreStr)
            :position(vec2(barX + 330.0, barY + 4.0))
            :color(color(255, 255, 255, 230))
            :scale(0.9)
            :draw()

        if comboMultiplier > 1.0 then
            gui.text(string.format('x%.1f', comboMultiplier))
                :position(vec2(barX + 330.0, barY + 24.0))
                :color(color(255, 180, 50, 230))
                :scale(0.65)
                :draw()
        end
    end

    -- Stats bar (below main)
    local statsY = barY + barH + 4.0
    local statsH = 22.0

    gui.rect(vec2(barX, statsY), vec2(barW, statsH))
        :filled()
        :color(color(10, 10, 10, 140))
        :rounding(4.0)
        :draw()

    gui.text(string.format('Total: %d', totalScore))
        :position(vec2(barX + 10.0, statsY + 3.0))
        :color(color(160, 160, 160, 200))
        :scale(0.6)
        :draw()

    gui.text(string.format('Best: %.1f\xC2\xB0', bestAngle))
        :position(vec2(barX + 140.0, statsY + 3.0))
        :color(color(160, 160, 160, 200))
        :scale(0.6)
        :draw()

    gui.text(string.format('Best Combo: %d', bestCombo))
        :position(vec2(barX + 270.0, statsY + 3.0))
        :color(color(160, 160, 160, 200))
        :scale(0.6)
        :draw()
end

-- ============================================================
-- LEXIS MENU
-- ============================================================

local root = menu.root()
local driftMenu = root:submenu('MikzDrift')

-- ---- Presets submenu ----
local presetsMenu = driftMenu:submenu('Drift Presets')

local presetList = {}
for i, p in ipairs(PRESETS) do
    presetList[i] = { p.name, i }
end

presetsMenu:combo_int('Active Preset', presetList, menu.type.scroll)
    :tooltip('Select FiveM-style drift preset')
    :event(menu.event.click, function(opt)
        currentPreset = opt.list:at(opt.value).value
        if driftActive then
            local vehicle = getPlayerVehicle()
            if vehicle then
                applyDriftPreset(vehicle, PRESETS[currentPreset])
                notify.push('MikzDrift', 'Applied: ' .. PRESETS[currentPreset].name)
            end
        end
    end)

-- Add info buttons for each preset
for _, p in ipairs(PRESETS) do
    presetsMenu:button(p.name .. ' - Info')
        :tooltip(p.desc)
        :event(menu.event.click, function()
            notify.push('MikzDrift', p.name .. ': ' .. p.desc, { time = 4000 })
        end)
end

-- ---- Main toggles ----
local driftToggle = driftMenu:toggle('Enable Drift')
    :tooltip('Apply drift handling to your current vehicle')
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
            applyDriftPreset(vehicle, PRESETS[currentPreset])
            driftActive = true
            notify.push('MikzDrift', 'Drift ON - ' .. PRESETS[currentPreset].name)
        else
            if lastVehicle then
                restoreHandling(lastVehicle)
            end
            stopSmoke()
            driftActive = false
            lastVehicle = nil
            notify.push('MikzDrift', 'Drift OFF - Handling restored')
        end
    end)

-- ---- Assists submenu ----
local assistMenu = driftMenu:submenu('Assists & Tuning')

assistMenu:toggle('Counter-Steer Assist')
    :tooltip('Auto counter-steer on controller (per-preset strength)')
    :value(counterSteerEnabled)
    :event(menu.event.click, function(opt)
        counterSteerEnabled = opt.value
        notify.push('MikzDrift', 'Counter-steer: ' .. (opt.value and 'ON' or 'OFF'))
    end)

assistMenu:toggle('Throttle Modulation')
    :tooltip('Helps maintain speed through high-angle drifts on controller')
    :value(throttleModEnabled)
    :event(menu.event.click, function(opt)
        throttleModEnabled = opt.value
        notify.push('MikzDrift', 'Throttle mod: ' .. (opt.value and 'ON' or 'OFF'))
    end)

-- ---- Visuals submenu ----
local visualMenu = driftMenu:submenu('Visuals')

visualMenu:toggle('Tire Smoke')
    :tooltip('Rear tire smoke during drift')
    :value(tireSmokeEnabled)
    :event(menu.event.click, function(opt)
        tireSmokeEnabled = opt.value
        if not opt.value then stopSmoke() end
        notify.push('MikzDrift', 'Tire smoke: ' .. (opt.value and 'ON' or 'OFF'))
    end)

-- Smoke color options
local smokeColors = {
    { 'White',  { r = 255, g = 255, b = 255 } },
    { 'Blue',   { r = 80,  g = 160, b = 255 } },
    { 'Red',    { r = 255, g = 60,  b = 60  } },
    { 'Yellow', { r = 255, g = 220, b = 50  } },
    { 'Purple', { r = 180, g = 60,  b = 255 } },
    { 'Green',  { r = 60,  g = 255, b = 80  } },
    { 'Pink',   { r = 255, g = 100, b = 200 } },
    { 'Orange', { r = 255, g = 140, b = 30  } },
}

local smokeColorList = {}
for i, sc in ipairs(smokeColors) do
    smokeColorList[i] = { sc[1], i }
end

visualMenu:combo_int('Smoke Color', smokeColorList, menu.type.scroll)
    :tooltip('Change tire smoke color')
    :event(menu.event.click, function(opt)
        local idx = opt.list:at(opt.value).value
        smokeColor = smokeColors[idx][2]
        stopSmoke() -- restart with new color on next tick
        notify.push('MikzDrift', 'Smoke: ' .. smokeColors[idx][1])
    end)

-- ---- HUD submenu ----
local hudMenu = driftMenu:submenu('HUD & Scoring')

hudMenu:toggle('Show HUD')
    :tooltip('Display drift HUD with angle, speed, score')
    :value(hudEnabled)
    :event(menu.event.click, function(opt)
        hudEnabled = opt.value
    end)

hudMenu:toggle('Angle Tracker')
    :tooltip('Track drift angle and score combos')
    :value(angleTrackEnabled)
    :event(menu.event.click, function(opt)
        angleTrackEnabled = opt.value
    end)

hudMenu:button('Reset Score')
    :tooltip('Reset total score and best records')
    :event(menu.event.click, function()
        totalScore = 0
        bestAngle = 0.0
        bestCombo = 0
        driftScore = 0
        comboMultiplier = 1.0
        notify.push('MikzDrift', 'Score reset!')
    end)

-- ---- Restore button ----
driftMenu:button('Restore Original Handling')
    :tooltip('Restore stock handling and disable drift')
    :event(menu.event.click, function()
        if lastVehicle and originalHandling then
            restoreHandling(lastVehicle)
            stopSmoke()
            driftActive = false
            driftToggle.value = false
            lastVehicle = nil
            notify.push('MikzDrift', 'Original handling restored')
        else
            notify.push('MikzDrift', 'No drift preset active')
        end
    end)

-- ============================================================
-- CONTROLLER HOTKEYS (GTA 5 default layout)
--   D-Pad Left     = Toggle drift on/off
--   D-Pad Up/Down  = Cycle presets
--   D-Pad Right    = Reset score
--   RB + D-Pad Up  = Toggle smoke
--   RB + D-Pad Down = Toggle assist
-- ============================================================

local padCooldown = 0

local function handleControllerInput()
    local now = getGameTime()
    if now < padCooldown then return end

    local vehicle = getPlayerVehicle()
    if not vehicle then return end

    local rbHeld = input.pad(PAD_RB).pressed

    -- D-Pad Left: Toggle drift
    local dpadLeft = input.pad(PAD_DPAD_LEFT)
    if dpadLeft.just_pressed and not rbHeld then
        if not driftActive then
            originalHandling = saveHandling(vehicle)
            lastVehicle = vehicle
            applyDriftPreset(vehicle, PRESETS[currentPreset])
            driftActive = true
            driftToggle.value = true
            notify.push('MikzDrift', 'Drift ON - ' .. PRESETS[currentPreset].name)
        else
            restoreHandling(lastVehicle or vehicle)
            stopSmoke()
            driftActive = false
            driftToggle.value = false
            lastVehicle = nil
            notify.push('MikzDrift', 'Drift OFF')
        end
        padCooldown = now + 300
    end

    -- D-Pad Up: Previous preset (or toggle smoke with RB)
    local dpadUp = input.pad(PAD_DPAD_UP)
    if dpadUp.just_pressed then
        if rbHeld then
            tireSmokeEnabled = not tireSmokeEnabled
            if not tireSmokeEnabled then stopSmoke() end
            notify.push('MikzDrift', 'Tire smoke: ' .. (tireSmokeEnabled and 'ON' or 'OFF'))
        else
            currentPreset = currentPreset - 1
            if currentPreset < 1 then currentPreset = #PRESETS end
            if driftActive then
                applyDriftPreset(vehicle, PRESETS[currentPreset])
            end
            notify.push('MikzDrift', PRESETS[currentPreset].name .. ': ' .. PRESETS[currentPreset].desc)
        end
        padCooldown = now + 250
    end

    -- D-Pad Down: Next preset (or toggle assist with RB)
    local dpadDown = input.pad(PAD_DPAD_DOWN)
    if dpadDown.just_pressed then
        if rbHeld then
            counterSteerEnabled = not counterSteerEnabled
            notify.push('MikzDrift', 'Counter-steer: ' .. (counterSteerEnabled and 'ON' or 'OFF'))
        else
            currentPreset = currentPreset + 1
            if currentPreset > #PRESETS then currentPreset = 1 end
            if driftActive then
                applyDriftPreset(vehicle, PRESETS[currentPreset])
            end
            notify.push('MikzDrift', PRESETS[currentPreset].name .. ': ' .. PRESETS[currentPreset].desc)
        end
        padCooldown = now + 250
    end

    -- D-Pad Right: Reset score
    local dpadRight = input.pad(PAD_DPAD_RIGHT)
    if dpadRight.just_pressed and not rbHeld then
        totalScore = 0
        bestAngle = 0.0
        bestCombo = 0
        driftScore = 0
        comboMultiplier = 1.0
        notify.push('MikzDrift', 'Score reset!')
        padCooldown = now + 300
    end
end

-- ============================================================
-- MAIN THREAD
-- ============================================================

notify.push('MikzDrift', 'v2.1 Loaded | Works on any car | D-Pad controls', { time = 5000 })

util.create_thread(function()
    while true do
        handleControllerInput()

        local vehicle = getPlayerVehicle()
        if vehicle and driftActive then
            updateDriftTracking(vehicle)
            doCounterSteerAssist(vehicle)
            doThrottleModulation(vehicle)
            updateTireSmoke(vehicle)
        elseif not vehicle and driftActive then
            driftActive = false
            driftToggle.value = false
            originalHandling = nil
            lastVehicle = nil
            stopSmoke()
            isDrifting = false
            currentAngle = 0.0
            notify.push('MikzDrift', 'Left vehicle - drift disabled')
        end

        drawHUD()
        util.yield()
    end
end)
