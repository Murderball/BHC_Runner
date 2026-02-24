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


/// scr_editor_level_key_from_path(path) -> "level01" or ""
function scr_editor_level_key_from_path(_path)
{
    var p = string_lower(string(_path));
    if (p == "") return "";

    p = string_replace_all(p, "\\", "/");

    var charts_pos = string_pos("charts/", p);
    if (charts_pos > 0) {
        var seg_start = charts_pos + string_length("charts/");
        var tail = string_delete(p, 1, seg_start - 1);
        var slash_pos = string_pos("/", tail);
        var seg = (slash_pos > 0) ? string_copy(tail, 1, slash_pos - 1) : tail;
        if (string_pos("level", seg) == 1 && string_length(seg) >= 6) {
            var digits = string_delete(seg, 1, 5);
            if (digits != "") {
                var idx = clamp(real(digits), 1, 99);
                if (!is_nan(idx)) {
                    var n = floor(idx);
                    return "level" + ((n < 10) ? "0" : "") + string(n);
                }
            }
        }
    }

    var lvl_pos = string_pos("level", p);
    if (lvl_pos > 0) {
        var i = lvl_pos + 5;
        var digits2 = "";
        while (i <= string_length(p)) {
            var ch = string_char_at(p, i);
            if (ch >= "0" && ch <= "9") {
                digits2 += ch;
                i += 1;
            } else {
                break;
            }
        }

        if (digits2 != "") {
            var idx2 = clamp(real(digits2), 1, 99);
            if (!is_nan(idx2)) {
                var n2 = floor(idx2);
                return "level" + ((n2 < 10) ? "0" : "") + string(n2);
            }
        }
    }

    return "";
}

/// scr_active_level_key() -> authoritative level key for editor+runtime
function scr_active_level_key()
{
    var in_editor = false;
    if (variable_global_exists("in_editor") && global.in_editor) in_editor = true;
    if (variable_global_exists("editor_on") && global.editor_on) in_editor = true;

    if (in_editor) {
        var chart_path = "";
        if (variable_global_exists("editor_chart_path")) chart_path = string(global.editor_chart_path);
        if (chart_path == "" && variable_global_exists("editor_chart_fullpath")) chart_path = string(global.editor_chart_fullpath);
        if (chart_path == "" && variable_global_exists("chart_file")) chart_path = string(global.chart_file);

        var editor_key = scr_editor_level_key_from_path(chart_path);
        if (editor_key != "") return editor_key;

        var rn = string_lower(room_get_name(room));
        var room_key = scr_editor_level_key_from_path(rn);
        if (room_key != "") return room_key;

        if (variable_global_exists("editor_level_index") && is_real(global.editor_level_index)) {
            var ei = clamp(floor(real(global.editor_level_index)), 1, 99);
            return "level" + ((ei < 10) ? "0" : "") + string(ei);
        }
    }

    if (variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY) && global.LEVEL_KEY != "") {
        return string_lower(string(global.LEVEL_KEY));
    }

    if (script_exists(scr_level_key_from_room)) {
        return string_lower(string(scr_level_key_from_room(room)));
    }

    return "";
}
