/// scr_chunk_load(fname)
/// Loads chunk JSON safely.
/// Search order:
/// 1) working_directory/chunks/<fname>  (batch/manual exports)
/// 2) <fname>                           (legacy)
/// 3) working_directory/datafiles/<fname> (Included Files)
///
/// Returns struct or undefined. Never crashes.

function scr_chunk_load(fname)
{
    var __mp_total = (script_exists(scr_microprof_begin) ? scr_microprof_begin("chunk.load.total") : 0);
    if (!is_string(fname) || string_length(fname) <= 0) {
       // show_debug_message("[scr_chunk_load] BAD fname");//
        if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.load.total", __mp_total);
        return undefined;
    }

    // Candidate paths (MUST be defined before use)
    var p_work = working_directory + "chunks/" + fname;
    var p_run  = fname;
    var p_data = working_directory + "datafiles/" + fname;

    var path = "";
    if (file_exists(p_work)) path = p_work;
    else if (file_exists(p_run)) path = p_run;
    else if (file_exists(p_data)) path = p_data;

    if (path == "") {
      //  show_debug_message("[scr_chunk_load] MISSING file: " + fname);//
        if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.load.total", __mp_total);
        return undefined;
    }

   // show_debug_message("[scr_chunk_load] open_read: " + path);//

    var f = file_text_open_read(path);
    if (f < 0) {
      //  show_debug_message("[scr_chunk_load] FAILED open_read: " + path);//
        if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.load.total", __mp_total);
        return undefined;
    }

    var json = "";
    while (!file_text_eof(f)) {
        json += file_text_read_string(f);
        file_text_readln(f);
    }
    file_text_close(f);

    if (string_length(json) <= 0) {
      //  show_debug_message("[scr_chunk_load] EMPTY file: " + path);//
        if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.load.total", __mp_total);
        return undefined;
    }

    var __mp_parse = (script_exists(scr_microprof_begin) ? scr_microprof_begin("chunk.load.json_parse") : 0);
    var data = json_parse(json);
    if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.load.json_parse", __mp_parse);
    if (is_undefined(data) || !is_struct(data)) {
    //    show_debug_message("[scr_chunk_load] JSON PARSE FAIL: " + path);//
        if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.load.total", __mp_total);
        return undefined;
    }

    // Backward compat: legacy "vis" -> all 3
    if (variable_struct_exists(data, "vis") &&
        !variable_struct_exists(data, "vis_easy") &&
        !variable_struct_exists(data, "vis_normal") &&
        !variable_struct_exists(data, "vis_hard"))
    {
        data.vis_easy = data.vis;
        data.vis_normal = data.vis;
        data.vis_hard = data.vis;
    }

    if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.load.total", __mp_total);
    return data;
}