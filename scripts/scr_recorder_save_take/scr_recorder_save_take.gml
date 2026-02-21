function scr_recorder_save_take(take_events)
{
    var base_path = variable_global_exists("chart_file") ? string(global.chart_file) : "charts/recorder/take.json";
    var slash_i = string_last_pos("/", base_path);
    var base_dir = (slash_i > 0) ? string_copy(base_path, 1, slash_i - 1) : "charts";

    directory_create("charts");
    if (base_dir != "") {
        var parts = string_split(base_dir, "/");
        var run = "";
        for (var i = 0; i < array_length(parts); i++) {
            run = (run == "") ? parts[i] : (run + "/" + parts[i]);
            directory_create(run);
        }
    }

    var takes_dir = base_dir + "/takes";
    directory_create(takes_dir);

    var take_idx = variable_global_exists("recorder_take_index") ? floor(global.recorder_take_index) : 1;
    var fname = takes_dir + "/take_" + string(take_idx) + ".json";

    var payload = {
        take_index: take_idx,
        chart_file: base_path,
        bpm: (variable_global_exists("chart_bpm") ? global.chart_bpm : global.BPM),
        events: take_events
    };

    var fh = file_text_open_write(fname);
    if (fh < 0) return "";
    file_text_write_string(fh, json_stringify(payload));
    file_text_close(fh);

    return fname;
}
