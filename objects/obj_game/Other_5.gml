// Remove layer scripts so they don't leak
var lid = layer_get_id("TL_Visual_Hard");
if (lid != -1) {
    layer_script_begin(lid, -1);
    layer_script_end(lid, -1);
    layer_shader(lid, -1);
}