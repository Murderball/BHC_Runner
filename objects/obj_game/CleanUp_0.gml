// obj_game : Clean Up (or Game End)
if (variable_global_exists("CHUNK_CACHE")) {
    if (ds_exists(global.CHUNK_CACHE, ds_type_map)) ds_map_destroy(global.CHUNK_CACHE);
}