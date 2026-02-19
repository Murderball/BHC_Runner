/// scr_chunk_load_queue_request(fname)
/// Enqueue a chunk file for incremental loading (deduped).

function scr_chunk_load_queue_request(_fname)
{
    if (is_undefined(_fname) || string_length(string(_fname)) <= 0) return;

    if (!variable_global_exists("chunk_load_queue") || !is_array(global.chunk_load_queue)) {
        global.chunk_load_queue = [];
        global.chunk_load_queue_head = 0;
    }

    if (!variable_global_exists("chunk_load_pending") || !ds_exists(global.chunk_load_pending, ds_type_map))
        global.chunk_load_pending = ds_map_create();

    if (ds_map_exists(global.chunk_load_pending, _fname)) return; // already queued

    ds_map_add(global.chunk_load_pending, _fname, true);
    array_push(global.chunk_load_queue, _fname);
}
