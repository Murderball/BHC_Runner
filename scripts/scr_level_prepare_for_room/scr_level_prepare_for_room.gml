/// scr_level_prepare_for_room([room_id])
/// Ensures LEVEL_KEY + per-level paths + sections + chunk sequences + BPM + song mapping are correct.
/// Call this at gameplay room start (obj_game Create is perfect).
function scr_level_prepare_for_room(_room_id)
{
    var rid = (argument_count >= 1) ? _room_id : room;

    // Ensure base globals exist
    if (!variable_global_exists("GLOBALS_INIT") || !global.GLOBALS_INIT) {
        scr_globals_init();
    }

    // Determine which level this room belongs to
    var key = scr_level_key_from_room(rid);

    // If LEVEL_KEY differs, update it
    if (!variable_global_exists("LEVEL_KEY") || !is_string(global.LEVEL_KEY) || global.LEVEL_KEY != key) {
        global.LEVEL_KEY = key;
    }
	// --------------------------------------------------
	// Keep boss settings synced with LEVEL_KEY
	// --------------------------------------------------
	if (variable_global_exists("BOSS_DEF_BY_LEVEL") && is_struct(global.BOSS_DEF_BY_LEVEL))
	{
	    if (variable_struct_exists(global.BOSS_DEF_BY_LEVEL, global.LEVEL_KEY))
	    {
	        var __def = global.BOSS_DEF_BY_LEVEL[$ global.LEVEL_KEY];
	        global.BOSS_ROOM       = __def.room;
	        global.BOSS_BOSSES     = __def.bosses;
	        global.BOSS_SONG_SOUND = __def.song;
	        global.BOSS_OFFSET     = __def.offset;
	        global.BOSS_BPM        = __def.bpm;
	    }
	}


    // --------------------------------------------------
    // PER-LEVEL BPM DEFAULT (drives hitline pulse + camera pulse)
    // Chart files can override BPM if they include a "bpm" field,
    // but if they DON'T, this value becomes the active BPM.
    // --------------------------------------------------
    var default_bpm = 140;
    if (global.LEVEL_KEY == "level01") default_bpm = 165;

    global.BPM = default_bpm;
    global.chart_bpm = default_bpm;
    global.SEC_PER_BEAT = 60.0 / max(1.0, global.BPM);

    // --------------------------------------------------
    // Chunk room/file prefixes (match exporter output)
    // --------------------------------------------------
    global.CHUNK_ROOM_PREFIX = "rm_chunk_";
    global.CHUNK_FILE_PREFIX = "chunk_rm_chunk_";

    if (global.LEVEL_KEY == "level01") {
        global.CHUNK_ROOM_PREFIX = "rm1_chunk_";
        global.CHUNK_FILE_PREFIX = "chunk_rm1_chunk_";
    }

    // Rebuild per-level chart paths EVERY time (standardized level{N}_{difficulty}.json)
    var lvl_num = 3;
    if (string_length(global.LEVEL_KEY) >= 6) lvl_num = max(1, real(string_copy(global.LEVEL_KEY, 6, string_length(global.LEVEL_KEY) - 5)));
    var lvl_num_str = string(floor(lvl_num));

    global.DIFF_CHART = {
        easy   : "charts/" + global.LEVEL_KEY + "/level" + lvl_num_str + "_easy.json",
        normal : "charts/" + global.LEVEL_KEY + "/level" + lvl_num_str + "_normal.json",
        hard   : "charts/" + global.LEVEL_KEY + "/level" + lvl_num_str + "_hard.json"
    };

    // ====================================================
    // AUDIO / MUSIC (PER-LEVEL SONG MAP)
    // ====================================================
    if (global.LEVEL_KEY == "level01") {
        global.DIFF_SONG_SOUND = {
            easy   : snd_song_1_easy,
            normal : snd_song_1_normal,
            hard   : snd_song_1_hard
        };
    } else {
        global.DIFF_SONG_SOUND = {
            easy   : snd_song_3_easy,
            normal : snd_song_3_normal,
            hard   : snd_song_3_hard
        };
    }

    // Ensure song_sound matches current difficulty selection (unless boss)
    if (!(variable_global_exists("LEVEL_MODE") && global.LEVEL_MODE == "boss"))
    {
        var d_song = "normal";
        if (variable_global_exists("DIFFICULTY")) d_song = string_lower(string(global.DIFFICULTY));
        else if (variable_global_exists("difficulty")) d_song = string_lower(string(global.difficulty));
        if (d_song != "easy" && d_song != "normal" && d_song != "hard") d_song = "normal";

        global.song_sound = global.DIFF_SONG_SOUND[$ d_song];
        if (is_undefined(global.song_sound) || global.song_sound == -1) {
            global.song_sound = global.DIFF_SONG_SOUND.normal;
        }
    }

    // Ensure chart root folders exist in sandbox
    if (!directory_exists("charts")) directory_create("charts");
    var lvl_dir = "charts/" + global.LEVEL_KEY;
    if (!directory_exists(lvl_dir)) directory_create(lvl_dir);

    // Make sure master sections reflect this level
    scr_level_master_sections_init(global.LEVEL_KEY);

    // Chunk sequences depend on master sections + chunk sizing globals
    scr_chunk_build_section_sequences();

    // Ensure current chart_file points at the current level's difficulty chart
    var d = "normal";
    if (variable_global_exists("DIFFICULTY")) d = string_lower(string(global.DIFFICULTY));
    else if (variable_global_exists("difficulty")) d = string_lower(string(global.difficulty));
    if (d != "easy" && d != "normal" && d != "hard") d = "normal";

    global.chart_file = global.DIFF_CHART[$ d];
}
