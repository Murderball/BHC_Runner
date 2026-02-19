function scr_bg_repaint_all_slots()
{
    if (!variable_global_exists("bg_slot_near")) return;
    if (!variable_global_exists("bg_slot_far"))  return;
    if (!variable_global_exists("BUFFER_CHUNKS")) return;

    // Need chunk manager instance vars
    if (!instance_exists(obj_chunk_manager)) return;

    with (obj_chunk_manager)
    {
        // Prefer repainting by integer CI (most robust).
        // Fall back to slot_room_name only if ci isn't available.
        var n = global.BUFFER_CHUNKS;

        // If these arrays don't exist yet, nothing to repaint.
        if (!is_array(slot_ci)) return;

        for (var s = 0; s < n; s++)
        {
            var ci = slot_ci[s];

            if (is_real(ci) && ci >= 0)
            {
                // Paint by CI (time-aligned, always works)
                scr_bg_paint_slot(s, ci);
            }
            else
            {
                // Fallback: if room-name string exists, paint from that
                if (is_array(slot_room_name))
                {
                    var nm = slot_room_name[s];
                    if (is_string(nm) && nm != "")
                        scr_bg_paint_slot(s, nm);
                }
            }
        }
    }
}
