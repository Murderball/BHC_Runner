function scr_phrases_save() {
    scr_phrases_sort();

    var payload = { phrases: global.phrases };
    var json = json_stringify(payload);

    var f = file_text_open_write(global.phrases_file);
    file_text_write_string(f, json);
    file_text_close(f);
}
