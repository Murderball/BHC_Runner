/// scr_load_text_file(fname) -> string
function scr_load_text_file(fname)
{
if (!file_exists(fname)) {
show_debug_message("scr_load_text_file: MISSING file: " + fname);
return "";
}


var buf = buffer_load(fname);
if (buf < 0) {
show_debug_message("scr_load_text_file: FAILED buffer_load: " + fname);
return "";
}


// IMPORTANT: read as TEXT (not buffer_string)
var txt = buffer_read(buf, buffer_text);


buffer_delete(buf);
return txt;
}