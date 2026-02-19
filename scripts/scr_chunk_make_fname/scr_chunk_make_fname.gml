function scr_chunk_make_fname(section_name, idx)
{
    var stem = scr_sec_to_stem(section_name);

    var kk = string(idx);
    if (idx < 10) kk = "0" + kk;

    var prefix = "chunk_rm_chunk_";
    if (variable_global_exists("CHUNK_FILE_PREFIX") && is_string(global.CHUNK_FILE_PREFIX)) {
        prefix = global.CHUNK_FILE_PREFIX;
    }

    return prefix + stem + "_" + kk + ".json";
}
