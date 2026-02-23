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

function scr_media_trace_enabled()
{
    return variable_global_exists("DEBUG_MEDIA_TRACE") && global.DEBUG_MEDIA_TRACE;
}

function scr_media_trace_sound_name(_snd)
{
    if (!is_real(_snd) || !audio_exists(_snd)) return "<none>";
    return asset_get_name(_snd);
}

function scr_media_trace_idx_dump()
{
    var out = "";

    if (variable_global_exists("song_level_idx")) out += " song_level_idx=" + string(global.song_level_idx);
    if (variable_global_exists("current_level")) out += " current_level=" + string(global.current_level);
    if (variable_global_exists("level_idx")) out += " level_idx=" + string(global.level_idx);
    if (variable_global_exists("editor_level_index")) out += " editor_level_index=" + string(global.editor_level_index);
    if (variable_global_exists("editor_chart_level_index")) out += " editor_chart_level_index=" + string(global.editor_chart_level_index);

    return out;
}

function scr_media_trace_assert_editor_level_key(_resolved_level_key)
{
    if (!scr_media_trace_enabled()) return;
    if (!(variable_global_exists("editor_on") && global.editor_on)) return;
    if (!variable_global_exists("editor_chart_path")) return;

    var p = string_lower(string(global.editor_chart_path));
    if (string_pos("charts/level01/", p) != 1) return;

    if (string_lower(string(_resolved_level_key)) != "level01") {
        show_debug_message("[MEDIA TRACE][ASSERT] MISMATCH expected=level01 got=" + string(_resolved_level_key)
            + " path=" + string(global.editor_chart_path));
    }
}

function scr_media_trace(_fn, _resolved_level_key, _diff, _resolved_sound)
{
    if (!scr_media_trace_enabled()) return;

    var is_editor = (variable_global_exists("editor_on") && global.editor_on) ? 1 : 0;
    var room_name = room_get_name(room);
    var editor_path = "<none>";
    if (variable_global_exists("editor_chart_path") && string(global.editor_chart_path) != "") {
        editor_path = string(global.editor_chart_path);
    }

    show_debug_message("[MEDIA TRACE] fn=" + string(_fn)
        + " room=" + room_name
        + " editor=" + string(is_editor)
        + " editor_chart_path=" + editor_path
        + " resolved_level_key=" + string(_resolved_level_key)
        + " diff=" + string(_diff)
        + " resolved_sound=" + string(_resolved_sound)
        + " resolved_sound_name=" + scr_media_trace_sound_name(_resolved_sound)
        + scr_media_trace_idx_dump());

    scr_media_trace_assert_editor_level_key(_resolved_level_key);
}

/// scr_active_level_key() -> string like "level01"
/// Editor: derive from loaded editor chart path first, then room name mapping.
/// Runtime: preserve LEVEL_KEY behavior, with room mapping fallback.
function scr_active_level_key()
{
    var is_editor = variable_global_exists("editor_on") && global.editor_on;
    var resolved = "";

    if (is_editor) {
        var editor_path = "";
        if (variable_global_exists("editor_chart_path")) editor_path = string(global.editor_chart_path);
        if (editor_path == "" && variable_global_exists("editor_chart_fullpath")) editor_path = string(global.editor_chart_fullpath);
        if (editor_path == "" && variable_global_exists("chart_file")) editor_path = string(global.chart_file);

        var editor_key = scr_editor_level_key_from_path(editor_path);
        if (editor_key != "") resolved = editor_key;

        if (resolved == "") {
            var room_key = scr_level_key_from_room(room);
            if (room_key != "") resolved = room_key;
        }
    }

    if (resolved == "" && variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY) && global.LEVEL_KEY != "") {
        resolved = string_lower(global.LEVEL_KEY);
    }

    if (resolved == "") resolved = scr_level_key_from_room(room);

    scr_media_trace("scr_active_level_key", resolved, "<na>", -1);
    return resolved;
}

/// scr_level_key_current() -> string
function scr_level_key_current()
{
    return scr_active_level_key();
}
