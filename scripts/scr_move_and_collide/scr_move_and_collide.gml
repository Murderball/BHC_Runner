function scr_move_and_collide(hsp, vsp) {

    // -------------------------
    // Horizontal move (pixel stepping)
    // -------------------------
    var step_h = sign(hsp);
    var amt_h  = abs(hsp);

    while (amt_h > 0) {
        if (!scr_solid_at(bbox_left  + step_h, bbox_top + 1) &&
            !scr_solid_at(bbox_left  + step_h, bbox_bottom - 1) &&
            !scr_solid_at(bbox_right + step_h, bbox_top + 1) &&
            !scr_solid_at(bbox_right + step_h, bbox_bottom - 1)) {
            x += step_h;
            amt_h -= 1;
        } else {
            hsp = 0;
            break;
        }
    }

    // -------------------------
    // Vertical move (pixel stepping)
    // Only test leading edge: top when going up, bottom when going down
    // -------------------------
    var step_v = sign(vsp);
    var amt_v  = abs(vsp);

    while (amt_v > 0) {

        if (step_v > 0) {
            // Moving DOWN: test bottom edge only
            if (!scr_solid_at(bbox_left + 1,  bbox_bottom + step_v) &&
                !scr_solid_at(bbox_right - 1, bbox_bottom + step_v)) {
                y += step_v;
                amt_v -= 1;
            } else {
                grounded = true;
                vsp = 0;
                break;
            }

        } else if (step_v < 0) {
            // Moving UP: test top edge only
            if (!scr_solid_at(bbox_left + 1,  bbox_top + step_v) &&
                !scr_solid_at(bbox_right - 1, bbox_top + step_v)) {
                y += step_v;
                amt_v -= 1;
            } else {
                vsp = 0;
                break;
            }

        } else {
            break; // no vertical movement
        }
    }

    return [hsp, vsp];
}
