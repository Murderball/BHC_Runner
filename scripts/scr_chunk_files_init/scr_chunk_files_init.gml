/// scr_chunk_files_init()
/// Ensures global.chunk_files exists and is populated.
/// Returns: ds_map id (global.chunk_files)


function scr_chunk_files_init()
{
// Already exists?
if (variable_global_exists("chunk_files") && ds_exists(global.chunk_files, ds_type_map)) {
return global.chunk_files;
}

    global.chunk_files = ds_map_create();

    // intro (5)
ds_map_add(global.chunk_files, "intro_00", "chunk_rm_chunk_intro_00.json");
ds_map_add(global.chunk_files, "intro_01", "chunk_rm_chunk_intro_01.json");
ds_map_add(global.chunk_files, "intro_02", "chunk_rm_chunk_intro_02.json");
ds_map_add(global.chunk_files, "intro_03", "chunk_rm_chunk_intro_03.json");
ds_map_add(global.chunk_files, "intro_04", "chunk_rm_chunk_intro_04.json");

// break (1)
ds_map_add(global.chunk_files, "break_00", "chunk_rm_chunk_break_00.json");

// main (8)
ds_map_add(global.chunk_files, "main_00", "chunk_rm_chunk_main_00.json");
ds_map_add(global.chunk_files, "main_01", "chunk_rm_chunk_main_01.json");
ds_map_add(global.chunk_files, "main_02", "chunk_rm_chunk_main_02.json");
ds_map_add(global.chunk_files, "main_03", "chunk_rm_chunk_main_03.json");
ds_map_add(global.chunk_files, "main_04", "chunk_rm_chunk_main_04.json");
ds_map_add(global.chunk_files, "main_05", "chunk_rm_chunk_main_05.json");
ds_map_add(global.chunk_files, "main_06", "chunk_rm_chunk_main_06.json");
ds_map_add(global.chunk_files, "main_07", "chunk_rm_chunk_main_07.json");

// verse (8)
ds_map_add(global.chunk_files, "verse_00", "chunk_rm_chunk_verse_00.json");
ds_map_add(global.chunk_files, "verse_01", "chunk_rm_chunk_verse_01.json");
ds_map_add(global.chunk_files, "verse_02", "chunk_rm_chunk_verse_02.json");
ds_map_add(global.chunk_files, "verse_03", "chunk_rm_chunk_verse_03.json");
ds_map_add(global.chunk_files, "verse_04", "chunk_rm_chunk_verse_04.json");
ds_map_add(global.chunk_files, "verse_05", "chunk_rm_chunk_verse_05.json");
ds_map_add(global.chunk_files, "verse_06", "chunk_rm_chunk_verse_06.json");
ds_map_add(global.chunk_files, "verse_07", "chunk_rm_chunk_verse_07.json");

// prechorus (4)
ds_map_add(global.chunk_files, "prechorus_00", "chunk_rm_chunk_prechorus_00.json");
ds_map_add(global.chunk_files, "prechorus_01", "chunk_rm_chunk_prechorus_01.json");
ds_map_add(global.chunk_files, "prechorus_02", "chunk_rm_chunk_prechorus_02.json");
ds_map_add(global.chunk_files, "prechorus_03", "chunk_rm_chunk_prechorus_03.json");

// chorus (8)
ds_map_add(global.chunk_files, "chorus_00", "chunk_rm_chunk_chorus_00.json");
ds_map_add(global.chunk_files, "chorus_01", "chunk_rm_chunk_chorus_01.json");
ds_map_add(global.chunk_files, "chorus_02", "chunk_rm_chunk_chorus_02.json");
ds_map_add(global.chunk_files, "chorus_03", "chunk_rm_chunk_chorus_03.json");
ds_map_add(global.chunk_files, "chorus_04", "chunk_rm_chunk_chorus_04.json");
ds_map_add(global.chunk_files, "chorus_05", "chunk_rm_chunk_chorus_05.json");
ds_map_add(global.chunk_files, "chorus_06", "chunk_rm_chunk_chorus_06.json");
ds_map_add(global.chunk_files, "chorus_07", "chunk_rm_chunk_chorus_07.json");

// chorus_2 (8)
ds_map_add(global.chunk_files, "chorus_2_00", "chunk_rm_chunk_chorus_2_00.json");
ds_map_add(global.chunk_files, "chorus_2_01", "chunk_rm_chunk_chorus_2_01.json");
ds_map_add(global.chunk_files, "chorus_2_02", "chunk_rm_chunk_chorus_2_02.json");
ds_map_add(global.chunk_files, "chorus_2_03", "chunk_rm_chunk_chorus_2_03.json");
ds_map_add(global.chunk_files, "chorus_2_04", "chunk_rm_chunk_chorus_2_04.json");
ds_map_add(global.chunk_files, "chorus_2_05", "chunk_rm_chunk_chorus_2_05.json");
ds_map_add(global.chunk_files, "chorus_2_06", "chunk_rm_chunk_chorus_2_06.json");
ds_map_add(global.chunk_files, "chorus_2_07", "chunk_rm_chunk_chorus_2_07.json");

// verse_2 (6)
ds_map_add(global.chunk_files, "verse_2_00", "chunk_rm_chunk_verse_2_00.json");
ds_map_add(global.chunk_files, "verse_2_01", "chunk_rm_chunk_verse_2_01.json");
ds_map_add(global.chunk_files, "verse_2_02", "chunk_rm_chunk_verse_2_02.json");
ds_map_add(global.chunk_files, "verse_2_03", "chunk_rm_chunk_verse_2_03.json");
ds_map_add(global.chunk_files, "verse_2_04", "chunk_rm_chunk_verse_2_04.json");
ds_map_add(global.chunk_files, "verse_2_05", "chunk_rm_chunk_verse_2_05.json");

// break_2 (2)
ds_map_add(global.chunk_files, "break_2_00", "chunk_rm_chunk_break_2_00.json");
ds_map_add(global.chunk_files, "break_2_01", "chunk_rm_chunk_break_2_01.json");

// breakdown (8)
ds_map_add(global.chunk_files, "breakdown_00", "chunk_rm_chunk_breakdown_00.json");
ds_map_add(global.chunk_files, "breakdown_01", "chunk_rm_chunk_breakdown_01.json");
ds_map_add(global.chunk_files, "breakdown_02", "chunk_rm_chunk_breakdown_02.json");
ds_map_add(global.chunk_files, "breakdown_03", "chunk_rm_chunk_breakdown_03.json");
ds_map_add(global.chunk_files, "breakdown_04", "chunk_rm_chunk_breakdown_04.json");
ds_map_add(global.chunk_files, "breakdown_05", "chunk_rm_chunk_breakdown_05.json");
ds_map_add(global.chunk_files, "breakdown_06", "chunk_rm_chunk_breakdown_06.json");
ds_map_add(global.chunk_files, "breakdown_07", "chunk_rm_chunk_breakdown_07.json");

// prechorus_2 (8)
ds_map_add(global.chunk_files, "prechorus_2_00", "chunk_rm_chunk_prechorus_2_00.json");
ds_map_add(global.chunk_files, "prechorus_2_01", "chunk_rm_chunk_prechorus_2_01.json");
ds_map_add(global.chunk_files, "prechorus_2_02", "chunk_rm_chunk_prechorus_2_02.json");
ds_map_add(global.chunk_files, "prechorus_2_03", "chunk_rm_chunk_prechorus_2_03.json");
ds_map_add(global.chunk_files, "prechorus_2_04", "chunk_rm_chunk_prechorus_2_04.json");
ds_map_add(global.chunk_files, "prechorus_2_05", "chunk_rm_chunk_prechorus_2_05.json");
ds_map_add(global.chunk_files, "prechorus_2_06", "chunk_rm_chunk_prechorus_2_06.json");
ds_map_add(global.chunk_files, "prechorus_2_07", "chunk_rm_chunk_prechorus_2_07.json");

// chorus_return (7)
ds_map_add(global.chunk_files, "chorus_return_00", "chunk_rm_chunk_chorus_return_00.json");
ds_map_add(global.chunk_files, "chorus_return_01", "chunk_rm_chunk_chorus_return_01.json");
ds_map_add(global.chunk_files, "chorus_return_02", "chunk_rm_chunk_chorus_return_02.json");
ds_map_add(global.chunk_files, "chorus_return_03", "chunk_rm_chunk_chorus_return_03.json");
ds_map_add(global.chunk_files, "chorus_return_04", "chunk_rm_chunk_chorus_return_04.json");
ds_map_add(global.chunk_files, "chorus_return_05", "chunk_rm_chunk_chorus_return_05.json");
ds_map_add(global.chunk_files, "chorus_return_06", "chunk_rm_chunk_chorus_return_06.json");

// break_3 (1)
ds_map_add(global.chunk_files, "break_3_00", "chunk_rm_chunk_break_3_00.json");

// bridge (8)
ds_map_add(global.chunk_files, "bridge_00", "chunk_rm_chunk_bridge_00.json");
ds_map_add(global.chunk_files, "bridge_01", "chunk_rm_chunk_bridge_01.json");
ds_map_add(global.chunk_files, "bridge_02", "chunk_rm_chunk_bridge_02.json");
ds_map_add(global.chunk_files, "bridge_03", "chunk_rm_chunk_bridge_03.json");
ds_map_add(global.chunk_files, "bridge_04", "chunk_rm_chunk_bridge_04.json");
ds_map_add(global.chunk_files, "bridge_05", "chunk_rm_chunk_bridge_05.json");
ds_map_add(global.chunk_files, "bridge_06", "chunk_rm_chunk_bridge_06.json");
ds_map_add(global.chunk_files, "bridge_07", "chunk_rm_chunk_bridge_07.json");

// build (8)
ds_map_add(global.chunk_files, "build_00", "chunk_rm_chunk_build_00.json");
ds_map_add(global.chunk_files, "build_01", "chunk_rm_chunk_build_01.json");
ds_map_add(global.chunk_files, "build_02", "chunk_rm_chunk_build_02.json");
ds_map_add(global.chunk_files, "build_03", "chunk_rm_chunk_build_03.json");
ds_map_add(global.chunk_files, "build_04", "chunk_rm_chunk_build_04.json");
ds_map_add(global.chunk_files, "build_05", "chunk_rm_chunk_build_05.json");
ds_map_add(global.chunk_files, "build_06", "chunk_rm_chunk_build_06.json");
ds_map_add(global.chunk_files, "build_07", "chunk_rm_chunk_build_07.json");

// breakdown_2 (8)
ds_map_add(global.chunk_files, "breakdown_2_00", "chunk_rm_chunk_breakdown_2_00.json");
ds_map_add(global.chunk_files, "breakdown_2_01", "chunk_rm_chunk_breakdown_2_01.json");
ds_map_add(global.chunk_files, "breakdown_2_02", "chunk_rm_chunk_breakdown_2_02.json");
ds_map_add(global.chunk_files, "breakdown_2_03", "chunk_rm_chunk_breakdown_2_03.json");
ds_map_add(global.chunk_files, "breakdown_2_04", "chunk_rm_chunk_breakdown_2_04.json");
ds_map_add(global.chunk_files, "breakdown_2_05", "chunk_rm_chunk_breakdown_2_05.json");
ds_map_add(global.chunk_files, "breakdown_2_06", "chunk_rm_chunk_breakdown_2_06.json");
ds_map_add(global.chunk_files, "breakdown_2_07", "chunk_rm_chunk_breakdown_2_07.json");

// chorus_3 (8)
ds_map_add(global.chunk_files, "chorus_3_00", "chunk_rm_chunk_chorus_3_00.json");
ds_map_add(global.chunk_files, "chorus_3_01", "chunk_rm_chunk_chorus_3_01.json");
ds_map_add(global.chunk_files, "chorus_3_02", "chunk_rm_chunk_chorus_3_02.json");
ds_map_add(global.chunk_files, "chorus_3_03", "chunk_rm_chunk_chorus_3_03.json");
ds_map_add(global.chunk_files, "chorus_3_04", "chunk_rm_chunk_chorus_3_04.json");
ds_map_add(global.chunk_files, "chorus_3_05", "chunk_rm_chunk_chorus_3_05.json");
ds_map_add(global.chunk_files, "chorus_3_06", "chunk_rm_chunk_chorus_3_06.json");
ds_map_add(global.chunk_files, "chorus_3_07", "chunk_rm_chunk_chorus_3_07.json");

// outro (8)
ds_map_add(global.chunk_files, "outro_00", "chunk_rm_chunk_outro_00.json");
ds_map_add(global.chunk_files, "outro_01", "chunk_rm_chunk_outro_01.json");
ds_map_add(global.chunk_files, "outro_02", "chunk_rm_chunk_outro_02.json");
ds_map_add(global.chunk_files, "outro_03", "chunk_rm_chunk_outro_03.json");
ds_map_add(global.chunk_files, "outro_04", "chunk_rm_chunk_outro_04.json");
ds_map_add(global.chunk_files, "outro_05", "chunk_rm_chunk_outro_05.json");
ds_map_add(global.chunk_files, "outro_06", "chunk_rm_chunk_outro_06.json");
ds_map_add(global.chunk_files, "outro_07", "chunk_rm_chunk_outro_07.json");

    return global.chunk_files;
}