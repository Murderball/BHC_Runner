function scr_datafile_read_all_text(fname) {
    // Reads an Included File (datafile) into a string.
    // fname is like "chunk_rm_chunk_intro.json"

    if (!file_exists(fname)) return "";

    var buf = buffer_load(fname);
    if (buf < 0) return "";

    var len = buffer_get_size(buf);
    var str = buffer_read(buf, buffer_string);

    buffer_delete(buf);
    return str;
}
