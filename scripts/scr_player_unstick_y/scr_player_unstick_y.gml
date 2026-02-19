/// scr_player_unstick_y(_inst)
function scr_player_unstick_y(_inst) {
    if (!instance_exists(_inst)) exit;

    with (_inst) {
        var safety = 32;
        while (safety > 0) {
            // Check 4 bbox corners (slightly inset)
            var inside =
                scr_solid_at(bbox_left + 1,  bbox_top + 1) ||
                scr_solid_at(bbox_right - 1, bbox_top + 1) ||
                scr_solid_at(bbox_left + 1,  bbox_bottom - 1) ||
                scr_solid_at(bbox_right - 1, bbox_bottom - 1);

            if (!inside) break;

            y -= 1;
            safety--;
        }
    }
}
