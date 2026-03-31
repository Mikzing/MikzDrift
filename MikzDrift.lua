-- ============================================================
-- MikzDrift v3.0 - FiveM-Style Drift Preset Script for Lexis
-- Multiplier-based system: works on every car in GTA Online
-- No custom keybinds — drive normally, control everything via menu
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
    DOES_ENTITY_EXIST               = 0x7239B21A38F536BA,
    GET_ENTITY_MODEL                = 0x9F47B058362C84B5,
    SET_GAMEPLAY_CAM_RELATIVE_HEADING = 0xB4EC2312F4E5B1F1,
    SET_GAMEPLAY_CAM_RELATIVE_PITCH = 0x6D0858B8EDFA2BCD,
    SET_CAM_ACTIVE                  = 0x026FB97D0A425F84,
    RENDER_SCRIPT_CAMS              = 0x07E5B515DB0636FC,
    CREATE_CAM_WITH_PARAMS          = 0xB51194800B257161,
    SET_CAM_FOV                     = 0xB13C14F66A00D047,
    SET_CAM_NEAR_CLIP               = 0xC7848EFCCC545182,
    DESTROY_CAM                     = 0x865908C81A2C22E9,
    SET_FOLLOW_VEHICLE_CAM_VIEW_MODE = 0xAC253D7842768F48,
    GET_FOLLOW_VEHICLE_CAM_VIEW_MODE = 0xA4FF579AC0E3AAAE,
    SET_FOLLOW_VEHICLE_CAM_ZOOM_LEVEL = 0x19464CB6E4078C8A,
    GET_GAMEPLAY_CAM_FOV            = 0x65019750A0324133,
    IS_CONTROL_JUST_RELEASED        = 0x0C076D25CC7AAE5B,
    GET_VEHICLE_RPM                 = 0xE7B12B54,
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
            dragCoeff           = 0.60,
            camberStiffness     = 0.20,
            rollCenterFront     = 0.80,
            rollCenterRear      = 0.72,
            mass                = 0.82,
            percentSubmerged    = 1.00,
        },
        set = {
            driveBiasFront      = 0.0,
            downforce           = 0.0,      -- force to zero (not multiplied)
        },
        assistStrength  = 0.25,
        assistAngleMin  = 8.0,
        assistAngleMax  = 120.0,
    },
}

-- ============================================================
-- CUSTOM PRESET FILE I/O
-- Saves/loads .lua preset files in scripts/MikzDrift/presets/
-- ============================================================

local SAVE_DIR = this.dir() .. '\\MikzDrift\\presets'

-- Ensure save directory exists
local function ensureSaveDir()
    os.execute('mkdir "' .. SAVE_DIR .. '" 2>nul')
end

-- Serialize a preset table to a saveable string
local function serializePreset(preset)
    local lines = {}
    table.insert(lines, 'return {')
    table.insert(lines, string.format('  name = %q,', preset.name))
    table.insert(lines, string.format('  desc = %q,', preset.desc or 'Custom preset'))
    table.insert(lines, string.format('  assistStrength = %.4f,', preset.assistStrength or 0.50))
    table.insert(lines, string.format('  assistAngleMin = %.1f,', preset.assistAngleMin or 10.0))
    table.insert(lines, string.format('  assistAngleMax = %.1f,', preset.assistAngleMax or 80.0))
    table.insert(lines, '  mult = {')
    if preset.mult then
        -- Sort keys for consistent file output
        local keys = {}
        for k in pairs(preset.mult) do table.insert(keys, k) end
        table.sort(keys)
        for _, k in ipairs(keys) do
            table.insert(lines, string.format('    %s = %.4f,', k, preset.mult[k]))
        end
    end
    table.insert(lines, '  },')
    table.insert(lines, '  set = {')
    if preset.set then
        local keys = {}
        for k in pairs(preset.set) do table.insert(keys, k) end
        table.sort(keys)
        for _, k in ipairs(keys) do
            table.insert(lines, string.format('    %s = %.4f,', k, preset.set[k]))
        end
    end
    table.insert(lines, '  },')
    table.insert(lines, '}')
    return table.concat(lines, '\n')
end

-- Save a preset to a .lua file
local function savePresetToFile(preset)
    ensureSaveDir()
    -- Sanitize filename: only alphanumeric and underscores
    local filename = preset.name:gsub('[^%w ]', ''):gsub(' ', '_')
    local path = SAVE_DIR .. '\\' .. filename .. '.lua'
    local f = io.open(path, 'w')
    if not f then
        notify.push('MikzDrift', 'Failed to save: could not write file')
        return false
    end
    f:write('-- MikzDrift Custom Preset\n')
    f:write('-- ' .. preset.name .. '\n\n')
    f:write(serializePreset(preset))
    f:close()
    return true
end

-- Load a single preset from a .lua file
local function loadPresetFromFile(path)
    local fn, err = loadfile(path)
    if not fn then
        return nil, err
    end
    local ok, result = pcall(fn)
    if not ok or type(result) ~= 'table' then
        return nil, 'Invalid preset file'
    end
    -- Validate required fields
    if not result.name or not result.mult then
        return nil, 'Missing name or mult table'
    end
    -- Ensure set table exists
    if not result.set then
        result.set = { driveBiasFront = 0.0 }
    end
    result.isCustom = true
    return result
end

-- List all .lua files in the presets folder
local function listPresetFiles()
    ensureSaveDir()
    local files = {}
    local handle = io.popen('dir "' .. SAVE_DIR .. '\\*.lua" /b 2>nul')
    if handle then
        for line in handle:lines() do
            if line:match('%.lua$') then
                table.insert(files, line)
            end
        end
        handle:close()
    end
    return files
end

-- Load all saved custom presets from disk
local function loadAllCustomPresets()
    local files = listPresetFiles()
    local loaded = {}
    for _, filename in ipairs(files) do
        local path = SAVE_DIR .. '\\' .. filename
        local preset, err = loadPresetFromFile(path)
        if preset then
            table.insert(loaded, preset)
        end
    end
    return loaded
end

-- Delete a preset file by name
local function deletePresetFile(presetName)
    local filename = presetName:gsub('[^%w ]', ''):gsub(' ', '_')
    local path = SAVE_DIR .. '\\' .. filename .. '.lua'
    return os.remove(path)
end

-- Number of built-in presets (used to tell built-in from custom)
local BUILTIN_COUNT = #PRESETS

-- Load saved custom presets and append to PRESETS
local function reloadCustomPresets()
    -- Remove old custom presets (keep only built-ins)
    while #PRESETS > BUILTIN_COUNT do
        table.remove(PRESETS)
    end
    -- Load from disk and append
    local customs = loadAllCustomPresets()
    for _, p in ipairs(customs) do
        table.insert(PRESETS, p)
    end
    return #customs
end

-- Initial load
reloadCustomPresets()

-- ============================================================
-- STATE
-- ============================================================

local currentPreset     = 1
local driftActive       = false
local originalHandling  = nil
local lastVehicle       = nil

-- Feature toggles
local counterSteerEnabled   = true
local hudEnabled            = true
local tireSmokeEnabled      = true
local angleTrackEnabled     = true
local throttleModEnabled    = true
local handbrakeBoostEnabled = true
local autoApplyEnabled      = true
local driftCameraEnabled    = false
local backfireEnabled       = true
local angleSmokeColorEnabled = false   -- angle-based smoke color mode
local useKMH                = false    -- false = MPH, true = KM/H
local personalBestNotify    = true

-- Drift angle state
local currentAngle      = 0.0
local peakAngle         = 0.0
local isDrifting        = false
local driftStartTime    = 0
local driftDuration     = 0.0
local driftScore        = 0
local comboMultiplier   = 1.0
local comboTimer        = -1
local totalScore        = 0

-- Session stats
local sessionStats = {
    longestDrift    = 0.0,      -- seconds
    fastestSpeed    = 0.0,      -- m/s during drift
    totalDrifts     = 0,        -- number of drift entries
    totalAngle      = 0.0,      -- sum of angles (for average)
    angleSamples    = 0,        -- sample count (for average)
    bestAngle       = 0.0,
    bestCombo       = 0,
    bestScore       = 0,
}

-- Auto-apply per car: model hash -> preset index
local carPresetMap = {}

-- Smoke FX state
local smokeHandles      = {}
local ptfxLoaded        = false
local smokeColor        = { r = 255, g = 255, b = 255 }

-- Handbrake boost state
local handbrakeBoostActive = false
local handbrakeBoostTimer  = 0

-- (drift camera uses gameplay cam natives directly, no state needed)

-- Backfire state
local backfirePtfxLoaded = false
local lastThrottle       = 0.0
local backfireCooldown   = 0

-- AWD drift bias (0.0 = RWD, 0.1 = 10/90, etc.)
local awdDriveBias      = 0.0

-- Keyboard hotkey (virtual key code for C)
local CYCLE_PRESET_VK   = 0x43  -- VK_C

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
-- Does NOT touch driftActive — caller is responsible for that.
local function restoreHandling(vehicle)
    if not originalHandling then return end
    -- Only write to vehicle if it still exists
    if vehicle and invoker.call(N.DOES_ENTITY_EXIST, vehicle).bool then
        for _, e in ipairs(HANDLING_FIELDS) do
            if originalHandling[e.key] then
                invoker.call(N.SET_VEHICLE_HANDLING_FLOAT, vehicle, joaat('CHandlingData'), joaat(e.field), originalHandling[e.key])
            end
        end
    end
    originalHandling = nil
end

-- Reset all drift tracking state (angle, score, combo, flags)
local function resetDriftState()
    isDrifting = false
    currentAngle = 0.0
    peakAngle = 0.0
    driftScore = 0
    comboMultiplier = 1.0
    comboTimer = -1
    driftDuration = 0.0
    handbrakeBoostActive = false
    handbrakeBoostTimer = 0
    lastThrottle = 0.0
    backfireCooldown = 0
end

-- Forward declaration: disableDrift is defined after stopSmoke
local disableDrift

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

-- Forward declarations (defined later in the file)
local updateSessionStats
local onDriftStart
local onDriftEnd
local getAngleSmokeColor

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
            onDriftStart()
            -- Continue combo if within timeout
            if comboTimer < 0 or (now - comboTimer) > COMBO_TIMEOUT then
                comboMultiplier = 1.0
                driftScore = 0
            end
        end

        -- Feed session stats
        updateSessionStats(vehicle)

        -- Track peak angle this drift
        if absAngle > peakAngle then
            peakAngle = absAngle
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
            totalScore = math.min(totalScore + math.floor(driftScore), 999999999)

            -- Session stats + personal best notifications
            onDriftEnd(driftDuration, driftScore, peakAngle)
            peakAngle = 0.0
        end

        -- Reset combo after timeout
        if comboTimer >= 0 and (now - comboTimer) > COMBO_TIMEOUT and not isDrifting then
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
    -- Always verify the asset is still loaded (game can stream it out)
    if invoker.call(N.HAS_NAMED_PTFX_ASSET_LOADED, PTFX_DICT).bool then
        ptfxLoaded = true
        return true
    end
    -- Asset was unloaded or never loaded — request it
    ptfxLoaded = false
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

-- Full cleanup: restore handling, stop effects, reset state
-- Defined here (after stopSmoke) to avoid forward reference issues
disableDrift = function()
    if lastVehicle then
        restoreHandling(lastVehicle)
    end
    stopSmoke()
    driftActive = false
    lastVehicle = nil
    resetDriftState()
end

local function updateSmokeScale(absAngle, speed)
    if #smokeHandles == 0 then return end
    -- Scale smoke intensity with drift angle and speed
    local angleFactor = clamp(absAngle / 60.0, 0.2, 1.0)
    local speedFactor = clamp(speed / 25.0, 0.3, 1.0)
    local scale = 0.3 + (angleFactor * speedFactor * 1.2)
    for _, handle in ipairs(smokeHandles) do
        invoker.call(N.SET_PARTICLE_FX_LOOPED_SCALE, handle, scale)

        -- Update color: angle-based or static
        if angleSmokeColorEnabled then
            local r, g, b = getAngleSmokeColor(absAngle)
            invoker.call(N.SET_PARTICLE_FX_LOOPED_COLOUR, handle,
                r / 255.0, g / 255.0, b / 255.0, false)
        end
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
-- AUTO-APPLY PER CAR
-- ============================================================

local function getVehicleModelHash(vehicle)
    return invoker.call(N.GET_ENTITY_MODEL, vehicle).int
end

local function rememberCarPreset(vehicle, presetIdx)
    local hash = getVehicleModelHash(vehicle)
    if hash and hash ~= 0 and PRESETS[presetIdx] then
        -- Store preset name instead of index to survive preset list changes
        carPresetMap[hash] = PRESETS[presetIdx].name
    end
end

local function getRememberedPreset(vehicle)
    local hash = getVehicleModelHash(vehicle)
    if not hash or not carPresetMap[hash] then return nil end

    local name = carPresetMap[hash]
    -- Find the preset by name (index may have shifted)
    for i, p in ipairs(PRESETS) do
        if p.name == name then
            return i
        end
    end
    -- Preset was deleted, clear the stale entry
    carPresetMap[hash] = nil
    return nil
end

-- ============================================================
-- SESSION STATS
-- ============================================================

updateSessionStats = function(vehicle)
    if not isDrifting then return end

    local speed = invoker.call(N.GET_ENTITY_SPEED, vehicle).float
    local absAngle = math.abs(currentAngle)

    -- Fastest speed during drift
    if speed > sessionStats.fastestSpeed then
        sessionStats.fastestSpeed = speed
    end

    -- Angle sampling for average (cap to prevent overflow on long sessions)
    if sessionStats.angleSamples < 10000000 then
        sessionStats.totalAngle = sessionStats.totalAngle + absAngle
        sessionStats.angleSamples = sessionStats.angleSamples + 1
    end
end

onDriftStart = function()
    sessionStats.totalDrifts = sessionStats.totalDrifts + 1
end

onDriftEnd = function(duration, score, peak)
    -- Longest drift
    if duration > sessionStats.longestDrift then
        sessionStats.longestDrift = duration
    end

    -- Best score
    if score > sessionStats.bestScore then
        sessionStats.bestScore = score
    end

    -- Best angle
    local newBestAngle = false
    if peak > sessionStats.bestAngle then
        sessionStats.bestAngle = peak
        newBestAngle = true
    end

    -- Best combo
    local newBestCombo = false
    if math.floor(score) > sessionStats.bestCombo then
        sessionStats.bestCombo = math.floor(score)
        newBestCombo = true
    end

    -- Personal best notifications (skip trivial first-drift bests)
    if personalBestNotify and sessionStats.totalDrifts > 1 then
        if newBestAngle and peak > 15.0 then
            notify.push('MikzDrift', string.format('New best angle! %.1f\xC2\xB0', peak), { time = 3000 })
        end
        if newBestCombo and math.floor(score) > 500 then
            notify.push('MikzDrift', string.format('New best combo! %d pts', math.floor(score)), { time = 3000 })
        end
    end
end

local function resetSessionStats()
    sessionStats.longestDrift = 0.0
    sessionStats.fastestSpeed = 0.0
    sessionStats.totalDrifts = 0
    sessionStats.totalAngle = 0.0
    sessionStats.angleSamples = 0
    sessionStats.bestAngle = 0.0
    sessionStats.bestCombo = 0
    sessionStats.bestScore = 0
end

local function getAverageAngle()
    if sessionStats.angleSamples > 0 then
        return sessionStats.totalAngle / sessionStats.angleSamples
    end
    return 0.0
end

-- ============================================================
-- HANDBRAKE BOOST
-- ============================================================

local function doHandbrakeBoost(vehicle)
    if not handbrakeBoostEnabled or not driftActive then return end

    local now = getGameTime()
    local handbrakePressed = invoker.call(N.IS_CONTROL_PRESSED, 0, 76).bool -- INPUT_VEH_HANDBRAKE

    if handbrakePressed and not handbrakeBoostActive then
        -- Initiate boost: lateral kick to start the slide
        handbrakeBoostActive = true
        handbrakeBoostTimer = now

        local speed = invoker.call(N.GET_ENTITY_SPEED, vehicle).float
        if speed > 5.0 then
            local steer = invoker.call(N.GET_CONTROL_NORMAL, 0, 59).float
            local kickForce = clamp(steer * 1.8 * (speed / 20.0), -3.0, 3.0)

            invoker.call(N.APPLY_FORCE_TO_ENTITY,
                vehicle, 1,
                kickForce, -0.3, 0.0,
                0.0, -2.0, 0.0,
                0, true, true, true, false, true
            )
        end
    elseif handbrakePressed and handbrakeBoostActive then
        -- Fade out after 400ms
        if now - handbrakeBoostTimer > 400 then
            handbrakeBoostActive = false
        end
    else
        handbrakeBoostActive = false
    end
end

-- ============================================================
-- DRIFT CAMERA
-- ============================================================

local function updateDriftCamera(vehicle)
    if not driftCameraEnabled or not driftActive then return end

    local absAngle = math.abs(currentAngle)
    local speed = invoker.call(N.GET_ENTITY_SPEED, vehicle).float

    if absAngle > 10.0 and speed > 5.0 then
        -- Lock camera to closest zoom for a tighter chase feel
        invoker.call(N.SET_FOLLOW_VEHICLE_CAM_ZOOM_LEVEL, 0)

        -- Offset camera heading slightly towards the drift direction
        -- This creates a looser, more cinematic follow
        local headingOffset = clamp(currentAngle * 0.08, -6.0, 6.0)
        invoker.call(N.SET_GAMEPLAY_CAM_RELATIVE_HEADING, headingOffset)
    end
end

-- ============================================================
-- BACKFIRE / ANTI-LAG POPS
-- ============================================================

local BACKFIRE_PTFX_DICT = 'core'
local BACKFIRE_PTFX_NAME = 'veh_backfire'

local function loadBackfirePtfx()
    if backfirePtfxLoaded then
        if invoker.call(N.HAS_NAMED_PTFX_ASSET_LOADED, BACKFIRE_PTFX_DICT).bool then
            return true
        end
        backfirePtfxLoaded = false
    end
    invoker.call(N.REQUEST_NAMED_PTFX_ASSET, BACKFIRE_PTFX_DICT)
    if invoker.call(N.HAS_NAMED_PTFX_ASSET_LOADED, BACKFIRE_PTFX_DICT).bool then
        backfirePtfxLoaded = true
        return true
    end
    return false
end

local function doBackfire(vehicle)
    if not backfireEnabled or not driftActive then return end

    local now = getGameTime()
    if now < backfireCooldown then return end

    local throttle = invoker.call(N.GET_CONTROL_NORMAL, 0, 71).float
    local speed = invoker.call(N.GET_ENTITY_SPEED, vehicle).float

    -- Trigger on throttle lift while at speed and angle
    local absAngle = math.abs(currentAngle)
    if lastThrottle > 0.7 and throttle < 0.3 and speed > 8.0 and absAngle > 15.0 then
        if loadBackfirePtfx() then
            local exhaustBone = invoker.call(N.GET_ENTITY_BONE_INDEX_BY_NAME, vehicle, 'exhaust').int
            if exhaustBone ~= -1 then
                invoker.call(N.USE_PARTICLE_FX_ASSET, BACKFIRE_PTFX_DICT)
                invoker.call(N.START_PARTICLE_FX_NON_LOOPED_ON_ENTITY,
                    BACKFIRE_PTFX_NAME, vehicle,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    1.0,
                    false, false, false,
                    exhaustBone
                )

                -- Also try exhaust_2 for dual exhaust cars
                local exhaust2 = invoker.call(N.GET_ENTITY_BONE_INDEX_BY_NAME, vehicle, 'exhaust_2').int
                if exhaust2 ~= -1 then
                    invoker.call(N.USE_PARTICLE_FX_ASSET, BACKFIRE_PTFX_DICT)
                    invoker.call(N.START_PARTICLE_FX_NON_LOOPED_ON_ENTITY,
                        BACKFIRE_PTFX_NAME, vehicle,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        1.0,
                        false, false, false,
                        exhaust2
                    )
                end
            end
            backfireCooldown = now + 150 + math.random(0, 200)
        end
    end

    lastThrottle = throttle
end

-- ============================================================
-- ANGLE-BASED SMOKE COLOR
-- ============================================================

getAngleSmokeColor = function(absAngle)
    if absAngle < 20.0 then
        -- White
        return 255, 255, 255
    elseif absAngle < 40.0 then
        -- White -> Yellow
        local t = (absAngle - 20.0) / 20.0
        return 255, math.floor(255 - t * 35), math.floor(255 - t * 205)
    elseif absAngle < 60.0 then
        -- Yellow -> Orange
        local t = (absAngle - 40.0) / 20.0
        return 255, math.floor(220 - t * 80), math.floor(50 - t * 20)
    else
        -- Orange -> Red
        local t = clamp((absAngle - 60.0) / 30.0, 0.0, 1.0)
        return 255, math.floor(140 - t * 100), math.floor(30 - t * 30)
    end
end

-- ============================================================
-- KEYBOARD HOTKEY
-- ============================================================

local function handleKeyboardHotkey()
    -- C key to cycle presets (only when drift is active)
    if not driftActive then return end

    local key = input.keyboard(CYCLE_PRESET_VK)
    if key.just_pressed then
        currentPreset = currentPreset + 1
        if currentPreset > #PRESETS then currentPreset = 1 end

        local vehicle = getPlayerVehicle()
        if vehicle then
            applyDriftPreset(vehicle, PRESETS[currentPreset])
            -- Re-apply AWD bias after preset switch
            if awdDriveBias > 0 then
                invoker.call(N.SET_VEHICLE_HANDLING_FLOAT, vehicle,
                    joaat('CHandlingData'), joaat('fDriveBiasFront'), awdDriveBias)
            end
            if autoApplyEnabled then
                rememberCarPreset(vehicle, currentPreset)
            end
        end
        notify.push('MikzDrift', 'Preset: ' .. PRESETS[currentPreset].name)
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
    local displaySpeed = useKMH and (speed * 3.6) or (speed * 2.237)
    local speedUnit = useKMH and 'KM/H' or 'MPH'
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
    gui.text(string.format('%.0f %s', displaySpeed, speedUnit))
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
    local statsH = 36.0

    gui.rect(vec2(barX, statsY), vec2(barW, statsH))
        :filled()
        :color(color(10, 10, 10, 140))
        :rounding(4.0)
        :draw()

    -- Row 1: score totals
    gui.text(string.format('Total: %d', totalScore))
        :position(vec2(barX + 10.0, statsY + 2.0))
        :color(color(160, 160, 160, 200))
        :scale(0.55)
        :draw()

    gui.text(string.format('Best: %.1f\xC2\xB0', sessionStats.bestAngle))
        :position(vec2(barX + 120.0, statsY + 2.0))
        :color(color(160, 160, 160, 200))
        :scale(0.55)
        :draw()

    gui.text(string.format('Best Combo: %d', sessionStats.bestCombo))
        :position(vec2(barX + 240.0, statsY + 2.0))
        :color(color(160, 160, 160, 200))
        :scale(0.55)
        :draw()

    -- Row 2: session stats
    local fastDisplay = useKMH and (sessionStats.fastestSpeed * 3.6) or (sessionStats.fastestSpeed * 2.237)
    gui.text(string.format('Drifts: %d', sessionStats.totalDrifts))
        :position(vec2(barX + 10.0, statsY + 18.0))
        :color(color(130, 130, 130, 180))
        :scale(0.5)
        :draw()

    gui.text(string.format('Longest: %.1fs', sessionStats.longestDrift))
        :position(vec2(barX + 100.0, statsY + 18.0))
        :color(color(130, 130, 130, 180))
        :scale(0.5)
        :draw()

    gui.text(string.format('Fastest: %.0f %s', fastDisplay, speedUnit))
        :position(vec2(barX + 210.0, statsY + 18.0))
        :color(color(130, 130, 130, 180))
        :scale(0.5)
        :draw()

    gui.text(string.format('Avg: %.1f\xC2\xB0', getAverageAngle()))
        :position(vec2(barX + 330.0, statsY + 18.0))
        :color(color(130, 130, 130, 180))
        :scale(0.5)
        :draw()
end

-- ============================================================
-- LEXIS MENU
-- ============================================================

local root = menu.root()
local driftMenu = root:submenu('MikzDrift')

-- Helper: rebuild the preset selector list (called after adding/removing custom presets)
local presetSelectorOpt = nil

local function rebuildPresetList()
    if not presetSelectorOpt then return end
    local list = {}
    for i, p in ipairs(PRESETS) do
        local prefix = (i > BUILTIN_COUNT) and '[Custom] ' or ''
        list[i] = { prefix .. p.name, i }
    end
    presetSelectorOpt:list(list)
    -- Clamp current selection
    if currentPreset > #PRESETS then
        currentPreset = 1
    end
end

-- ---- Presets submenu ----
local presetsMenu = driftMenu:submenu('Drift Presets')

local presetList = {}
for i, p in ipairs(PRESETS) do
    local prefix = (i > BUILTIN_COUNT) and '[Custom] ' or ''
    presetList[i] = { prefix .. p.name, i }
end

presetSelectorOpt = presetsMenu:combo_int('Active Preset', presetList, menu.type.scroll)
    :tooltip('Select drift preset (built-in or custom)')
    :event(menu.event.click, function(opt)
        currentPreset = opt.list:at(opt.value).value
        if driftActive then
            local vehicle = getPlayerVehicle()
            if vehicle then
                applyDriftPreset(vehicle, PRESETS[currentPreset])
                -- Re-apply AWD bias after preset switch
                if awdDriveBias > 0 then
                    invoker.call(N.SET_VEHICLE_HANDLING_FLOAT, vehicle,
                        joaat('CHandlingData'), joaat('fDriveBiasFront'), awdDriveBias)
                end
                notify.push('MikzDrift', 'Applied: ' .. PRESETS[currentPreset].name)
            end
        end
    end)

-- Add info buttons for built-in presets
for _, p in ipairs(PRESETS) do
    if not p.isCustom then
        presetsMenu:button(p.name .. ' - Info')
            :tooltip(p.desc)
            :event(menu.event.click, function()
                notify.push('MikzDrift', p.name .. ': ' .. p.desc, { time = 4000 })
            end)
    end
end

-- ---- Custom Presets submenu ----
local customMenu = driftMenu:submenu('Custom Presets')

-- Editing state for the custom preset builder
local editPreset = {
    name            = 'My Preset',
    desc            = 'Custom drift preset',
    assistStrength  = 0.50,
    assistAngleMin  = 10.0,
    assistAngleMax  = 80.0,
    mult = {
        tractionMin         = 0.70,
        tractionMax         = 0.75,
        tractionLateral     = 0.90,
        tractionBiasFront   = 1.08,
        tractionLossMult    = 1.50,
        lowSpeedTractionLoss = 1.60,
        driveForce          = 1.20,
        driveInertia        = 1.10,
        topSpeed            = 1.00,
        steeringLock        = 1.35,
        brakeForce          = 0.90,
        brakeBiasFront      = 1.00,
        handBrakeForce      = 1.50,
        suspForce           = 1.20,
        suspCompDamp        = 1.15,
        suspReboundDamp     = 1.20,
        suspUpperLimit      = 0.75,
        suspLowerLimit      = 0.85,
        suspBiasFront       = 0.97,
        antiRollBar         = 0.70,
        antiRollBiasFront   = 1.00,
        downforce           = 0.40,
        dragCoeff           = 0.85,
        camberStiffness     = 0.60,
        rollCenterFront     = 0.95,
        rollCenterRear      = 0.90,
        mass                = 0.92,
        percentSubmerged    = 1.00,
    },
    set = {
        driveBiasFront      = 0.0,
    },
}

-- ---- Create / Edit submenu ----
local createMenu = customMenu:submenu('Create New Preset')

-- Slider definitions: { label, key, min, max, step, tooltip }
local SLIDER_DEFS = {
    { 'Traction',           {
        { 'Traction Min',           'tractionMin',          0.10, 1.50, 0.01, 'Rear grip (lower = more slide)' },
        { 'Traction Max',           'tractionMax',          0.10, 1.50, 0.01, 'Peak grip multiplier' },
        { 'Traction Lateral',       'tractionLateral',      0.50, 1.20, 0.01, 'Sideways grip' },
        { 'Traction Bias Front',    'tractionBiasFront',    0.90, 1.30, 0.01, 'Front grip bias (higher = more front grip, rear slides easier)' },
        { 'Traction Loss',          'tractionLossMult',     0.50, 3.00, 0.05, 'How fast grip is lost (higher = more slide)' },
        { 'Low Speed Traction Loss','lowSpeedTractionLoss', 0.50, 3.00, 0.05, 'Grip loss at low speed' },
    }},
    { 'Drivetrain',         {
        { 'Drive Force',            'driveForce',           0.50, 2.50, 0.05, 'Engine power multiplier' },
        { 'Drive Inertia',          'driveInertia',         0.50, 2.00, 0.05, 'Drivetrain responsiveness' },
        { 'Top Speed',              'topSpeed',             0.50, 1.50, 0.01, 'Top speed multiplier' },
    }},
    { 'Steering',           {
        { 'Steering Lock',          'steeringLock',         1.00, 2.50, 0.05, 'Max steering angle (higher = more angle)' },
    }},
    { 'Brakes',             {
        { 'Brake Force',            'brakeForce',           0.30, 1.20, 0.05, 'Brake power' },
        { 'Brake Bias Front',       'brakeBiasFront',       0.70, 1.20, 0.05, 'Front brake bias' },
        { 'Handbrake Force',        'handBrakeForce',       0.50, 3.00, 0.05, 'Handbrake strength for initiating' },
    }},
    { 'Suspension',         {
        { 'Suspension Force',       'suspForce',            0.50, 2.00, 0.05, 'Suspension stiffness' },
        { 'Compression Damp',       'suspCompDamp',         0.50, 2.00, 0.05, 'Compression damping' },
        { 'Rebound Damp',           'suspReboundDamp',      0.50, 2.00, 0.05, 'Rebound damping' },
        { 'Upper Limit',            'suspUpperLimit',       0.30, 1.20, 0.05, 'Max suspension extension' },
        { 'Lower Limit',            'suspLowerLimit',       0.30, 1.20, 0.05, 'Max suspension compression' },
        { 'Susp. Bias Front',       'suspBiasFront',        0.70, 1.20, 0.01, 'Front suspension bias' },
        { 'Anti-Roll Bar',          'antiRollBar',          0.10, 1.50, 0.05, 'Anti-roll stiffness (lower = more body roll)' },
        { 'Anti-Roll Bias Front',   'antiRollBiasFront',    0.70, 1.20, 0.01, 'Front anti-roll bias' },
    }},
    { 'Aero & Weight',      {
        { 'Downforce',              'downforce',            0.00, 1.50, 0.05, 'Downforce (lower = less grip at speed)' },
        { 'Drag',                   'dragCoeff',            0.30, 1.50, 0.05, 'Air drag multiplier' },
        { 'Camber Stiffness',       'camberStiffness',      0.10, 1.20, 0.05, 'Wheel camber stiffness' },
        { 'Roll Center Front',      'rollCenterFront',      0.50, 1.20, 0.05, 'Front roll center height' },
        { 'Roll Center Rear',       'rollCenterRear',       0.50, 1.20, 0.05, 'Rear roll center height' },
        { 'Mass',                   'mass',                 0.60, 1.30, 0.01, 'Vehicle weight multiplier' },
    }},
    { 'Assist',             {
        { 'Counter-Steer Strength', 'assistStrength',       0.00, 1.00, 0.05, 'Controller counter-steer assist strength' },
        { 'Assist Angle Min',       'assistAngleMin',       5.0,  30.0, 1.0,  'Min drift angle before assist kicks in' },
        { 'Assist Angle Max',       'assistAngleMax',       50.0, 150.0, 5.0, 'Max drift angle where assist still works' },
    }},
}

-- Build slider sub-menus for each category
for _, category in ipairs(SLIDER_DEFS) do
    local catName = category[1]
    local sliders = category[2]
    local catMenu = createMenu:submenu(catName)

    for _, slider in ipairs(sliders) do
        local label, key, sMin, sMax, step, tip = slider[1], slider[2], slider[3], slider[4], slider[5], slider[6]

        -- Determine which table to read/write
        -- Keys that live on editPreset root (not in .mult)
        local isRootKey = (key == 'assistStrength' or key == 'assistAngleMin' or key == 'assistAngleMax')

        -- Calculate integer range for slider (Lexis uses integer sliders)
        local steps = math.floor((sMax - sMin) / step + 0.5)
        local defaultIdx = 0
        if isRootKey then
            defaultIdx = math.floor(((editPreset[key] or sMin) - sMin) / step + 0.5)
        else
            defaultIdx = math.floor(((editPreset.mult[key] or 1.0) - sMin) / step + 0.5)
        end
        defaultIdx = math.max(0, math.min(steps, defaultIdx))

        catMenu:slider_int(label, 0, steps, defaultIdx)
            :tooltip(tip .. string.format(' (%.2f - %.2f)', sMin, sMax))
            :event(menu.event.click, function(opt)
                local val = sMin + opt.value * step
                val = math.floor(val * 10000 + 0.5) / 10000 -- round to 4 decimals
                if isRootKey then
                    editPreset[key] = val
                else
                    editPreset.mult[key] = val
                end
            end)
    end
end

-- Live preview toggle
local livePreview = false
createMenu:toggle('Live Preview')
    :tooltip('Apply changes in real-time while tuning (must be in vehicle with drift enabled)')
    :event(menu.event.click, function(opt)
        livePreview = opt.value
        if opt.value then
            local vehicle = getPlayerVehicle()
            if vehicle and driftActive then
                applyDriftPreset(vehicle, editPreset)
                notify.push('MikzDrift', 'Live preview ON')
            else
                notify.push('MikzDrift', 'Enable drift on a vehicle first')
                opt.value = false
                livePreview = false
            end
        end
    end)

-- Apply preview button
createMenu:button('Apply Preview')
    :tooltip('Apply current slider values to your vehicle')
    :event(menu.event.click, function()
        local vehicle = getPlayerVehicle()
        if vehicle and driftActive then
            applyDriftPreset(vehicle, editPreset)
            notify.push('MikzDrift', 'Preview applied')
        else
            notify.push('MikzDrift', 'Enable drift on a vehicle first')
        end
    end)

-- Copy from existing preset
local copyList = {}
for i, p in ipairs(PRESETS) do
    copyList[i] = { p.name, i }
end
createMenu:combo_int('Copy From', copyList, menu.type.scroll)
    :tooltip('Copy all values from a built-in or saved preset as a starting point')
    :event(menu.event.click, function(opt)
        local idx = opt.list:at(opt.value).value
        local source = PRESETS[idx]
        if source then
            -- Deep copy mult table
            editPreset.mult = {}
            if source.mult then
                for k, v in pairs(source.mult) do
                    editPreset.mult[k] = v
                end
            end
            -- Deep copy set table
            editPreset.set = {}
            if source.set then
                for k, v in pairs(source.set) do
                    editPreset.set[k] = v
                end
            end
            editPreset.assistStrength = source.assistStrength or 0.50
            editPreset.assistAngleMin = source.assistAngleMin or 10.0
            editPreset.assistAngleMax = source.assistAngleMax or 80.0
            notify.push('MikzDrift', 'Copied from: ' .. source.name .. ' (sliders not updated, values applied internally)')
        end
    end)

-- Save button
createMenu:button('Save Preset')
    :tooltip('Save the current tuning as a custom preset file')
    :event(menu.event.click, function()
        -- Build the final preset to save
        local toSave = {
            name = editPreset.name,
            desc = editPreset.desc or 'Custom preset',
            assistStrength = editPreset.assistStrength,
            assistAngleMin = editPreset.assistAngleMin,
            assistAngleMax = editPreset.assistAngleMax,
            mult = {},
            set = {},
            isCustom = true,
        }
        for k, v in pairs(editPreset.mult) do
            toSave.mult[k] = v
        end
        for k, v in pairs(editPreset.set) do
            toSave.set[k] = v
        end
        -- Always force RWD
        toSave.set.driveBiasFront = 0.0

        if savePresetToFile(toSave) then
            -- Reload and rebuild
            reloadCustomPresets()
            rebuildPresetList()
            notify.push('MikzDrift', 'Saved: ' .. toSave.name, { time = 3000 })
        end
    end)

-- Preset name input (using a text option)
createMenu:text_input('Preset Name', editPreset.name)
    :tooltip('Set the name for your custom preset')
    :event(menu.event.click, function(opt)
        editPreset.name = opt.value
    end)

-- ---- Manage Saved submenu ----
local manageMenu = customMenu:submenu('Manage Saved')

manageMenu:button('Reload From Disk')
    :tooltip('Reload all custom presets from the MikzDrift/presets folder')
    :event(menu.event.click, function()
        local count = reloadCustomPresets()
        rebuildPresetList()
        notify.push('MikzDrift', 'Loaded ' .. count .. ' custom preset(s)')
    end)

-- Delete preset selector
local function buildDeleteList()
    local list = {}
    local idx = 1
    for i = BUILTIN_COUNT + 1, #PRESETS do
        list[idx] = { PRESETS[i].name, i }
        idx = idx + 1
    end
    return list
end

local deleteList = buildDeleteList()
if #deleteList > 0 then
    manageMenu:combo_int('Select to Delete', deleteList, menu.type.scroll)
        :tooltip('Select a custom preset to delete')
        :event(menu.event.click, function(opt)
            local entry = opt.list:at(opt.value)
            if entry then
                local preset = PRESETS[entry.value]
                if preset and preset.isCustom then
                    deletePresetFile(preset.name)
                    reloadCustomPresets()
                    rebuildPresetList()
                    notify.push('MikzDrift', 'Deleted: ' .. preset.name)
                end
            end
        end)
else
    manageMenu:button('No custom presets saved')
        :tooltip('Create and save a preset first')
end

-- Open folder button
manageMenu:button('Open Presets Folder')
    :tooltip('Open the MikzDrift presets folder in Explorer')
    :event(menu.event.click, function()
        ensureSaveDir()
        os.execute('explorer "' .. SAVE_DIR .. '"')
    end)

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
            -- Apply AWD bias if set
            if awdDriveBias > 0 then
                invoker.call(N.SET_VEHICLE_HANDLING_FLOAT, vehicle,
                    joaat('CHandlingData'), joaat('fDriveBiasFront'), awdDriveBias)
            end
            driftActive = true
            resetDriftState()
            -- Remember for auto-apply
            if autoApplyEnabled then
                rememberCarPreset(vehicle, currentPreset)
            end
            notify.push('MikzDrift', 'Drift ON - ' .. PRESETS[currentPreset].name)
        else
            disableDrift()
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

assistMenu:toggle('Handbrake Boost')
    :tooltip('Extra kick when pulling handbrake to help initiate drifts')
    :value(handbrakeBoostEnabled)
    :event(menu.event.click, function(opt)
        handbrakeBoostEnabled = opt.value
        notify.push('MikzDrift', 'Handbrake boost: ' .. (opt.value and 'ON' or 'OFF'))
    end)

-- AWD drift option
assistMenu:slider_int('Drive Bias (AWD)', 0, 10, 0)
    :tooltip('0 = Pure RWD, 1-10 = front drive % (e.g. 2 = 20/80 AWD split)')
    :event(menu.event.click, function(opt)
        awdDriveBias = opt.value / 10.0
        -- Update the driveBiasFront override in all presets' set tables
        -- and re-apply if drift is active
        if driftActive then
            local vehicle = getPlayerVehicle()
            if vehicle then
                invoker.call(N.SET_VEHICLE_HANDLING_FLOAT, vehicle,
                    joaat('CHandlingData'), joaat('fDriveBiasFront'), awdDriveBias)
            end
        end
        if awdDriveBias == 0.0 then
            notify.push('MikzDrift', 'Drive: Pure RWD')
        else
            notify.push('MikzDrift', string.format('Drive: %d/%d AWD', math.floor(awdDriveBias * 100), 100 - math.floor(awdDriveBias * 100)))
        end
    end)

assistMenu:toggle('Auto-Apply Per Car')
    :tooltip('Remember which preset you used on each car model and auto-apply')
    :value(autoApplyEnabled)
    :event(menu.event.click, function(opt)
        autoApplyEnabled = opt.value
        notify.push('MikzDrift', 'Auto-apply: ' .. (opt.value and 'ON' or 'OFF'))
    end)

assistMenu:button('Clear Remembered Cars')
    :tooltip('Forget all per-car preset assignments')
    :event(menu.event.click, function()
        carPresetMap = {}
        notify.push('MikzDrift', 'Cleared all remembered car presets')
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

visualMenu:toggle('Angle-Based Smoke Color')
    :tooltip('Smoke changes color with drift angle (white -> yellow -> orange -> red)')
    :value(angleSmokeColorEnabled)
    :event(menu.event.click, function(opt)
        angleSmokeColorEnabled = opt.value
        if not opt.value then stopSmoke() end -- reset to static color
        notify.push('MikzDrift', 'Angle smoke color: ' .. (opt.value and 'ON' or 'OFF'))
    end)

-- Smoke color options (for static mode)
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

visualMenu:combo_int('Smoke Color (Static)', smokeColorList, menu.type.scroll)
    :tooltip('Static smoke color (used when angle-based color is off)')
    :event(menu.event.click, function(opt)
        local idx = opt.list:at(opt.value).value
        smokeColor = smokeColors[idx][2]
        stopSmoke()
        notify.push('MikzDrift', 'Smoke: ' .. smokeColors[idx][1])
    end)

visualMenu:toggle('Backfire / Anti-Lag')
    :tooltip('Exhaust pops on throttle lift during drifts')
    :value(backfireEnabled)
    :event(menu.event.click, function(opt)
        backfireEnabled = opt.value
        notify.push('MikzDrift', 'Backfire: ' .. (opt.value and 'ON' or 'OFF'))
    end)

visualMenu:toggle('Drift Camera')
    :tooltip('Wider FOV during drifts for a cinematic feel')
    :value(driftCameraEnabled)
    :event(menu.event.click, function(opt)
        driftCameraEnabled = opt.value
        notify.push('MikzDrift', 'Drift camera: ' .. (opt.value and 'ON' or 'OFF'))
    end)

-- ---- HUD submenu ----
local hudMenu = driftMenu:submenu('HUD & Scoring')

hudMenu:toggle('Show HUD')
    :tooltip('Display drift HUD with angle, speed, score, and session stats')
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

hudMenu:toggle('Personal Best Notifications')
    :tooltip('Show popup when you beat your best angle or combo')
    :value(personalBestNotify)
    :event(menu.event.click, function(opt)
        personalBestNotify = opt.value
    end)

hudMenu:combo_int('Speed Unit', { { 'MPH', 1 }, { 'KM/H', 2 } }, menu.type.scroll)
    :tooltip('Switch between MPH and KM/H')
    :event(menu.event.click, function(opt)
        local idx = opt.list:at(opt.value).value
        useKMH = (idx == 2)
        notify.push('MikzDrift', 'Speed: ' .. (useKMH and 'KM/H' or 'MPH'))
    end)

hudMenu:button('Reset Score')
    :tooltip('Reset total score and best records')
    :event(menu.event.click, function()
        totalScore = 0
        driftScore = 0
        comboMultiplier = 1.0
        notify.push('MikzDrift', 'Score reset!')
    end)

hudMenu:button('Reset Session Stats')
    :tooltip('Reset all session statistics')
    :event(menu.event.click, function()
        resetSessionStats()
        totalScore = 0
        driftScore = 0
        comboMultiplier = 1.0
        notify.push('MikzDrift', 'Session stats reset!')
    end)

-- ---- Restore button ----
driftMenu:button('Restore Original Handling')
    :tooltip('Restore stock handling and disable drift')
    :event(menu.event.click, function()
        if lastVehicle and originalHandling then
            disableDrift()
            driftToggle.value = false
            notify.push('MikzDrift', 'Original handling restored')
        else
            notify.push('MikzDrift', 'No drift preset active')
        end
    end)

-- ============================================================
-- MAIN THREAD
-- ============================================================

notify.push('MikzDrift', 'v3.0 Loaded | Works on any car | Use the menu to enable', { time = 5000 })

-- Cleanup on script unload: stop smoke, restore handling
this:event(this.event.unload, function()
    stopSmoke()
    if lastVehicle and originalHandling then
        restoreHandling(lastVehicle)
    end
end)

-- Track last vehicle we were in (for auto-apply detection)
local lastCheckedVehicle = nil

util.create_thread(function()
    while true do
        local vehicle = getPlayerVehicle()

        -- Auto-apply: when entering a new vehicle, check if we have a remembered preset
        if vehicle and not driftActive and autoApplyEnabled then
            if vehicle ~= lastCheckedVehicle then
                lastCheckedVehicle = vehicle
                local remembered = getRememberedPreset(vehicle)
                if remembered and remembered <= #PRESETS then
                    currentPreset = remembered
                    originalHandling = saveHandling(vehicle)
                    lastVehicle = vehicle
                    applyDriftPreset(vehicle, PRESETS[currentPreset])
                    -- Apply AWD bias if set
                    if awdDriveBias > 0 then
                        invoker.call(N.SET_VEHICLE_HANDLING_FLOAT, vehicle,
                            joaat('CHandlingData'), joaat('fDriveBiasFront'), awdDriveBias)
                    end
                    driftActive = true
                    driftToggle.value = true
                    resetDriftState()
                    notify.push('MikzDrift', 'Auto-applied: ' .. PRESETS[currentPreset].name)
                end
            end
        end

        if vehicle and driftActive then
            -- Detect vehicle swap: player got into a different car
            if lastVehicle and vehicle ~= lastVehicle then
                disableDrift()
                driftToggle.value = false
                lastCheckedVehicle = vehicle -- prevent auto-apply loop on same frame
                notify.push('MikzDrift', 'Switched vehicle - drift disabled')
            else
                -- Live preview: re-apply edit preset each tick while tuning
                if livePreview then
                    applyDriftPreset(vehicle, editPreset)
                    if awdDriveBias > 0 then
                        invoker.call(N.SET_VEHICLE_HANDLING_FLOAT, vehicle,
                            joaat('CHandlingData'), joaat('fDriveBiasFront'), awdDriveBias)
                    end
                end

                updateDriftTracking(vehicle)
                doCounterSteerAssist(vehicle)
                doThrottleModulation(vehicle)
                doHandbrakeBoost(vehicle)
                doBackfire(vehicle)
                updateTireSmoke(vehicle)
                updateDriftCamera(vehicle)
            end
        elseif not vehicle and driftActive then
            disableDrift()
            driftToggle.value = false
            lastCheckedVehicle = nil
            notify.push('MikzDrift', 'Left vehicle - drift disabled')
        elseif not vehicle then
            lastCheckedVehicle = nil
        end

        -- Keyboard hotkey (works anytime)
        handleKeyboardHotkey()

        drawHUD()
        util.yield()
    end
end)
