/// obj_loading_controller : Step

var now = current_time;
var dt  = now - last_ms;
if (dt < 0) dt = 0;
if (dt > 200) dt = 200; // clamp
last_ms = now;

// fade + zoom timers
fade_accum_ms = min(fade_in_ms, fade_accum_ms + dt);
zoom_accum_ms = min(zoom_ms,    zoom_accum_ms + dt);

// loading delay
load_timer_ms -= dt;

if (load_timer_ms <= 0)
{
    var go = global.next_room;

    global.next_room = rm_menu;
    global.in_loading = false;

    room_goto(go);
}
