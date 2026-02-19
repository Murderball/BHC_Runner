/// scr_player_ultimate_guitar(player_id_or_object, judge)
/// Fires a burst of homing bolts at nearby enemies using obj_proj_guitar.
function scr_player_ultimate_guitar(_pl, _judge)
{
    // Accept either an instance id OR an object asset index (obj_player_guitar, etc.)
    // - instance id: instance_exists(_pl) will be true
    // - object index: asset_get_type(_pl) == asset_object, then use instance_find()
    if (is_real(_pl))
    {
        // If it's an object asset index, convert to first instance
        if (asset_get_type(_pl) == asset_object)
        {
            _pl = instance_find(_pl, 0);
        }
    }

    if (!instance_exists(_pl)) return;

    // Must have projectile object
    if (!object_exists(obj_proj_guitar)) return;

    // Normalize judge to a lowercase string so comparisons always work
    var j = is_string(_judge) ? string_lower(_judge) : string_lower(string(_judge));

    // Scale burst based on note judgement
    var shots = 6;
    var dmg   = 4;
    if (j == "perfect") { shots = 10; dmg = 7; }
    else if (j == "good") { shots = 8; dmg = 6; }

    // Camera + GUI conversion (match your ATK blocks infrastructure)
    var cam = view_camera[0];

    // If no camera for some reason, bail safely
    if (cam == noone) return;

    var cam_x = camera_get_view_x(cam);
    var cam_y = camera_get_view_y(cam);

    // IMPORTANT: match ATK blocks (view_w / gui_w), NOT obj_camera.cam_zoom
    var gui_w = display_get_gui_width();
    if (gui_w <= 0) return;

    var zoom = camera_get_view_width(cam) / gui_w;

    // Fire point in ROOM space, anchored to bbox (origin-safe)
    var fire_x_room = _pl.bbox_left + 24;
    var fire_y_room = _pl.bbox_top  + 75;

    // Convert to GUI space
    var ox = (fire_x_room - cam_x) * zoom;
    var oy = (fire_y_room - cam_y) * zoom;

    for (var i = 0; i < shots; i++)
    {
        var tgt = noone;
        if (script_exists(scr_find_nearest_enemy_gui))
            tgt = scr_find_nearest_enemy_gui(ox, oy, 2500);

        var dir = irandom_range(-15, 15); // fallback spread

        if (instance_exists(tgt) && script_exists(scr_enemy_gui_pos))
        {
            var tp = scr_enemy_gui_pos(tgt);
            // tp is expected to be a struct with .x/.y in GUI space
            if (is_struct(tp) && variable_struct_exists(tp, "x") && variable_struct_exists(tp, "y"))
                dir = point_direction(ox, oy, tp.x, tp.y) + irandom_range(-10, 10);
        }

        // Spawn in ROOM at the fire point (same as your ATK fixes)
        var p = instance_create_layer(fire_x_room, fire_y_room, "Instances", obj_proj_guitar);
        if (!instance_exists(p)) continue;

        // Projectile uses GUI space for movement/draw
        p.gui_x = ox;
        p.gui_y = oy;

        p.target = tgt;
        p.homing = instance_exists(tgt);

        var spd = 1200;
        p.speed_gui = spd;
        p.gui_vx = lengthdir_x(spd, dir);
        p.gui_vy = lengthdir_y(spd, dir);
        p.dir = dir;

        p.damage     = dmg;
        p.life_max   = 1.4;
        p.pierce     = true;
        p.hit_radius = 26;
    }
}
