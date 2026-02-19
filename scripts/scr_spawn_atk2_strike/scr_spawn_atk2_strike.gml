/// scr_spawn_atk2_strike(_src, _dmg)
function scr_spawn_atk2_strike(_src, _dmg) {
    if (!instance_exists(_src)) exit;

    with (_src) {

        var px = x; // player world x (used to ignore targets behind)
        var py = y;

        var best = noone;
        var best_d2 = 1000000000;

        // --- scenekid ---
        var e = instance_nearest(px, py, obj_scenekid);
        if (e != noone) {
            // must match ATK2 requirement
            if (!variable_instance_exists(e, "req_act") || e.req_act == "atk2" || e.req_act == global.ACT_ATK2) {

                // ignore targets behind player
                if (e.x >= px - 32) {
                    var dx = e.x - px, dy = e.y - py;
                    var d2 = dx*dx + dy*dy;
                    if (d2 < best_d2) { best_d2 = d2; best = e; }
                }
            }
        }

        // --- poptart (only if it requires atk2, usually it won't) ---
        e = instance_nearest(px, py, obj_poptart);
        if (e != noone) {
            if (!variable_instance_exists(e, "req_act") || e.req_act == "atk2" || e.req_act == global.ACT_ATK2) {
                if (e.x >= px - 32) {
                    var dx2 = e.x - px, dy2 = e.y - py;
                    var d22 = dx2*dx2 + dy2*dy2;
                    if (d22 < best_d2) { best_d2 = d22; best = e; }
                }
            }
        }

        // --- boss (only if it requires atk2, usually it won't) ---
        e = instance_nearest(px, py, obj_boss_punky_level3);
        if (e != noone) {
            if (!variable_instance_exists(e, "req_act") || e.req_act == "atk2" || e.req_act == global.ACT_ATK2) {
                if (e.x >= px - 32) {
                    var dx3 = e.x - px, dy3 = e.y - py;
                    var d23 = dx3*dx3 + dy3*dy3;
                    if (d23 < best_d2) { best_d2 = d23; best = e; }
                }
            }
        }

        if (best == noone) exit;

        var s = instance_create_layer(best.x, best.y, "Instances", obj_lightning_strike);
        s.target_id = best;
        s.dmg = _dmg;
        s.top_y_offset = 220;
    }
}
