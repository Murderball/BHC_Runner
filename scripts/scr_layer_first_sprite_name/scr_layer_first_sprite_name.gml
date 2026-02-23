function scr_layer_first_sprite_name(_layer_name)
{
    var lid = layer_get_id(_layer_name);
    if (lid == -1) return "";

    var elems = layer_get_all_elements(lid);
    if (!is_array(elems)) return "";

    for (var i = 0; i < array_length(elems); i++)
    {
        var el = elems[i];
        var spr = layer_sprite_get_sprite(el);
        if (spr != -1) return sprite_get_name(spr);
    }
    return "";
}
