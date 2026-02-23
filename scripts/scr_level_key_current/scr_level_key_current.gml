/// scr_editor_level_key_from_path(path) -> "level01" or ""
function scr_editor_level_key_from_path(_path)
{
    var raw_path = string(_path);
    if (raw_path == "") return "";

    var p = string_lower(raw_path);

    // First preference: folder segment charts/levelNN/
    var tag = "charts/level";
    var pos = string_pos(tag, p);
    if (pos > 0) {
        var num_pos = pos + string_length(tag);
        if (num_pos + 1 <= string_length(p)) {
            var d1 = string_char_at(p, num_pos);
            var d2 = string_char_at(p, num_pos + 1);
            if (d1 >= "0" && d1 <= "9" && d2 >= "0" && d2 <= "9") {
                var parsed = real(d1 + d2);
                if (parsed >= 1 && parsed <= 99) {
                    var ns = string(parsed);
                    if (string_length(ns) < 2) ns = "0" + ns;
                    return "level" + ns;
                }
            }
        }
    }

    // Fallback parse: filename contains level<digits>
    var key_pos = string_pos("level", p);
    if (key_pos > 0) {
        var i = key_pos + 5;
        var digits = "";
        while (i <= string_length(p)) {
            var ch = string_char_at(p, i);
            if (ch >= "0" && ch <= "9") {
                digits += ch;
                i += 1;
            } else {
                break;
            }
        }

        if (digits != "") {
            var n = real(digits);
            if (n >= 1 && n <= 99) {
                var ns2 = string(n);
                if (string_length(ns2) < 2) ns2 = "0" + ns2;
                return "level" + ns2;
            }
        }
    }

    return "";
}

/// scr_active_level_key() -> string like "level01"
/// Editor: derive from loaded editor chart path first, then room name mapping.
/// Runtime: preserve LEVEL_KEY behavior, with room mapping fallback.
function scr_active_level_key()
{
    var is_editor = variable_global_exists("editor_on") && global.editor_on;

    if (is_editor) {
        var editor_path = "";
        if (variable_global_exists("editor_chart_path")) editor_path = string(global.editor_chart_path);
        if (editor_path == "" && variable_global_exists("editor_chart_fullpath")) editor_path = string(global.editor_chart_fullpath);
        if (editor_path == "" && variable_global_exists("chart_file")) editor_path = string(global.chart_file);

        var editor_key = scr_editor_level_key_from_path(editor_path);
        if (editor_key != "") return editor_key;

        var room_key = scr_level_key_from_room(room);
        if (room_key != "") return room_key;

        return "";
    }

    if (variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY) && global.LEVEL_KEY != "") {
        return string_lower(global.LEVEL_KEY);
    }

    return scr_level_key_from_room(room);
}

/// scr_level_key_current() -> string
function scr_level_key_current()
{
    return scr_active_level_key();
}
