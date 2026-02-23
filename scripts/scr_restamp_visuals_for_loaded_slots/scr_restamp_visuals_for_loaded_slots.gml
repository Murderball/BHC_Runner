/// scr_restamp_visuals_for_loaded_slots()
function scr_restamp_visuals_for_loaded_slots()
{
    if (!variable_global_exists("chunk_slot_data")) return;
    if (!variable_global_exists("tm_visual") || global.tm_visual == -1) return;
    if (!variable_global_exists("tm_collide") || global.tm_collide == -1) return;

    var n = array_length(global.chunk_slot_data);
    for (var s = 0; s < n; s++)
    {
        var d = global.chunk_slot_data[s];
        if (!is_undefined(d) && is_struct(d)) {
            // Re-stamp. Collision will be identical; safe.
            scr_chunk_stamp_to_maps(d, s, global.tm_visual, global.tm_collide);
        }
    }
}