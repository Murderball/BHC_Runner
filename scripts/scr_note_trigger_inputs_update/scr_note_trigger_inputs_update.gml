/// scr_note_trigger_inputs_update()
///
/// Makes notes "press" actions when they reach the hit window.
/// - ATK1/ATK2/ATK3: note-triggered + player can press anytime
/// - ULT: NOTE-ONLY (this is the only way global.in_ult becomes true)
///
/// Call order:
///   scr_input_update();
///   scr_story_pause_update();
///   scr_note_trigger_inputs_update();
///   (then obj_player reads global.in_*)

function scr_note_trigger_inputs_update()
{
    if (variable_global_exists("STORY_PAUSED") && global.STORY_PAUSED) return;
    if (variable_global_exists("editor_on") && global.editor_on) return;

    if (!variable_global_exists("note_triggers_on") || !global.note_triggers_on) return;
    if (!variable_global_exists("chart") || is_undefined(global.chart)) return;

    var tnow = scr_chart_time();
    var win  = global.WIN_PERFECT;

    // If time moved backwards (scrub), reset debounce
    if (!variable_global_exists("note_prev_time_s")) global.note_prev_time_s = tnow;
    if (tnow < global.note_prev_time_s - 0.001) {
        scr_autohit_reset();
    }
    global.note_prev_time_s = tnow;

    var len = array_length(global.chart);

    // Find nearest note time for each note-triggered action
	var BIG = 1000000000; 

	var best_a1_dt = BIG; var best_a1_t = -1;
	var best_a2_dt = BIG; var best_a2_t = -1;
	var best_a3_dt = BIG; var best_a3_t = -1;
	var best_u_dt  = BIG; var best_u_t  = -1;


    for (var i = 0; i < len; i++)
    {
        var n = global.chart[i];
        if (!is_struct(n)) continue;
        if (!variable_struct_exists(n, "t")) continue;
        if (!variable_struct_exists(n, "act")) continue;

        // Skip already-hit notes
        if (variable_struct_exists(n, "hit") && n.hit) continue;

        var dt = abs(n.t - tnow);
        if (dt > global.WIN_BAD) continue;

        var a = n.act;
        if (a == global.ACT_ATK1) {
            if (dt < best_a1_dt) { best_a1_dt = dt; best_a1_t = n.t; }
        }
        else if (a == global.ACT_ATK2) {
            if (dt < best_a2_dt) { best_a2_dt = dt; best_a2_t = n.t; }
        }
        else if (a == global.ACT_ATK3) {
            if (dt < best_a3_dt) { best_a3_dt = dt; best_a3_t = n.t; }
        }
        else if (a == global.ACT_ULT) {
            if (dt < best_u_dt)  { best_u_dt  = dt; best_u_t  = n.t; }
        }
    }

    // Debounce so it doesn't "press" the same note every frame
    if (best_a1_dt <= win && best_a1_t != global.note_last_atk1_t) {
        global.in_atk1 = true;
        global.note_last_atk1_t = best_a1_t;
    }
    if (best_a2_dt <= win && best_a2_t != global.note_last_atk2_t) {
        global.in_atk2 = true;
        global.note_last_atk2_t = best_a2_t;
    }
    if (best_a3_dt <= win && best_a3_t != global.note_last_atk3_t) {
        global.in_atk3 = true;
        global.note_last_atk3_t = best_a3_t;
    }

    // ULT is NOTE-ONLY
    if (best_u_dt <= win && best_u_t != global.note_last_ult_t) {
        global.in_ult = true;
        global.note_last_ult_t = best_u_t;
    }

    // Decay transient note hit FX timers in authoritative gameplay update path
    for (var j = 0; j < len; j++)
    {
        var nj = global.chart[j];
        if (!is_struct(nj)) continue;

        if (!variable_struct_exists(nj, "hit_fx_t")) nj.hit_fx_t = 0;
        if (!variable_struct_exists(nj, "hit_fx_dur")) nj.hit_fx_dur = 0.10;
        if (!variable_struct_exists(nj, "hit_fx_pow")) nj.hit_fx_pow = 0;

        if (nj.hit_fx_t > 0)
        {
            nj.hit_fx_t = max(0, nj.hit_fx_t - (delta_time / 1000000.0));
            if (nj.hit_fx_t <= 0) nj.hit_fx_pow = 0;
        }
    }
}
