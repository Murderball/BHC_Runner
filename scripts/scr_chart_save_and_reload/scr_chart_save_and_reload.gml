function scr_chart_filename(_level_index, _diff, _is_boss)
{
    var level_index = clamp(floor(real(_level_index)), 1, 6);

    var diff = string_lower(string(_diff));
    if (diff != "easy" && diff != "normal" && diff != "hard") {
        diff = "normal";
    }

    var prefix = (_is_boss) ? "boss_" : "";
    return prefix + "level" + string(level_index) + "_" + diff + ".json";
}

function scr_chart_fullpath(_filename)
{
    var filename = string(_filename);

    var lvl = 1;
    var p = string_pos("level", filename);
    if (p > 0)
    {
        var pnum = p + 5;
        var num_txt = "";
        while (pnum <= string_length(filename))
        {
            var ch = string_char_at(filename, pnum);
            if (ch >= "0" && ch <= "9") {
                num_txt += ch;
                pnum += 1;
            } else {
                break;
            }
        }

        if (num_txt != "") lvl = clamp(real(num_txt), 1, 6);
    }

    var level_key = "level0" + string(lvl);
    return "charts/" + level_key + "/" + filename;
}

function scr_editor_chart_autosave()
{
    if (!variable_global_exists("editor_chart_fullpath")) return false;

    var path = string(global.editor_chart_fullpath);
    if (path == "") return false;

    global.chart_file = path;

    if (script_exists(scr_chart_save)) {
        scr_chart_save();
        return true;
    }

    return false;
}

function scr_editor_chart_switch(_fullpath, _level_index, _diff, _is_boss)
{
    scr_editor_chart_autosave();

    var path = string(_fullpath);
    var level_index = clamp(floor(real(_level_index)), 1, 6);
    var diff = string_lower(string(_diff));
    if (diff != "easy" && diff != "normal" && diff != "hard") diff = "normal";

    global.chart_file = path;

    if (script_exists(scr_chart_load)) scr_chart_load();

    if (script_exists(scr_editor_selection_clear)) scr_editor_selection_clear();
    if (script_exists(scr_autohit_reset)) scr_autohit_reset();
    if (script_exists(scr_attack_timeline_build)) scr_attack_timeline_build();

    if (variable_global_exists("editor_time") && variable_global_exists("CHART_LEN_S") && is_real(global.CHART_LEN_S)) {
        global.editor_time = clamp(global.editor_time, 0, max(0, global.CHART_LEN_S));
    }

    global.editor_chart_level_index = level_index;
    global.editor_chart_diff = diff;
    global.editor_chart_is_boss = _is_boss;
    global.editor_chart_filename = scr_chart_filename(level_index, diff, _is_boss);
    global.editor_chart_fullpath = path;
    global.editor_chart_path = path;

    global.editor_active_chart_label = global.editor_chart_filename;

    if (!_is_boss)
    {
        global.DIFFICULTY = diff;
        global.difficulty = diff;
        global.editor_chart_diff = diff;

        if (script_exists(scr_editor_preview_music_set)) {
            scr_editor_preview_music_set(level_index, diff);
        }

        show_debug_message("[EDITOR AUDIO] chart switch level=level" + (string(level_index < 10 ? "0" + string(level_index) : string(level_index)))
            + " diff=" + diff + " path=" + path);
    }

    global.editor_level_index = level_index;
    if (variable_global_exists("LEVEL_KEY")) {
        global.LEVEL_KEY = "level0" + string(level_index);
    }

    show_debug_message("[editor chart switch] " + path);
    return true;
}

/// scr_chart_save_and_reload(path_or_filename)
function scr_chart_save_and_reload(fname)
{
    if (is_undefined(fname) || string(fname) == "") return;

    var raw = string(fname);
    var path = raw;
    if (string_pos("/", raw) == 0 && string_pos("\\", raw) == 0) {
        path = scr_chart_fullpath(raw);
    }

    if (string_pos("charts/", path) != 1) {
        path = "charts/" + path;
    }

    global.chart_file = path;
    if (script_exists(scr_chart_save)) scr_chart_save();
    if (script_exists(scr_chart_load)) scr_chart_load();
}

/// Back-compat: 1..6 => normal/boss quick-switch slots
function scr_editor_switch_chart_variant(_variant_index)
{
    var idx = floor(_variant_index);

    if (!variable_global_exists("editor_level_index")) global.editor_level_index = 1;
    global.editor_level_index = clamp(global.editor_level_index, 1, 6);

    var diff = "normal";
    var is_boss = false;

    if (idx == 1) { diff = "easy";   is_boss = false; }
    if (idx == 2) { diff = "normal"; is_boss = false; }
    if (idx == 3) { diff = "hard";   is_boss = false; }
    if (idx == 4) { diff = "easy";   is_boss = true; }
    if (idx == 5) { diff = "normal"; is_boss = true; }
    if (idx == 6) { diff = "hard";   is_boss = true; }

    var filename = scr_chart_filename(global.editor_level_index, diff, is_boss);
    var fullpath = scr_chart_fullpath(filename);

    return scr_editor_chart_switch(fullpath, global.editor_level_index, diff, is_boss);
}
