function scr_room_flow_init()
{
    // Define your level as an ordered list of rooms (edit these rooms manually)
    // Use the rooms you already have: rm_chunk_intro, rm_chunk_verse, etc.
    global.LEVEL_ROOMS = [
        rm_chunk_intro,
        rm_chunk_verse,
        rm_chunk_verse_2,
        rm_chunk_prechorus,
        rm_chunk_chorus,
        rm_chunk_build,
        rm_chunk_break,
        rm_chunk_bridge,
        rm_chunk_chorus_2,
        rm_chunk_outro
    ];

    global.ROOM_INDEX = 0;
    global.WORLD_X_BASE = 0;
}
