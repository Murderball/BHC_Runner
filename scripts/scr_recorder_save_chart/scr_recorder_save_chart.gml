function scr_recorder_save_chart(chart_struct)
{
    var path = variable_global_exists("chart_file") ? string(global.chart_file) : "";
    if (path == "") return false;

    var dir = "";
    var slash_i = string_last_pos("/", path);
    if (slash_i > 0) {
        dir = string_copy(path, 1, slash_i - 1);
    }

    if (string_pos("charts", path) == 1) directory_create("charts");
    if (dir != "")
    {
        var parts = string_split(dir, "/");
        var run = "";
        for (var i = 0; i < array_length(parts); i++) {
            run = (run == "") ? parts[i] : (run + "/" + parts[i]);
            directory_create(run);
        }
    }

    var json_txt = json_stringify(chart_struct);
    var fh = file_text_open_write(path);
    if (fh < 0) return false;

    file_text_write_string(fh, json_txt);
    file_text_close(fh);

    if (variable_struct_exists(chart_struct, "notes") && is_array(chart_struct.notes)) {
        global.chart = chart_struct.notes;
    } else if (variable_struct_exists(chart_struct, "chart") && is_array(chart_struct.chart)) {
        global.chart = chart_struct.chart;
    }

    if (script_exists(scr_chart_sort)) scr_chart_sort();
    return true;
}
