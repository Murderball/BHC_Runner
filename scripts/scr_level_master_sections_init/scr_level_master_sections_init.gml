/// scr_level_master_sections_init([level_key])
/// Initializes global.master_sections for the requested level.
/// Also sets:
///   global.master_sections_key
///   global.master_sections_chunks (via scr_master_sections_build_chunk_ranges if called later)
function scr_level_master_sections_init(_level_key = undefined)
{
    var key = (argument_count >= 1 && is_string(_level_key) && _level_key != "")
        ? _level_key
        : (variable_global_exists("LEVEL_KEY") ? global.LEVEL_KEY : "");

    if (key == "" || is_undefined(key)) key = scr_level_key_from_room(room);

	    // If the level changes, force BG cache to rebuild for the new level's naming scheme
    if (!variable_global_exists("master_sections_key") || global.master_sections_key != key)
    {
        global.BG_CACHE_READY = false;
    }


    // Already initialized for this key
    if (variable_global_exists("master_sections_key") &&
        variable_global_exists("master_sections") &&
        is_array(global.master_sections) &&
        global.master_sections_key == key)
    {
        return;
    }

    global.master_sections_key = key;

	// ------------------------------------------------------------
	// LEVEL 1 (AUTHORED) - from Time Master Level 1.txt
	// ------------------------------------------------------------
	if (key == "level01")
	{
	    global.master_sections = [
	        { name:"Intro_1",      t0: 0.000,    t1: 7.273   },
	        { name:"Main_1",       t0: 7.273,    t1: 13.910  },
	        { name:"Verse_1",      t0: 13.910,   t1: 24.727  },
	        { name:"Prechorus_1",  t0: 24.727,   t1: 34.182  },
	        { name:"Break_1",      t0: 34.182,   t1: 36.364  },
	        { name:"Chorus_1",     t0: 36.364,   t1: 61.910  },
	        { name:"Break_2",      t0: 61.910,   t1: 62.545  },
	        { name:"Verse_2",      t0: 62.545,   t1: 74.182  },
	        { name:"Interlude_1",  t0: 74.182,   t1: 83.636  },
	        { name:"Break_3",      t0: 83.636,   t1: 85.818  },
	        { name:"Chorus_2",     t0: 85.818,   t1: 110.545 },
	        { name:"Breakdown_1",  t0: 110.545,  t1: 120.727 },
	        { name:"Breakdown_2",  t0: 120.727,  t1: 129.455 },
	        { name:"Breakdown_3",  t0: 129.455,  t1: 138.182 },
	        { name:"Breakdown_4",  t0: 138.182,  t1: 155.636 },
	        { name:"Break_4",      t0: 155.636,  t1: 158.545 },
	        { name:"Main_2",       t0: 158.545,  t1: 168.727 },
	        { name:"Outro",        t0: 168.727,  t1: 180.364 }
	    ];

	    // Optional alias (handy for debug)
	    global.level1_master_sections = global.master_sections;
		
		// --- BACKGROUND SETUP FOR LEVEL 1 (9 hard bgs) ---
	    global.BG_FRAMES = 9;
	    global.BG_CACHE_READY = false;
	    global.bg_repaint_all = true;

	    // Force repaint guard reset so the new cache applies immediately
	    if (variable_global_exists("bg_slot_near") && is_array(global.bg_slot_near))
	        global.bg_slot_last_ci = array_create(array_length(global.bg_slot_near), -999999);

	    return;
	}

    // ------------------------------------------------------------
    // LEVEL 3 (current authored data)
    // ------------------------------------------------------------
    if (key == "level03")
    {
        global.master_sections = [
            { name:"intro",           t0: 0.000,        t1: 8.571428571 },
            { name:"break",           t0: 8.571428571,  t1: 10.285714286 },
            { name:"main",            t0: 10.285714286, t1: 24.000 },
            { name:"verse",           t0: 24.000,       t1: 37.714 },
            { name:"pre chorus",      t0: 37.714,       t1: 44.571 },
            { name:"chorus",          t0: 44.571,       t1: 58.286 },
            { name:"chorus_2",        t0: 58.286,       t1: 72.000 },
            { name:"verse_2",         t0: 72.000,       t1: 82.286 },
            { name:"break_2",         t0: 82.286,       t1: 85.714 },
            { name:"breakdown",       t0: 85.714,       t1: 99.429 },
            { name:"pre chorus_2",    t0: 99.429,       t1: 113.143 },
            { name:"chorus_return",   t0: 113.143,      t1: 125.143 },
            { name:"break_3",         t0: 125.143,      t1: 126.857 },
            { name:"bridge",          t0: 126.857,      t1: 140.571 },
            { name:"build",           t0: 140.571,      t1: 154.286 },
            { name:"breakdown_2",     t0: 154.286,      t1: 168.000 },
            { name:"chorus_3",        t0: 168.000,      t1: 181.714 },
            { name:"outro",           t0: 181.714,      t1: 196.0 }
        ];

        // Back-compat alias
        global.level3_master_sections = global.master_sections;
		 // --- BACKGROUND SETUP FOR LEVEL 3 (default set length) ---
        global.BG_FRAMES = 44;
        global.BG_CACHE_READY = false;
        global.bg_repaint_all = true;

        if (variable_global_exists("bg_slot_near") && is_array(global.bg_slot_near))
            global.bg_slot_last_ci = array_create(array_length(global.bg_slot_near), -999999);

        return;
    }

    // ------------------------------------------------------------
    // UNKNOWN / NOT AUTHORED YET
    // ------------------------------------------------------------
    global.master_sections = [
        { name:"intro", t0:0.0, t1:10.0 }
    ];
}
