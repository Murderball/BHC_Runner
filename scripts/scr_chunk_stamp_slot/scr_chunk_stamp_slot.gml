/// scr_chunk_stamp_slot(data, slot)
/// Stamps a chunk into all active tilemaps (Easy/Normal/Hard + Collide)

function scr_chunk_stamp_slot(data, slot)
{
    // We ONLY pass data + slot now.
    // scr_chunk_stamp_to_maps will resolve:
    // - global.tm_vis_easy
    // - global.tm_vis_normal
    // - global.tm_vis_hard
    // - global.tm_collide

    scr_chunk_stamp_to_maps(data, slot);
}