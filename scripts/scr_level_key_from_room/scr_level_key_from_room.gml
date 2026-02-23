/// scr_level_key_from_room([room_id]) -> "level01", "level03", etc.
function scr_level_key_from_room(_room_id)
{
    var rid = (argument_count >= 1) ? _room_id : room;

    var rn = room_get_name(rid);
    if (!is_string(rn) || rn == "") return "level01";

    rn = string_lower(rn);

    // Primary: gameplay rooms
    if (string_pos("rm_level01", rn) > 0) return "level01";
    if (string_pos("rm_level03", rn) > 0) return "level03";

    // Optional: boss rooms
    if (string_pos("rm_boss_1", rn) > 0) return "level01";
    if (string_pos("rm_boss_3", rn) > 0) return "level03";

    // Optional: chunk rooms
    if (string_pos("rm1_chunk_", rn) > 0) return "level01";
    if (string_pos("rm_chunk_", rn) > 0)  return "level03";

    // Fallback
    return "level01";
}

/// scr_level_key_to_index(level_key) -> numeric index (1..6)
function scr_level_key_to_index(_level_key)
{
    var lk = string_lower(string(_level_key));
    if (lk == "") return 1;

    if (string_pos("level", lk) == 1 && string_length(lk) >= 6)
    {
        var n = real(string_copy(lk, 6, string_length(lk) - 5));
        if (is_real(n) && !is_nan(n)) return clamp(floor(n), 1, 6);
    }

    var d = real(lk);
    if (is_real(d) && !is_nan(d)) return clamp(floor(d), 1, 6);

    return 1;
}

/// scr_level_resolve_key() -> canonical level key for current context.
/// Priority:
/// 1) global.level_key (new canonical runtime key)
/// 2) global.LEVEL_KEY (legacy runtime key)
/// 3) global.editor_level_key (editor context)
/// 4) room name inference
/// 5) safe default level01 (+ warn once)
function scr_level_resolve_key()
{
    var key = "";

    if (variable_global_exists("level_key") && is_string(global.level_key)) {
        key = string_lower(string(global.level_key));
    }

    if (key == "" && variable_global_exists("editor_level_key") && is_string(global.editor_level_key)) {
        key = string_lower(string(global.editor_level_key));
    }

    // Legacy compatibility
    if (key == "" && variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY)) {
        key = string_lower(string(global.LEVEL_KEY));
    }

    if (key == "") {
        key = scr_level_key_from_room(room);
    }

    if (key != "level01" && key != "level03")
    {
        var inferred = scr_level_key_from_room(room);
        if (inferred == "level01" || inferred == "level03") {
            key = inferred;
        } else {
            key = "level01";
            if (!variable_global_exists("__warn_level_resolve_fallback")) global.__warn_level_resolve_fallback = false;
            if (!global.__warn_level_resolve_fallback) {
                global.__warn_level_resolve_fallback = true;
                var rn = room_get_name(room);
                show_debug_message("[LEVEL] WARNING unresolved level key; fallback=level01 room=" + string(rn));
            }
        }
    }

    return key;
}
