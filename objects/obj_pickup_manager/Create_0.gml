/// obj_pickup_manager : Create

pickup_margin_px = 96;

pickup_spawns = [];
next_pickup_i = 0;

// Build from editor markers (type="pickup")
if (script_exists(scr_pickup_spawns_from_markers))
    pickup_spawns = scr_pickup_spawns_from_markers();
else
    pickup_spawns = [];
