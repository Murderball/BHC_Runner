/// scr_difficulty_events_from_markers()
/// Reads global.markers and builds global.diff_events (time-ordered)
/// Adds per-event swap flags: swap_visual / swap_audio
function scr_difficulty_events_from_markers()
{
    global.diff_events = [];

    if (!is_array(global.markers) || array_length(global.markers) == 0) return;

    // Defaults if you want a global fallback (safe if you already set these elsewhere)
    if (!variable_global_exists("diff_swap_visual")) global.diff_swap_visual = true;
    if (!variable_global_exists("diff_swap_audio"))  global.diff_swap_audio  = true;

    for (var i = 0; i < array_length(global.markers); i++)
    {
        var m = global.markers[i];
        if (!is_struct(m)) continue;

        if (!variable_struct_exists(m, "type")) continue;
        if (m.type != "difficulty" && m.type != "diff") continue;

        if (!variable_struct_exists(m, "t")) continue;
        if (!is_real(m.t) || m.t < 0) continue;

        // --- difficulty target ---
        var d = "normal";
        if (variable_struct_exists(m, "diff") && is_string(m.diff)) d = string_lower(m.diff);

        // sanitize
        if (d != "easy" && d != "normal" && d != "hard") d = "normal";

        // --- swap behavior (visual/audio) ---
        // Start from global defaults
        var sv = global.diff_swap_visual;
        var sa = global.diff_swap_audio;

        // If marker provides explicit booleans, they win
        if (variable_struct_exists(m, "swap_visual") && is_bool(m.swap_visual)) sv = m.swap_visual;
        if (variable_struct_exists(m, "swap_audio")  && is_bool(m.swap_audio))  sa = m.swap_audio;

        // If marker provides a swap mode string, it wins over defaults
        if (variable_struct_exists(m, "swap") && is_string(m.swap))
        {
            var s = string_lower(m.swap);

            // normalize common synonyms
            if (s == "tiles" || s == "tile" || s == "tilemap") s = "visual";
            if (s == "music" || s == "song") s = "audio";

            if (s == "visual") { sv = true;  sa = false; }
            else if (s == "audio")  { sv = false; sa = true;  }
            else if (s == "both")   { sv = true;  sa = true;  }
            // else: leave sv/sa as-is
        }

        array_push(global.diff_events, {
            t: m.t,
            diff: d,
            swap_visual: sv,
            swap_audio: sa,
            done: false
        });
    }

    // sort by time
    var n = array_length(global.diff_events);
    for (var a = 0; a < n - 1; a++) {
        for (var b = a + 1; b < n; b++) {
            if (global.diff_events[a].t > global.diff_events[b].t) {
                var tmp = global.diff_events[a];
                global.diff_events[a] = global.diff_events[b];
                global.diff_events[b] = tmp;
            }
        }
    }
}