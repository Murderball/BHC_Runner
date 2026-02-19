/// scr_chunk_load_queue_step(chunk_cache)
/// Loads a small number of queued chunk files per frame and stores in chunk_cache.

function scr_chunk_load_queue_step(_chunk_cache)
{
    if (is_undefined(_chunk_cache) || !ds_exists(_chunk_cache, ds_type_map)) return;

    if (!variable_global_exists("chunk_load_queue") || !is_array(global.chunk_load_queue)) {
        global.chunk_load_queue = [];
        global.chunk_load_queue_head = 0;
    }

    if (!variable_global_exists("chunk_load_pending") || !ds_exists(global.chunk_load_pending, ds_type_map))
        global.chunk_load_pending = ds_map_create();

    if (!variable_global_exists("chunk_load_queue_head") || !is_real(global.chunk_load_queue_head))
        global.chunk_load_queue_head = 0;

    var budget = 1;
    if (variable_global_exists("chunk_load_budget")) budget = max(1, floor(global.chunk_load_budget));

    var __mp = (script_exists(scr_microprof_begin) ? scr_microprof_begin("chunk.load_queue.body") : 0);

    while (budget > 0 && global.chunk_load_queue_head < array_length(global.chunk_load_queue))
    {
        var fname = global.chunk_load_queue[global.chunk_load_queue_head];
        global.chunk_load_queue_head += 1;

        if (ds_map_exists(global.chunk_load_pending, fname))
            ds_map_delete(global.chunk_load_pending, fname);

        // already loaded?
        if (ds_map_exists(_chunk_cache, fname)) { budget--; continue; }

        var __mp_load = (script_exists(scr_microprof_begin) ? scr_microprof_begin("chunk.load_file") : 0);
        var data = scr_chunk_load(fname);
        if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.load_file", __mp_load);

        if (!is_undefined(data))
        {
            ds_map_add(_chunk_cache, fname, data);
        }
        else
        {
            show_debug_message("[chunk] load FAIL (not cached): " + string(fname));
        }

        budget--;
    }

    // Compact queue occasionally so head growth never causes O(n) spikes from array_delete(0).
    if (global.chunk_load_queue_head > 64 && global.chunk_load_queue_head * 2 >= array_length(global.chunk_load_queue)) {
        var remain = array_length(global.chunk_load_queue) - global.chunk_load_queue_head;
        if (remain > 0) {
            var compact = array_create(remain);
            for (var qi = 0; qi < remain; qi++) compact[qi] = global.chunk_load_queue[global.chunk_load_queue_head + qi];
            global.chunk_load_queue = compact;
        } else {
            global.chunk_load_queue = [];
        }
        global.chunk_load_queue_head = 0;
    }

    if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.load_queue.body", __mp);
}
