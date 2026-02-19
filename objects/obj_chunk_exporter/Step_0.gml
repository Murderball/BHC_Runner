/// obj_chunk_exporter : Step

if (!keyboard_check_pressed(export_key)) exit;

var ok = scr_chunk_export_current_room_to_json();

if (ok) {
    // scr_chunk_export_current_room_to_json writes chunk_<roomname>.json
    dbg_line1 = "CHUNK EXPORTER";
    dbg_line2 = "EXPORTED current room (E/N/H)";
    dbg_line3 = room_get_name(room);
    dbg_line4 = "OK";
} else {
    dbg_line1 = "CHUNK EXPORTER";
    dbg_line2 = "EXPORT FAILED";
    dbg_line3 = room_get_name(room);
    dbg_line4 = "Check layers exist";
}