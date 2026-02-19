/// scr_attack_perform(act, judge, lane)
/// Central place to define what atk1/atk2/atk3 actually DO.

function scr_attack_perform(_act, _judge, _lane)
{
    // --- base damage per attack type ---
    var base_dmg = 1;

    switch (_act) {
        case global.ACT_ATK1: base_dmg = 1; break; // light
        case global.ACT_ATK2: base_dmg = 2; break; // medium
        case global.ACT_ATK3: base_dmg = 3; break; // heavy
        default: base_dmg = 1; break;
    }

    // --- judge multiplier ---
    var mult = 1.0;
    switch (_judge) {
        case "perfect": mult = 1.50; break;
        case "good":    mult = 1.00; break;
        case "bad":     mult = 0.50; break;
        default:        mult = 0.0;  break;
    }

    var dmg = floor(base_dmg * mult);
    if (dmg <= 0) return;

    // --- lane-locked damage ---
    scr_enemy_damage_lane(dmg, _lane);

    // --- OPTIONAL: player feedback hooks (safe even if you don’t draw them yet) ---
    // You can use these to drive animations later.
    if (instance_exists(obj_player)) {
        with (obj_player) {
            atk_flash_t = 0.10;    // seconds of “attack flash”
            last_atk_act = _act;   // remember which attack fired
        }
    }
}
