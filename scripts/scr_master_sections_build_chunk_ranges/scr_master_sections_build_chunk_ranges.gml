function scr_master_sections_build_chunk_ranges()
{
    scr_level_master_sections_init();
    scr_chunk_system_init();

    if (!variable_global_exists("master_sections") || !is_array(global.master_sections)) return;

    var dt = global.CHUNK_DT_S;
    if (dt <= 0) dt = 1;

    var secs = global.master_sections;
    var n = array_length(secs);

    global.master_sections_chunks = array_create(n);

    for (var i = 0; i < n; i++) {
        var s = secs[i];

        // stable rounding (float-safe)
        var denom_dt0 = dt;
    if (denom_dt0 == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_dt0 = 1;
    }
    var ci0 = round(s.t0 / denom_dt0); // inclusive
        var denom_dt1 = dt;
    if (denom_dt1 == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_dt1 = 1;
    }
    var ci1 = round(s.t1 / denom_dt1); // exclusive

        if (ci1 <= ci0) ci1 = ci0 + 1;

        global.master_sections_chunks[i] = {
            name:  s.name,
            t0:    s.t0,
            t1:    s.t1,
            ci0:   ci0,
            ci1:   ci1,
            count: (ci1 - ci0)
        };
    }

    // Back-compat: keep Level 3 alias if current key is level03
    if (variable_global_exists("master_sections_key") && global.master_sections_key == "level03") {
        global.level3_master_sections_chunks = global.master_sections_chunks;
    }
}
