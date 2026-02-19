// obj_boss : Create
// Generic boss spawner. Place ONE obj_boss in the boss room where
// you want the CENTER of the boss pair (or the single boss) to be.

// ====================================================
// Ensure globals exist (boss rooms do not always have obj_game)
// ====================================================
if (!variable_global_exists("GLOBALS_INIT") || !global.GLOBALS_INIT)
{
    if (script_exists(scr_globals_init)) scr_globals_init();
}

// ====================================================
// Detect boss room entry (covers direct room_goto into rm_boss_*)
// ====================================================
var __isBossRoom = false;

if (room == rm_boss_1 || room == rm_boss_3) __isBossRoom = true;

if (!__isBossRoom)
{
    var __rn = string_lower(room_get_name(room));
    if (string_pos("rm_boss_", __rn) == 1) __isBossRoom = true;
}

// ====================================================
// HARD SYNC (boss rooms do not always have obj_game)
// So we sync LEVEL_KEY + BOSS_BOSSES from the boss room name.
// ====================================================
if (script_exists(scr_level_key_from_room))
{
    var __k = scr_level_key_from_room(room);
    if (is_string(__k) && __k != "")
        global.LEVEL_KEY = __k;
}

if (variable_global_exists("BOSS_DEF_BY_LEVEL") && is_struct(global.BOSS_DEF_BY_LEVEL))
{
    if (variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY)
    && variable_struct_exists(global.BOSS_DEF_BY_LEVEL, global.LEVEL_KEY))
    {
        var __def = global.BOSS_DEF_BY_LEVEL[$ global.LEVEL_KEY];
        global.BOSS_ROOM       = __def.room;
        global.BOSS_BOSSES     = __def.bosses;
        global.BOSS_SONG_SOUND = __def.song;
        global.BOSS_OFFSET     = __def.offset;
        global.BOSS_BPM        = __def.bpm;
    }
}

// ====================================================
// Start boss music on boss-room entry
// (boss rooms may not have obj_game, so we start here)
// ====================================================
if (__isBossRoom)
{
    global.LEVEL_MODE = "boss";
    global.ROOM_FLOW_ENABLED = false;

    // Make sure boss defs & per-level mappings are correct for THIS room
    if (script_exists(scr_level_prepare_for_room)) {
        scr_level_prepare_for_room(room);
    }

    // scr_begin_level_play() is already boss-aware in your project and will:
    // - stop menu music
    // - stop previous song
    // - pick BOSS_SONG_SOUND for boss rooms (rm_boss_1 / rm_boss_3)
    // - apply BOSS_OFFSET
    if (script_exists(scr_begin_level_play)) {
        scr_begin_level_play(0.0);
    }
}

// ====================================================
// Boss spawn logic (unchanged)
// ====================================================
var ax  = x;
var ay  = y;
var lay = layer;

// How far apart the mirrored pair should be (center-to-center distance)
var pair_spacing = 260; // tweak this until it looks right

if (variable_global_exists("BOSS_BOSSES") && is_array(global.BOSS_BOSSES))
{
    var n = array_length(global.BOSS_BOSSES);

    if (n == 1)
    {
        // Single boss: spawn at anchor
        var o0 = global.BOSS_BOSSES[0];
        if (!is_undefined(o0)) instance_create_layer(ax, ay, lay, o0);
    }
    else if (n == 2)
    {
        // Two bosses: spawn centered around anchor
        // Index 0 = left (uke1), index 1 = right (uke2)
        var oL = global.BOSS_BOSSES[0];
        var oR = global.BOSS_BOSSES[1];

        var half = pair_spacing * 0.5;

        if (!is_undefined(oL)) instance_create_layer(ax - half, ay, lay, oL); // LEFT
        if (!is_undefined(oR)) instance_create_layer(ax + half, ay, lay, oR); // RIGHT
    }
    else
    {
        // 3+ bosses fallback: spread them evenly around center
        var halfN = (n - 1) * 0.5;
        for (var i = 0; i < n; i++)
        {
            var o = global.BOSS_BOSSES[i];
            if (is_undefined(o)) continue;

            var dx = (i - halfN) * pair_spacing;
            instance_create_layer(ax + dx, ay, lay, o);
        }
    }
}

// Remove spawner
instance_destroy();
