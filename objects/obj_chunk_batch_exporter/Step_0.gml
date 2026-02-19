/// obj_chunk_batch_exporter : Step
///
/// FIX: waits for room switch AND tile layer existence before exporting

// If we have nothing to do, bail loudly
if (array_length(export_rooms) <= 0)
{
    show_debug_message("[Batch Export] ABORT: export_rooms empty. Nothing will be exported.");
    room_goto(return_room);
    instance_destroy();
    exit;
}

// finished?
if (idx >= array_length(export_rooms) - 1 && phase == 0)
{
    show_debug_message("[Batch Export] DONE. Returning...");
    room_goto(return_room);
    instance_destroy();
    exit;
}

// Helper: check if TL_Collide tilemap exists in this room
function _collide_tilemap_ready()
{
    var lid = layer_get_id("TL_Collide");
    if (lid == -1) return false;
    var tm  = layer_tilemap_get_id(lid);
    return (tm != -1);
}

// phase 0: go next room
if (phase == 0)
{
    idx += 1;

    target_room = export_rooms[idx];
    show_debug_message("[Batch Export] goto " + room_get_name(target_room));

    room_goto(target_room);

    // phase 1: wait until we are actually IN that room
    phase = 1;
    wait_frames = 0;
    timeout_frames = 120; // 2 seconds @ 60fps to switch rooms
    exit;
}

// phase 1: wait until room switch completes
if (phase == 1)
{
    // room changes at end of step, so wait until it becomes active
    if (room == target_room)
    {
        // now wait until tilemaps exist
        phase = 2;
        timeout_frames = 180; // give tile layers time to exist
        exit;
    }

    timeout_frames -= 1;
    if (timeout_frames <= 0)
    {
        show_debug_message("[Batch Export] ERROR: room switch timed out for " + room_get_name(target_room));
        // move on rather than deadlocking
        phase = 0;
    }
    exit;
}

// phase 2: wait for tilemaps to exist then export
if (phase == 2)
{
    if (_collide_tilemap_ready())
    {
        var ok = scr_chunk_export_current_room_to_json();
        if (!ok) show_debug_message("[Batch Export] WARNING: export failed for " + room_get_name(room));
        else     show_debug_message("[Batch Export] exported: " + room_get_name(room));

        phase = 0;
        exit;
    }

    timeout_frames -= 1;
    if (timeout_frames <= 0)
    {
        show_debug_message("[Batch Export] ERROR: TL_Collide tilemap never became ready in " + room_get_name(room));
        show_debug_message("[Batch Export] Skipping this room...");
        phase = 0;
        exit;
    }

    // keep waiting
    exit;
}
