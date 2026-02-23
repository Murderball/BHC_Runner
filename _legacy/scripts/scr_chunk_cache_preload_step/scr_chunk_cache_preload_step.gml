/// scr_chunk_cache_preload_step(_budget)
/// Incrementally preloads ALL chunk JSON referenced in chunk_files
/// Uses ds_map_find_first/next (compatible with all GM runtimes)

function scr_chunk_cache_preload_step(_budget)
{
    if (!variable_instance_exists(id, "chunk_preload_done")) chunk_preload_done = false;
    if (chunk_preload_done) return;

    if (!variable_instance_exists(id, "chunk_cache") || is_undefined(chunk_cache))
        chunk_cache = ds_map_create();

    if (!variable_instance_exists(id, "chunk_files") || is_undefined(chunk_files))
        return;

    // --------------------------------------------------
    // Build preload list ONCE
    // --------------------------------------------------
    if (!variable_instance_exists(id, "chunk_preload_list") || is_undefined(chunk_preload_list))
    {
        chunk_preload_list = [];
        chunk_preload_i = 0;

        var k = ds_map_find_first(chunk_files);
        while (k != undefined)
        {
            var f = chunk_files[? k];
            if (is_string(f) && f != "") {
                array_push(chunk_preload_list, f);
            }
            k = ds_map_find_next(chunk_files, k);
        }

        // Optional debug
        show_debug_message("[chunk] preload list built: " + string(array_length(chunk_preload_list)));
    }

    // --------------------------------------------------
    // Incremental load
    // --------------------------------------------------
    var budget = max(1, floor(_budget));
    var total  = array_length(chunk_preload_list);

    for (var n = 0; n < budget; n++)
    {
        if (chunk_preload_i >= total)
        {
            chunk_preload_done = true;
            show_debug_message("[chunk] preload DONE (" + string(total) + ")");
            return;
        }
		
        var fname = chunk_preload_list[chunk_preload_i++];
        if (ds_map_exists(chunk_cache, fname)) continue;

        var data = scr_chunk_load(fname);
        if (!is_undefined(data)) {
            chunk_cache[? fname] = data;
		chunk_preload_done = true;
		global.CHUNKS_PRELOADED = true;
		show_debug_message("[chunk] preload DONE (" + string(total) + ")");
		return;
        }
    }
}