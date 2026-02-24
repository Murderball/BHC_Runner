/// scr_try_trigger(act)
/// Judges closest matching note by act.
/// Test-room safe: returns "perfect" if no chart/time exists.

function scr_try_trigger(act)
{
    // ----------------------------
    // TEST ROOM: always succeed
    // ----------------------------
    if (variable_global_exists("LEVEL_MODE") && global.LEVEL_MODE == "test")
    {
        return "perfect";
    }

    // If chart isn't loaded, can't judge (safe)
    if (!variable_global_exists("chart") || is_undefined(global.chart)) return "miss";
    if (!variable_global_exists("WIN_BAD")) return "miss";

    var t = scr_chart_time();
    var auto_on = scr_autohit_enabled();
    var input_pressed = true;

    var best_i  = -1;
    var best_dt = 1000000000;

    var len = array_length(global.chart);
    for (var i = 0; i < len; i++)
    {
        var n = global.chart[i];

        if (!is_struct(n)) continue;
        if (!variable_struct_exists(n, "t")) continue;
        if (!variable_struct_exists(n, "act")) continue;

        // Skip already-hit notes
        if (variable_struct_exists(n, "hit") && n.hit) continue;

        if (n.act != act) continue;

        var dt = abs(n.t - t);
        if (dt > global.WIN_BAD) continue;

        if (dt < best_dt) {
            best_dt = dt;
            best_i  = i;
        }
    }

    if (best_i < 0) return "miss";

    var within_hit_window = (best_dt <= global.WIN_BAD);

    var hit_success = false;
    var hit_accuracy = 0;
    var hit_reason = "";
    var result = "miss";

    if (auto_on)
    {
        if (within_hit_window)
        {
            hit_success = true;
            hit_accuracy = 1.0;
            hit_reason = "AUTO";
            result = "perfect";
        }
    }
    else
    {
        if (input_pressed && within_hit_window)
        {
            hit_success = true;
            hit_reason = "INPUT";

            if (variable_global_exists("WIN_PERFECT") && best_dt <= global.WIN_PERFECT) {
                result = "perfect";
                hit_accuracy = 1.0;
            }
            else if (variable_global_exists("WIN_GOOD") && best_dt <= global.WIN_GOOD) {
                result = "good";
                hit_accuracy = 0.75;
            }
            else {
                result = "bad";
                hit_accuracy = 0.5;
            }
        }
    }

    if (!hit_success) return "miss";

    // Mark note as hit (do NOT delete)
    var nn = global.chart[best_i];

    var already_judged = (variable_struct_exists(nn, "judged") && nn.judged);
    if (already_judged) {
        if (variable_global_exists("DEBUG_SCORE") && global.DEBUG_SCORE) {
            show_debug_message("[SCORE] skipped double-judge act=" + string(act) + " t=" + string(nn.t));
        }
        return result;
    }

    nn.hit = true;
    nn.judged = true;
    nn.scored = true;
    nn.hit_judge = result;
    nn.hit_time = t;

    var base_points = scr_score_base_points(act);
    scr_score_on_judge(result, base_points, {
        act       : act,
        note_time : nn.t,
        hit_time  : t,
        hit_reason: hit_reason,
        hit_accuracy: hit_accuracy,
        source    : "scr_try_trigger"
    });

    if (variable_global_exists("DEBUG_SCORE") && global.DEBUG_SCORE) {
        show_debug_message("[SCORE] " + result + " +" + string(base_points) + " total=" + string(global.score_state.score_total));
    }

    return result;
}


/// scr_score_process_passed_misses()
/// Marks overdue notes as misses exactly once and feeds score pipeline.
function scr_score_process_passed_misses()
{
    if (!variable_global_exists("chart") || is_undefined(global.chart)) return;
    if (!variable_global_exists("WIN_BAD")) return;
    if (variable_global_exists("editor_on") && global.editor_on) return;

    var _is_playing = (variable_global_exists("song_playing") && global.song_playing);
    if (!_is_playing && variable_global_exists("song_handle") && (global.song_handle >= 0)) {
        _is_playing = audio_is_playing(global.song_handle);
    }
    if (!_is_playing) return;

    var _t = scr_chart_time();
    var _late_cutoff = _t - global.WIN_BAD;

    var _len = array_length(global.chart);
    for (var i = 0; i < _len; i++)
    {
        var n = global.chart[i];
        if (!is_struct(n)) continue;
        if (!variable_struct_exists(n, "t")) continue;

        var _already_judged = (variable_struct_exists(n, "judged") && n.judged);
        if (_already_judged) continue;

        if (variable_struct_exists(n, "hit") && n.hit) {
            n.judged = true;
            n.scored = true;
            continue;
        }

        if (n.t > _late_cutoff) continue;

        n.hit = true;
        n.judged = true;
        n.scored = true;
        n.hit_judge = "miss";
        n.hit_time = _t;

        var _base_points = scr_score_base_points(variable_struct_exists(n, "act") ? n.act : "");
        scr_score_on_judge("miss", _base_points, {
            act       : variable_struct_exists(n, "act") ? n.act : "",
            note_time : n.t,
            hit_time  : _t,
            hit_reason: "MISS",
            hit_accuracy: 0,
            source    : "scr_score_process_passed_misses"
        });

        if (variable_global_exists("DEBUG_SCORE") && global.DEBUG_SCORE) {
            show_debug_message("[SCORE] miss +" + string(_base_points) + " total=" + string(global.score_state.score_total));
        }
    }
}
