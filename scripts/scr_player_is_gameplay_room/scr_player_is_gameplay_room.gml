function scr_player_is_gameplay_room()
{
    // If your game state is explicitly "play", treat as gameplay.
    if (variable_global_exists("GAME_STATE") && global.GAME_STATE == "play") return true;

    var rn = room_get_name(room);

    // Any main level rooms: rm_level01, rm_level03, rm_level10 etc
    if (string_pos("rm_level", rn) == 1) return true;

    // Any boss rooms: rm_boss, rm_boss_3, rm_boss_06, etc
    if (string_pos("rm_boss", rn) == 1) return true;

    // All streamed chunk rooms
    if (string_pos("rm_chunk_", rn) == 1) return true;

    return false;
}
