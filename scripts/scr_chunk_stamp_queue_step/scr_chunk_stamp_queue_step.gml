/// scr_chunk_stamp_queue_step()
/// Processes queued chunk stamping jobs incrementally to avoid start-of-level hitches.
/// Uses global.chunk_stamp_queue = [ job, job, ... ]
/// Each job = { chunk_data, slot, ci, row, rows_per_step }

function scr_chunk_stamp_queue_step()
{
    if (!variable_global_exists("chunk_stamp_queue") || !is_array(global.chunk_stamp_queue)) {
        global.chunk_stamp_queue = [];
        global.chunk_stamp_queue_head = 0;
    }

    if (!variable_global_exists("chunk_stamp_queue_head") || !is_real(global.chunk_stamp_queue_head))
        global.chunk_stamp_queue_head = 0;

    var budget = 24; // rows per frame total (tune)
    if (variable_global_exists("chunk_stamp_row_budget")) budget = max(1, floor(global.chunk_stamp_row_budget));

    var __mp = (script_exists(scr_microprof_begin) ? scr_microprof_begin("chunk.stamp_queue.body") : 0);

    while (budget > 0 && global.chunk_stamp_queue_head < array_length(global.chunk_stamp_queue))
    {
        var job = global.chunk_stamp_queue[global.chunk_stamp_queue_head];

        // safety
        if (!is_struct(job) || !variable_struct_exists(job, "slot"))
        {
            global.chunk_stamp_queue_head += 1;
            continue;
        }

        // drop outdated jobs (slot was reassigned)
        if (variable_struct_exists(job, "ci"))
        {
            var s = job.slot;
            if (is_array(slot_ci) && s >= 0 && s < array_length(slot_ci))
            {
                if (slot_ci[s] != job.ci)
                {
                    global.chunk_stamp_queue_head += 1;
                    continue;
                }
            }
        }

        var before = (variable_struct_exists(job, "row") ? job.row : 0);

        // clamp this job’s slice to remaining budget
        var rps = 8;
        if (variable_struct_exists(job, "rows_per_step")) rps = max(1, floor(job.rows_per_step));
        rps = min(rps, budget);
        job.rows_per_step = rps;

        var __mp_job = (script_exists(scr_microprof_begin) ? scr_microprof_begin("chunk.stamp_job") : 0);
        var done = scr_chunk_stamp_slot_step(job);
        if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.stamp_job", __mp_job);

        var after = (variable_struct_exists(job, "row") ? job.row : before);
        budget -= max(0, after - before);

        if (done)
        {
            global.chunk_stamp_queue_head += 1;
        }
        else
        {
            // job mutated in-place; keep it at head
            global.chunk_stamp_queue[global.chunk_stamp_queue_head] = job;
        }
    }

    // Compact queue occasionally to keep array small.
    if (global.chunk_stamp_queue_head > 64 && global.chunk_stamp_queue_head * 2 >= array_length(global.chunk_stamp_queue)) {
        var remain = array_length(global.chunk_stamp_queue) - global.chunk_stamp_queue_head;
        if (remain > 0) {
            var compact = array_create(remain);
            for (var qi = 0; qi < remain; qi++) compact[qi] = global.chunk_stamp_queue[global.chunk_stamp_queue_head + qi];
            global.chunk_stamp_queue = compact;
        } else {
            global.chunk_stamp_queue = [];
        }
        global.chunk_stamp_queue_head = 0;
    }

    if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.stamp_queue.body", __mp);
}
