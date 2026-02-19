/// obj_chunk_manager : Clean Up
if (ds_exists(chunk_cache, ds_type_map)) ds_map_destroy(chunk_cache);
if (ds_exists(chunk_files, ds_type_map)) ds_map_destroy(chunk_files);
if (variable_instance_exists(id, "section_t0_map") && ds_exists(section_t0_map, ds_type_map)) ds_map_destroy(section_t0_map);
