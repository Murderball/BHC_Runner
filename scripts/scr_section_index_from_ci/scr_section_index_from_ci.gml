function scr_section_index_from_ci(ci) {
    // Build ranges if missing
    if (!variable_global_exists("level3_master_sections_chunks")) {
        scr_master_sections_build_chunk_ranges();
    }

    var a = global.level3_master_sections_chunks;
    var n = array_length(a);

    // Linear search is fine for ~20 sections (fast).
    // If you ever have hundreds, we can binary search.
    for (var i = 0; i < n; i++) {
        var s = a[i];
        if (ci >= s.ci0 && ci < s.ci1) return i;
    }

    // Outside timeline: clamp
    if (ci < a[0].ci0) return 0;
    return n - 1;
}
