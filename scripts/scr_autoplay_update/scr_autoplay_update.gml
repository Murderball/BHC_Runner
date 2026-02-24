/// scr_autoplay_update()
/// Sets global.in_* flags automatically when a matching-action note reaches the hit window.
/// Must run AFTER scr_input_update() and BEFORE obj_player reads inputs.

function scr_autoplay_update()
{
	if (variable_global_exists("STORY_PAUSED") && global.STORY_PAUSED) return;
    if (!variable_global_exists("AUTO_HIT_ENABLED")) return;
    if (!global.AUTO_HIT_ENABLED) return;

    // Don't autoplay while editor is on
    if (variable_global_exists("editor_on") && global.editor_on) return;

    if (!variable_global_exists("chart") || is_undefined(global.chart)) return;

    var tnow = scr_chart_time();
	
	// --- Reset debounce if time moved backwards (scrub/jump back) ---
	if (!variable_global_exists("auto_prev_time_s")) global.auto_prev_time_s = tnow;

	if (tnow < global.auto_prev_time_s - 0.001) {
	    scr_autohit_reset();
	}
	global.auto_prev_time_s = tnow;


    var win  = global.WIN_PERFECT; // "auto perfect" window

    var len = array_length(global.chart);

    // Find nearest note time for each action
    var best_jump_dt = 1000000000; var best_jump_t = -1;
    var best_duck_dt = 1000000000; var best_duck_t = -1;
    var best_atk1_dt = 1000000000; var best_atk1_t = -1;
    var best_atk2_dt = 1000000000; var best_atk2_t = -1;
    var best_atk3_dt = 1000000000; var best_atk3_t = -1;

    for (var i = 0; i < len; i++)
    {
        var n = global.chart[i];
        if (!is_struct(n)) continue;
        if (!variable_struct_exists(n, "t")) continue;
        if (!variable_struct_exists(n, "act")) continue;

        var dt = abs(n.t - tnow);

        // Only care about nearby notes (keeps it cheap)
        if (dt > global.WIN_BAD) continue;

        var a = n.act;

        if (a == global.ACT_JUMP) {
            if (dt < best_jump_dt) { best_jump_dt = dt; best_jump_t = n.t; }
        }
        else if (a == global.ACT_DUCK) {
            if (dt < best_duck_dt) { best_duck_dt = dt; best_duck_t = n.t; }
        }
        else if (a == global.ACT_ATK1) {
            if (dt < best_atk1_dt) { best_atk1_dt = dt; best_atk1_t = n.t; }
        }
        else if (a == global.ACT_ATK2) {
            if (dt < best_atk2_dt) { best_atk2_dt = dt; best_atk2_t = n.t; }
        }
        else if (a == global.ACT_ATK3) {
            if (dt < best_atk3_dt) { best_atk3_dt = dt; best_atk3_t = n.t; }
        }
    }

    // Debounce so it doesn't "press" the same note every frame
    if (best_jump_dt <= win && best_jump_t != global.auto_last_jump_t) {
        global.in_jump = true;
        global.auto_last_jump_t = best_jump_t;
    }

    if (best_duck_dt <= win && best_duck_t != global.auto_last_duck_t) {
        global.in_duck = true;
        global.auto_last_duck_t = best_duck_t;
    }

    if (best_atk1_dt <= win && best_atk1_t != global.auto_last_atk1_t) {
        global.in_atk1 = true;
        global.auto_last_atk1_t = best_atk1_t;
    }

    if (best_atk2_dt <= win && best_atk2_t != global.auto_last_atk2_t) {
        global.in_atk2 = true;
        global.auto_last_atk2_t = best_atk2_t;
    }

    if (best_atk3_dt <= win && best_atk3_t != global.auto_last_atk3_t) {
        global.in_atk3 = true;
        global.auto_last_atk3_t = best_atk3_t;
    }
}
