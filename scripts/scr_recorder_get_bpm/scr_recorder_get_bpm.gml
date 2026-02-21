function scr_recorder_get_bpm()
{
    var _pick = function(_value)
    {
        if (is_real(_value) && _value > 0) return _value;
        return -1;
    };

    // a) Global BPM variables (prefer existing chart clock globals first)
    var _global_keys = ["chart_bpm", "BPM", "level_bpm", "SONG_BPM", "BOSS_BPM"];
    for (var i = 0; i < array_length(_global_keys); i++)
    {
        var k = _global_keys[i];
        if (variable_global_exists(k))
        {
            var v = _pick(variable_global_get(k));
            if (v > 0) return v;
        }
    }

    // b) Chart/level structs with bpm fields
    var _chart_struct_keys = ["chart_data", "CUR_CHART", "chart_struct", "chart"];
    for (var j = 0; j < array_length(_chart_struct_keys); j++)
    {
        var sk = _chart_struct_keys[j];
        if (variable_global_exists(sk))
        {
            var s = variable_global_get(sk);
            if (is_struct(s) && variable_struct_exists(s, "bpm"))
            {
                var sv = _pick(s.bpm);
                if (sv > 0) return sv;
            }
        }
    }

    // c) Existing "get bpm" scripts (if present)
    var _getter_scripts = ["scr_get_bpm", "scr_chart_get_bpm", "scr_level_get_bpm"];
    for (var n = 0; n < array_length(_getter_scripts); n++)
    {
        var sn = _getter_scripts[n];
        var sid = asset_get_index(sn);
        if (sid >= 0)
        {
            var out = _pick(script_execute(sid));
            if (out > 0) return out;
        }
    }

    // d) No valid BPM available yet
    return -1;
}
