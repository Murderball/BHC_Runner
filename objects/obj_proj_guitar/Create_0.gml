/// obj_proj_guitar : Create

// ----------------------------------------------------
// Default spawn: player's on-screen (GUI) position
// (If spawner overrides gui_x/gui_y, those win anyway.)
// ----------------------------------------------------
gui_x = 448;
gui_y = 400;

if (instance_exists(obj_player_guitar))
{
    var cam = view_camera[0];
    var cam_x = camera_get_view_x(cam);
    var cam_y = camera_get_view_y(cam);

    var zoom = 1.0;
    if (instance_exists(obj_camera) && variable_instance_exists(obj_camera, "cam_zoom")) {
        zoom = obj_camera.cam_zoom;
    }

    gui_x = (obj_player_guitar.x - cam_x) * zoom + (24 * zoom);
    gui_y = (obj_player_guitar.y - cam_y) * zoom + (-8 * zoom);
}

// Motion
gui_vx = 900;    // pixels/sec
gui_vy = 0;

// Combat
damage = 2;
hit_radius = 24;     // projectile hit bubble in pixels (GUI)
pierce = false;
hit_x = 448;         // cached GUI hitline X used from enemy scope in Step

// Lifetime
life = 0;
life_max = 1.5;

// Lightning look
len = 64;
dir = 0;        // updated by spawner when it sets velocity
jag = 8;
segs = 4;

// Homing
target = noone;
homing = true;
turn_speed = 18;
speed_gui = 900;
