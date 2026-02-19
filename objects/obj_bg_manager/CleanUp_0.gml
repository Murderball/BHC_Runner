/// obj_bg_manager : Clean Up Event
if (!is_undefined(bg_map) && ds_exists(bg_map, ds_type_map)) ds_map_destroy(bg_map);