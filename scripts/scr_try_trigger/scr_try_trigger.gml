/// scr_try_trigger(act)
/// Judges closest matching note by act.
/// Test-room safe: returns "perfect" if no chart/time exists.

function scr_try_trigger(act)
{
    if (!variable_global_exists("__dbg_note_hit_once")) global.__dbg_note_hit_once = false;

    // ----------------------------
    // TEST ROOM: always succeed
    // ----------------------------
    if (variable_global_exists("LEVEL_MODE") && global.LEVEL_MODE == "test")
    {
        return "perfect";
    }

    var judge = "miss";

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
        if (dt > global.WIN_BAD) continue;

        if (dt < best_dt) {
            best_dt = dt;
            best_i  = i;
        }
    }

    if (best_i < 0) return "miss";

    // Judge
    var result;
    if (variable_global_exists("WIN_PERFECT") && best_dt <= global.WIN_PERFECT) result = "perfect";
    else if (variable_global_exists("WIN_GOOD") && best_dt <= global.WIN_GOOD) result = "good";
    else result = "bad";

    // Mark note as hit (do NOT delete)
    var nn = global.chart[best_i];
    nn.hit = true;
    nn.hit_judge = result;
    nn.hit_time = t;
    if (!variable_struct_exists(nn, "hit_fx_t")) nn.hit_fx_t = 0;
    if (!variable_struct_exists(nn, "hit_fx_dur")) nn.hit_fx_dur = 0.10;
    if (!variable_struct_exists(nn, "hit_fx_pow")) nn.hit_fx_pow = 0;
    nn.hit_fx_t = nn.hit_fx_dur;
    nn.hit_fx_pow = 1;

    if (!global.__dbg_note_hit_once)
    {
        global.__dbg_note_hit_once = true;
        show_debug_message("[NOTE HIT PATH] scr_try_trigger called act=" + string(act)
            + " judge=" + string(result)
            + " hit_fx_t=" + string(nn.hit_fx_t)
            + " hit_fx_dur=" + string(nn.hit_fx_dur));
    }

    if (variable_global_exists("dbg_song_overlay_on") && global.dbg_song_overlay_on) {
        show_debug_message("[NOTE HIT FX] id=" + string(best_i) + " fx_dur=" + string(nn.hit_fx_dur));
    }

    return result;
}
