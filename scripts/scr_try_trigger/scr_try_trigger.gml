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

    var judge = "miss";
    var auto_hit = (variable_global_exists("AUTO_HIT_ENABLED") && global.AUTO_HIT_ENABLED);

    // If chart isn't loaded, can't judge (safe)
    if (!variable_global_exists("chart") || is_undefined(global.chart)) return "miss";

    var t = scr_chart_time();

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

        // Need timing windows
        if (!variable_global_exists("WIN_BAD")) return "miss";

        var dt = abs(n.t - t);
        if (!auto_hit && dt > global.WIN_BAD) continue;

        if (dt < best_dt) {
            best_dt = dt;
            best_i  = i;
        }
    }

    if (best_i < 0) return "miss";

    // Judge
    var result;
    if (auto_hit) result = "perfect";
    else if (variable_global_exists("WIN_PERFECT") && best_dt <= global.WIN_PERFECT) result = "perfect";
    else if (variable_global_exists("WIN_GOOD") && best_dt <= global.WIN_GOOD) result = "good";
    else result = "bad";

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
            source    : "scr_score_process_passed_misses"
        });

        if (variable_global_exists("DEBUG_SCORE") && global.DEBUG_SCORE) {
            show_debug_message("[SCORE] miss +" + string(_base_points) + " total=" + string(global.score_state.score_total));
        }
    }
}
