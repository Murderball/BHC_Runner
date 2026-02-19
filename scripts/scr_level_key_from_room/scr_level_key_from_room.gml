/// scr_level_key_from_room([room_id]) -> "level01", "level03", etc.
function scr_level_key_from_room(_room_id)
{
    var rid = (argument_count >= 1) ? _room_id : room;

    var rn = room_get_name(rid);
    if (!is_string(rn) || rn == "") return "level03"; // safe fallback

    rn = string_lower(rn);

    // Primary: gameplay rooms
    if (string_pos("rm_level01", rn) == 1) return "level01";
    if (string_pos("rm_level03", rn) == 1) return "level03";

    // Optional: boss rooms (if you name them like rm_boss_1, rm_boss_3)
    if (string_pos("rm_boss_1", rn) == 1) return "level01";
    if (string_pos("rm_boss_3", rn) == 1) return "level03";

    // Optional: chunk rooms (helps editor/testing if you ever jump into a chunk room directly)
    if (string_pos("rm1_chunk_", rn) == 1) return "level01";
    if (string_pos("rm_chunk_", rn) == 1)  return "level03";

    // Fallback
    return "level03";
}
