function scr_markers_wipe_file()
{
    // Overwrite the active level+difficulty marker save with an empty marker list
    var f = file_text_open_write(global.MARKERS_FILE);
    file_text_write_string(f, "[]");
    file_text_close(f);

    // Reload markers + rebuild events
    scr_markers_load();
    scr_story_events_from_markers();
}
