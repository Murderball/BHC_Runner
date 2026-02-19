/// scr_attack_apply_damage(attacker, atk_id, judge)
/// Nearest-enemy targeting (no lane locks, no hitline window).
function scr_attack_apply_damage(attacker, atk_id, judge)
{
    if (judge == "miss") return false;

    // Damage by judge
    var dmg = 1;
    if (judge == "perfect") dmg = 3;
    else if (judge == "good") dmg = 2;
    else if (judge == "bad") dmg = 1;

    // Optional per-attack scaling
    // if (atk_id == "atk2") dmg += 1;
    // if (atk_id == "atk3") dmg += 2;

    // Attack origin in GUI-space:
    // Your project uses hitline X=448. Y can be “center-ish”.
    var ox = 448;
    var oy = 400;

    // Find nearest enemy in GUI space
    var target = scr_find_nearest_enemy_gui(ox, oy, 2500);
    if (!instance_exists(target)) return false;
    if (!variable_instance_exists(target, "hp")) return false;

    target.hp -= dmg;
    if (target.hp < 0) target.hp = 0;

    if (target.hp <= 0)
    {
        target.dead = true;
        instance_destroy(target);
    }

    return true;
}
