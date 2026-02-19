function scr_chart_save() {
    scr_chart_sort();

    var payload = { notes: global.chart, bpm: global.BPM, offset: global.OFFSET };
    var json = json_stringify(payload);

    var f = file_text_open_write(global.chart_file);
    file_text_write_string(f, json);
    file_text_close(f);
	if (variable_global_exists("markers_file")) scr_markers_save();

}
