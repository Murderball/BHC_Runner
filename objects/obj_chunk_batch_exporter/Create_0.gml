/// obj_chunk_batch_exporter : Create
persistent = true;

// File containing room names (Included File)
rooms_file = "rooms_export.txt";     // recommended clean list
// rooms_file = "Time Master.txt";  // optional alternative

// Track export
export_rooms = scr_batch_export_load_rooms_from_file(rooms_file);

idx = -1;
phase = 0;

// wait / timeouts
wait_frames = 0;
timeout_frames = 0;

// room transition tracking
target_room = -1;

// where to go when done
return_room = rm_level03; // change if you want

// log output dir so you can confirm it in console
var dir = scr_chunks_dir();
show_debug_message("[Batch Export] chunks dir: " + dir);

// if rooms list failed, don't pretend it worked
if (array_length(export_rooms) <= 0)
{
    show_debug_message("[Batch Export] ERROR: No rooms loaded. Check rooms_export.txt (Included Files) + room names.");
}
