// Remove any visual-layer shader/script hooks so tiles are never post-processed.
var lids = [
    layer_get_id("TL_Visual_Hard"),
    layer_get_id("TL_Preview_Visual_Hard")
];

for (var i = 0; i < array_length(lids); i++) {
    var lid = lids[i];
    if (lid != -1) {
        layer_script_begin(lid, -1);
        layer_script_end(lid, -1);
        layer_shader(lid, -1);
    }
}
