function scr_globals_init()
{
    // ====================================================
    // ONE-TIME INIT GUARD
    // ====================================================
    if (variable_global_exists("GLOBALS_INIT") && global.GLOBALS_INIT) return;
    global.GLOBALS_INIT = true;

    if (variable_global_exists("GLOBALS_INITIALIZED") && global.GLOBALS_INITIALIZED) return;
    global.GLOBALS_INITIALIZED = true;

    // ====================================================
    // CORE SAFETY DEFAULTS (prevent "not set before reading")
    // ====================================================
    if (!variable_global_exists("transport_paused")) global.transport_paused = false;

    if (!variable_global_exists("GAME_PAUSED"))  global.GAME_PAUSED  = false;
    if (!variable_global_exists("STORY_PAUSED")) global.STORY_PAUSED = false;
    if (!variable_global_exists("EDITOR_PAUSE_OPEN")) global.EDITOR_PAUSE_OPEN = false;
    if (!variable_global_exists("EDITOR_PAUSE_REWIND_ON_EXIT")) global.EDITOR_PAUSE_REWIND_ON_EXIT = false;
    if (!variable_global_exists("EDITOR_PAUSE_T0")) global.EDITOR_PAUSE_T0 = 0.0;
    if (!variable_global_exists("EDITOR_PAUSE_ROOM")) global.EDITOR_PAUSE_ROOM = room;
    if (!variable_global_exists("EDITOR_PAUSE_VALID")) global.EDITOR_PAUSE_VALID = false;

    // Input edge flags (must exist before ANY player Step runs)
    if (!variable_global_exists("in_jump")) global.in_jump = false;
    if (!variable_global_exists("in_duck")) global.in_duck = false;
    if (!variable_global_exists("in_atk1")) global.in_atk1 = false;
    if (!variable_global_exists("in_atk2")) global.in_atk2 = false;
    if (!variable_global_exists("in_atk3")) global.in_atk3 = false;
    if (!variable_global_exists("in_ult"))  global.in_ult  = false;

    // Holds (optional)
    if (!variable_global_exists("hold_duck")) global.hold_duck = false;

    // Judge debug strings (avoid debug UI reads crashing)
    if (!variable_global_exists("last_jump_judge")) global.last_jump_judge = "miss";
    if (!variable_global_exists("last_duck_judge")) global.last_duck_judge = "miss";
    if (!variable_global_exists("last_atk1_judge")) global.last_atk1_judge = "miss";
    if (!variable_global_exists("last_atk2_judge")) global.last_atk2_judge = "miss";
    if (!variable_global_exists("last_atk3_judge")) global.last_atk3_judge = "miss";
    if (!variable_global_exists("last_ult_judge"))  global.last_ult_judge  = "miss";
    if (!variable_global_exists("DEBUG_EDITOR_ICONS")) global.DEBUG_EDITOR_ICONS = true;
    if (!variable_global_exists("DEBUG_NOTE_ALPHA")) global.DEBUG_NOTE_ALPHA = false;

    // Input/keybind debug gate
    if (!variable_global_exists("DEBUG_INPUT")) global.DEBUG_INPUT = false;

    // ====================================================
    // RUN SESSION IDS
    // ====================================================
    if (!variable_global_exists("run_id")) global.run_id = 0;
    if (!variable_global_exists("last_run_id_in_room")) global.last_run_id_in_room = -1;

	// Current level key (used by level-aware systems)
	if (!variable_global_exists("LEVEL_KEY") || !is_string(global.LEVEL_KEY) || global.LEVEL_KEY == "")
    global.LEVEL_KEY = "level03";


    // ====================================================
    // BASE RESOLUTION / CAMERA
    // ====================================================
    global.BASE_W = 1920;
    global.BASE_H = 1080;
    global.CAM_Y  = 300; // positive = camera looks lower

    // ====================================================
    // WORLD SCROLL / TIMING CORE
    // ====================================================
    global.WORLD_PPS = 448;
    global.SCROLL_PPS_BASE = global.WORLD_PPS;

    global.START_WORLD_X_PX = 0.0;

    global.BPM = 140;
    global.SEC_PER_BEAT = 60.0 / max(1.0, global.BPM);

    global.HIT_X_GUI = 448;

    // ====================================================
    // STARTUP LOADING GATE
    // ====================================================
    global.STARTUP_LOADING = true;
    global.STARTUP_LOADING_FRAMES = 2;
    global.startup_frames_left = global.STARTUP_LOADING_FRAMES;

    // ====================================================
    // GLOBAL OFFSETS / CALIBRATION
    // ====================================================
    global.spawn_y_offset = -276;
    global.spawn_x_offset = [300, 0, 0, 0];

    global.OFFSET = 0.0;
    global.HITLINE_TIME_OFFSET_S = 0.0;
    global.CHART_TIME_OFFSET_S = 0.0;
    global.CAM_PULSE_TIME_OFFSET_S = 0.0;

    global.CHUNK_X_OFFSET_PX = 0.0;

    // ====================================================
    // CHUNK SYSTEM (INCREMENTAL)
    // ====================================================
    if (!variable_global_exists("chunk_stamp_queue") || !is_array(global.chunk_stamp_queue)) global.chunk_stamp_queue = [];
    global.chunk_stamp_row_budget = 24;
    global.chunk_stamp_rows_per_job = 8;

    if (!variable_global_exists("chunk_load_queue") || !is_array(global.chunk_load_queue)) global.chunk_load_queue = [];

    if (!variable_global_exists("chunk_load_pending") || !ds_exists(global.chunk_load_pending, ds_type_map))
        global.chunk_load_pending = ds_map_create();

    global.chunk_load_budget = 1;

    // ====================================================
    // ENUMS
    // ====================================================
    enum PLAYER_STATE { IDLE, RUN, JUMP, FALL, ATTACK }

    enum DIFF_SWAP_MODE {
        BOTH = 0,
        VISUAL_ONLY = 1,
        AUDIO_ONLY = 2
    }

    // ====================================================
    // DIFFICULTY SYSTEM
    // ====================================================
    // Respect menu previous selection if already set
    var _d0 = "normal";
    if (variable_global_exists("DIFFICULTY")) _d0 = string_lower(string(global.DIFFICULTY));
    else if (variable_global_exists("difficulty")) _d0 = string_lower(string(global.difficulty));

    if (_d0 != "easy" && _d0 != "normal" && _d0 != "hard") _d0 = "normal";

    global.DIFFICULTY = _d0;
    global.difficulty = _d0;

   // IMPORTANT: These must be REAL paths/strings
	global.DIFF_CHART = {
	    easy   : "charts/" + global.LEVEL_KEY + "/easy.json",
	    normal : "charts/" + global.LEVEL_KEY + "/normal_v2.json",
	    hard   : "charts/" + global.LEVEL_KEY + "/hard_v2.json"
	};


    // Tileset names stored as STRINGS (tilemap init can asset_get_index() them)
    global.DIFF_TILESET_NAME = {
        easy   : "TileSet_Easy",
        normal : "TileSet_Normal",
        hard   : "TileSet_Hard"
    };

    global.diff_swap_mode   = DIFF_SWAP_MODE.BOTH;
    global.diff_swap_visual = true;
    global.diff_swap_audio  = true;

    // ====================================================
    // INPUT / ACTION DEFINITIONS
    // ====================================================
    global.ACT_JUMP = "jump";
    global.ACT_DUCK = "duck";
    global.ACT_ATK1 = "atk1";
    global.ACT_ATK2 = "atk2";
    global.ACT_ATK3 = "atk3";
    global.ACT_ULT  = "ult";

    // All possible actions (editor logic). Notes only use ATK1/ATK2/ATK3/ULT now.
    global.ACT_LIST = [
        global.ACT_JUMP,
        global.ACT_DUCK,
        global.ACT_ATK1,
        global.ACT_ATK2,
        global.ACT_ATK3,
        global.ACT_ULT
    ];

    // NOTE LANES (4): ATK1, ATK2, ATK3, ULT
    global.LANE_TO_ACT = [
        global.ACT_ATK1,
        global.ACT_ATK2,
        global.ACT_ATK3,
        global.ACT_ULT
    ];

    // Notes trigger actions system (separate from AUTO_HIT)
    global.note_triggers_on = true;
    global.note_last_atk1_t = -1000000000;
    global.note_last_atk2_t = -1000000000;
    global.note_last_atk3_t = -1000000000;
    global.note_last_ult_t  = -1000000000;

    // ====================================================
    // LANES / GUI
    // ====================================================
    global.LANE_COUNT = 4;

    global.GUI_TOP = 350;
    global.GUI_BOT = 580;

    global.LANE_Y = array_create(global.LANE_COUNT, 0);

    var spacing = (global.GUI_BOT - global.GUI_TOP) / max(1, (global.LANE_COUNT - 1));
    for (var i = 0; i < global.LANE_COUNT; i++)
        global.LANE_Y[i] = global.GUI_TOP + i * spacing;

    // ====================================================
    // JUDGEMENT WINDOWS
    // ====================================================
    global.WIN_PERFECT = 0.030;
    global.WIN_GOOD    = 0.070;
    global.WIN_BAD     = 0.120;

    // ====================================================
    // CHART SYSTEM
    // ====================================================
    global.CHART_ROOT = "charts";

    global.chart_hot_reload = false;
    global.chart_hot_reload_hz = 4;
    global._chart_hot_reload_accum = 0.0;
    global._chart_hot_reload_last_dt = 0.0;
    global._chart_hot_reload_last_sig = -1;

    // (safe defaults; loader will fill)
    if (!variable_global_exists("chart") || !is_array(global.chart)) global.chart = [];
    if (!variable_global_exists("chart_file") || global.chart_file == "")
        global.chart_file = global.DIFF_CHART[$ global.DIFFICULTY];

    // ====================================================
    // PHRASE SYSTEM
    // ====================================================
    global.phrases = [];
    global.phrases_file = ""; // was "noone" in your file; use string path when you implement

    global.PHRASE_LEAD_S = 2.0;
    global.PHRASE_WIN_PERF = 0.030;
    global.PHRASE_WIN_GOOD = 0.070;
    global.PHRASE_WIN_BAD  = 0.120;

    global.phrase_active = false;
    global.phrase_i = -1;
    global.phrase_step_i = 0;
    global.phrase_hits_perfect = 0;
    global.phrase_hits_good = 0;
    global.phrase_hits_miss = 0;

    // ====================================================
    // EDITOR SYSTEM
    // ====================================================
    global.editor_on = true;
    if (!variable_global_exists("editor_time")) global.editor_time = 0.0;

    global.editor_toggle_key    = vk_tab;
    global.editor_playpause_key = vk_space;
    global.editor_snap_key      = ord("G");
    global.editor_quant_key     = ord("Q");
    global.editor_delete_key    = vk_delete;

    global.editor_scrub_fast  = vk_shift;
    global.editor_scrub_left  = vk_left;
    global.editor_scrub_right = vk_right;

    global.editor_tool = "tap";
    global.editor_hold_default_beats = 1.0;

    global.TICKS_PER_BEAT = 16;
    global.editor_grid_show_subdiv = true;
    global.editor_grid_step_ticks = 1;

    global.editor_snap_on = true;
    global.editor_snap_options = [1.0, 0.5, 0.25, 0.125];
    global.editor_snap_index = 2;
    global.editor_snap = global.editor_snap_options[global.editor_snap_index];

    global.SNAP_DIV = 16;

// ====================================================
    // AUDIO / MUSIC  (FIXED: level-aware, no forced level03)
    // ====================================================
    if (!variable_global_exists("AUDIO_MASTER")) global.AUDIO_MASTER = 1.0;
    scr_audio_settings_load();
    scr_audio_settings_apply();

    global.song_handle = -1;
    global.song_playing = false;

    global.music_bus = -1;
    global.music_name = ""; // keep as string
    global.music_fade_ms = 350;

    // Level-aware default song map (prevents globals from "locking" to level03)
    if (global.LEVEL_KEY == "level01") {
        global.DIFF_SONG_SOUND = {
            easy   : snd_song_1_easy,
            normal : snd_song_1_normal,
            hard   : snd_song_1_hard
        };
    } else {
        // fallback: level03
        global.DIFF_SONG_SOUND = {
            easy   : snd_song_3_easy,
            normal : snd_song_3_normal,
            hard   : snd_song_3_hard
        };
    }

    // Only set song_sound if it's not set yet
    if (!variable_global_exists("song_sound") || global.song_sound == -1 || is_undefined(global.song_sound))
        global.song_sound = global.DIFF_SONG_SOUND[$ string_lower(global.DIFFICULTY)];

    global.METRONOME_SOUND = snd_metronome;
    global.METRONOME_VOL = 5.0;
    global.metro_last_beat = -1000000000;
    global.metro_next_t = 0.0;
    global.metro_last_t = 0.0;


    // ====================================================
    // HITLINE PULSE
    // ====================================================
    global.HITLINE_PULSE_LEN_BEATS = 0.22;
    global.HITLINE_PULSE_AMP_BEAT  = 0.55;
    global.HITLINE_PULSE_AMP_DOWN  = 0.85;

    // ====================================================
    // STORY / MARKERS
    // ====================================================
    global.MARKERS_FILE = "markers_save.json";
    global.STORY_PAUSED = false;

    global.story_state = "idle";
    global.story_timer = 0.0;

    global.story_pause_song_t = 0.0;
    global.story_song_was_playing = false;

    global.story_npc_handle = -1;
    global.story_idx = 0;

    global.story_choice_active = false;
    global.story_choice_caption = "";
    global.story_choice_options = [];
    global.story_choice_sel = 0;

    global.story_choice_last = "";
    global.story_choice_last_idx = -1;

    global.markers = [];
    global.markers_file = "story_markers.json";

    global.STORY_IGNORE_BEFORE_S = 1.50;

    // Default marker template (used by editor when placing new markers)
    if (!variable_global_exists("marker_default") || is_undefined(global.marker_default) || !is_struct(global.marker_default))
    {
        global.marker_default = {
            type         : "pause",
            snd_name      : "snd_pause", // string name
            fade_out_ms   : 150,
            fade_in_ms    : 150,
            wait_confirm  : true,
            loop          : true,
            caption       : "Continue",
            choices       : []
        };
    }

    // Marker editor sound dropdown list (string asset names)
    if (!variable_global_exists("marker_sound_list") || is_undefined(global.marker_sound_list))
    {
        global.marker_sound_list = ["snd_pause"];
    }

    // ====================================================
    // BOSS SYSTEM (LEVEL-AWARE + PER-DIFFICULTY CHARTS + BOSS OBJECTS)
    // (FIXED: no hard-coded level03 runtime defaults)
    // ====================================================
    global.LEVEL_MODE = "main";
    global.ROOM_FLOW_ENABLED = true;

    // Default trigger time (you can override per level later if you want)
    global.BOSS_TRIGGER_S = 195.324;

    // Boss definitions per level
    global.BOSS_DEF_BY_LEVEL = {
        level01 : {
            room  : rm_boss_1,
            // Two bosses for level 1
            bosses: [ obj_boss_uke1_level1, obj_boss_uke2_level1 ],
            charts: { easy: "charts/level01/boss_ukes_easy.json",
                     normal: "charts/level01/boss_ukes_normal.json",
                     hard: "charts/level01/boss_ukes_hard.json" },
            song  : snd_boss_music_level1,
            offset: 0.0,
            bpm   : 180
        },

        level03 : {
            room  : rm_boss_3,
            // One boss for level 3
            bosses: [ obj_boss_punky_level3 ],
            charts: { easy: "charts/level03/boss_punky_easy.json",
                     normal: "charts/level03/boss_punky_normal.json",
                     hard: "charts/level03/boss_punky_hard.json" },
            song  : snd_boss_music_level3,
            offset: 0.0,
            bpm   : 180
        }
    };

    // Runtime-selected boss settings (filled from LEVEL_KEY)
    // Start with safe fallbacks
    global.BOSS_ROOM = rm_boss_3;
    global.BOSS_BOSSES = [ obj_boss_punky_level3 ];
    global.BOSS_CHART_FILE = "";
    global.BOSS_SONG_SOUND = snd_boss_music_level3;
    global.BOSS_OFFSET = 0.0;
    global.BOSS_BPM = 180;

    // Initialize from current LEVEL_KEY if present (and valid)
    var __lk = "level03";
    if (variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY) && global.LEVEL_KEY != "")
        __lk = global.LEVEL_KEY;

    // If LEVEL_KEY isn't defined in the boss struct, fall back to level03
    if (!variable_struct_exists(global.BOSS_DEF_BY_LEVEL, __lk))
        __lk = "level03";

    if (variable_struct_exists(global.BOSS_DEF_BY_LEVEL, __lk))
    {
        var __def = global.BOSS_DEF_BY_LEVEL[$ __lk];
        global.BOSS_ROOM       = __def.room;
        global.BOSS_BOSSES     = __def.bosses;
        global.BOSS_SONG_SOUND = __def.song;
        global.BOSS_OFFSET     = __def.offset;
        global.BOSS_BPM        = __def.bpm;
    }

    // ====================================================
    // BACKGROUND SYSTEM
    // ====================================================
    global.bg_difficulty = global.DIFFICULTY;
    global.bg_repaint_all = true;
    global.BG_FRAMES = 44;

    // fallback sprite index (use asset_get_index on string names)
    global.bg_fallback_sprite = asset_get_index("spr_bg_normal_00");
    if (global.bg_fallback_sprite == -1)
        global.bg_fallback_sprite = asset_get_index("spr_bg_easy_00");

    global.BG_CACHE_READY = false;
    global.BG_DBG_REV_READY = false;

    // ====================================================
    // PERF / DEBUG
    // ====================================================
    global.dbg_spike_on = true;
    global.dbg_spike_us = 45000;

    global.dbg_last_chart_load_t = -1;
    global.dbg_last_diff_apply_t = -1;
    global.dbg_last_chunk_refresh_t = -1;
    global.dbg_last_bg_repaint_t = -1;
    global.dbg_last_spike_msg = "";

    // ====================================================
    // WINDOW / MONITOR TOGGLE (prevents win_on_second crash)
    // ====================================================
    if (!variable_global_exists("win_on_second")) global.win_on_second = false;

    if (!variable_global_exists("win_default_w")) global.win_default_w = global.BASE_W;
    if (!variable_global_exists("win_default_h")) global.win_default_h = global.BASE_H;

    if (!variable_global_exists("win_m1_x")) global.win_m1_x = 10;
    if (!variable_global_exists("win_m1_y")) global.win_m1_y = 10;

    if (!variable_global_exists("win_m2_pad_x")) global.win_m2_pad_x = 966;
    if (!variable_global_exists("win_m2_pad_y")) global.win_m2_pad_y = 35;

    // ====================================================
    // FINAL BOOT CALLS (keep your ordering)
    // ====================================================
    if (script_exists(scr_bg_cache_init)) scr_bg_cache_init();
    if (script_exists(scr_bg_debug_reverse_init)) scr_bg_debug_reverse_init();

    if (script_exists(scr_markers_load)) scr_markers_load();
    if (script_exists(scr_story_router_init)) scr_story_router_init();
    if (script_exists(scr_story_events_from_markers)) scr_story_events_from_markers();
    if (script_exists(scr_perf_init)) scr_perf_init();
}
