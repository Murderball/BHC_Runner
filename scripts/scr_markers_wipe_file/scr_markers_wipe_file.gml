function scr_markers_wipe_file()
{
    // Overwrite story_markers.json with an empty marker list
    var f = file_text_open_write(global.markers_file);
    file_text_write_string(f, "{\"markers\":[]}");
    file_text_close(f);

    // Reload markers + rebuild events
    scr_markers_load();
    scr_story_events_from_markers();
}
