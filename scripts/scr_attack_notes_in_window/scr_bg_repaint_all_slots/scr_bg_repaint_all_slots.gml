function scr_bg_repaint_all_slots()
{
    if (!variable_global_exists("bg_slot_near")) return;
    if (!variable_global_exists("BUFFER_CHUNKS")) return;
    if (!variable_instance_exists(obj_chunk_manager, "slot_room_name")) return; // only if slot_room_name lives on the instance

    // If slot_room_name is an instance var on chunk manager:
    with (obj_chunk_manager)
    {
        for (var s = 0; s < global.BUFFER_CHUNKS; s++)
        {
            var nm = slot_room_name[s];
            if (nm != "") scr_bg_paint_slot(s, nm);
        }
    }
}