/// scr_reload_level_media_for_diff(diff)
/// Editor-only media reload path used by difficulty hotkeys.
function scr_reload_level_media_for_diff(_diff)
{
    var diff = string_lower(string(_diff));
    if (diff != "easy" && diff != "normal" && diff != "hard") diff = "normal";

    var level_key = "";
    if (script_exists(scr_active_level_key)) level_key = string_lower(string(scr_active_level_key()));

    var level_index = -1;
    if (string_length(level_key) >= 6 && string_pos("level", level_key) == 1) {
        var digits = string_delete(level_key, 1, 5);
        if (digits != "") {
            var parsed = real(digits);
            if (!is_nan(parsed)) level_index = clamp(floor(parsed), 1, 99);
        }
    }

    if (level_index < 1) {
        show_debug_message("[EDITOR AUDIO] reload skipped: invalid active level key='" + level_key + "' diff=" + diff);
        return;
    }

    show_debug_message("[EDITOR AUDIO] reload diff=" + diff + " active_level_key=" + level_key + " level_index=" + string(level_index));

    if (script_exists(scr_editor_preview_music_set)) {
        scr_editor_preview_music_set(level_index, diff);
    }
}
