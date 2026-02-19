/// scr_markers_save()
function scr_markers_save()
{
    if (!variable_global_exists("markers") || !is_array(global.markers)) global.markers = [];

    var fname = global.MARKERS_FILE;

    // Convert to JSON text
    var json = json_stringify(global.markers);

    // Write into SAVE area (persistent)
    var f = file_text_open_write(fname);
    file_text_write_string(f, json);
    file_text_close(f);

    show_debug_message("MARKERS SAVE -> " + fname + " bytes=" + string(string_length(json)));
}