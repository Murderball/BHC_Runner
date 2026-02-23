function scr_start_boss_level()
{
    if (variable_global_exists("LEVEL_MODE") && global.LEVEL_MODE == "boss") return;

    // ====================================================
    // HARD SYNC: make sure LEVEL_KEY matches the room that triggered the boss
    // (prevents level03 boss data bleeding into level01)
    // ====================================================
    if (script_exists(scr_level_key_from_room))
    {
        var __k = scr_level_key_from_room(room);
        if (is_string(__k) && __k != "")
            global.LEVEL_KEY = __k;
    }

    // Also refresh boss globals from LEVEL_KEY BEFORE we do anything else
    if (variable_global_exists("BOSS_DEF_BY_LEVEL") && is_struct(global.BOSS_DEF_BY_LEVEL))
    {
        if (variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY)
        && variable_struct_exists(global.BOSS_DEF_BY_LEVEL, global.LEVEL_KEY))
        {
            var __def0 = global.BOSS_DEF_BY_LEVEL[$ global.LEVEL_KEY];
            global.BOSS_ROOM       = __def0.room;
            global.BOSS_BOSSES     = __def0.bosses;
            global.BOSS_SONG_SOUND = __def0.song;
            global.BOSS_OFFSET     = __def0.offset;
            global.BOSS_BPM        = __def0.bpm;
        }
    }

    // 1) mark boss mode
    global.LEVEL_MODE = "boss";
    global.ROOM_FLOW_ENABLED = false;

    // 2) stop current song
    scr_fmod_music_stop();
    global.song_handle = -1;
    global.song_playing = false;

    // 3) reset playhead
    global.editor_time = 0;
    if (variable_global_exists("transport_time_s")) global.transport_time_s = 0;

    // --- RESET TIMELINE / CHART STATE ---
    global.editor_time = 0.0;
    if (variable_global_exists("transport_time_s")) global.transport_time_s = 0.0;
    if (variable_global_exists("song_time_s")) global.song_time_s = 0.0;

    // Reset story + chart seek state
    scr_story_seek_time(0.0);

    // 4) swap song + offset
    global.song_sound = global.BOSS_SONG_SOUND;
    global.OFFSET = global.BOSS_OFFSET;

    // --------------------------------------------------
    // Pick boss chart by LEVEL_KEY + DIFFICULTY
    // --------------------------------------------------
    global.BOSS_CHART_FILE = "";

    if (variable_global_exists("BOSS_DEF_BY_LEVEL") && is_struct(global.BOSS_DEF_BY_LEVEL))
    {
        var __lk = (variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY) && global.LEVEL_KEY != "")
            ? global.LEVEL_KEY : "level03";

        if (variable_struct_exists(global.BOSS_DEF_BY_LEVEL, __lk))
        {
            var __def = global.BOSS_DEF_BY_LEVEL[$ __lk];

            // Difficulty key
            var __d = "normal";
            if (variable_global_exists("DIFFICULTY") && is_string(global.DIFFICULTY)) __d = string_lower(global.DIFFICULTY);
            if (__d != "easy" && __d != "normal" && __d != "hard") __d = "normal";

            // Chart from def
            if (is_struct(__def.charts) && variable_struct_exists(__def.charts, __d))
                global.BOSS_CHART_FILE = __def.charts[$ __d];

            // Also refresh these (safe)
            global.BOSS_ROOM        = __def.room;
            global.BOSS_BOSSES      = __def.bosses;
            global.BOSS_SONG_SOUND  = __def.song;
            global.BOSS_OFFSET      = __def.offset;
            global.BOSS_BPM         = __def.bpm;
        }
    }

    // Swap chart if provided
    if (is_string(global.BOSS_CHART_FILE) && string_length(global.BOSS_CHART_FILE) > 0)
    {
        global.chart_file = global.BOSS_CHART_FILE;
        scr_chart_load();
    }

    // 5) start boss music at 0
    global.song_handle = -1;
    global.song_playing = true;
    scr_audio_route_apply();

    // Boss timeline reset (used if audio timing is briefly unavailable)
    global.BOSS_TIMELINE_S = 0.0;

    // === Boss song tempo ===
    global.SONG_BPM = (variable_global_exists("BOSS_BPM") && is_real(global.BOSS_BPM)) ? global.BOSS_BPM : 180;
    global.PX_PER_BEAT = 192;

    // Derived scroll speed
    global.WORLD_PPS = global.PX_PER_BEAT * (global.SONG_BPM / 60.0);

    // If you have separate chart PPS, keep them in sync
    global.CHART_PPS = global.WORLD_PPS;

    // 6) go to boss room
    room_goto(global.BOSS_ROOM);
}
