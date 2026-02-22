function scr_countdown_begin(_reason)
{
    var _spb = scr_seconds_per_beat();
    global.COUNTDOWN_ACTIVE = true;
    global.COUNTDOWN_REASON = is_undefined(_reason) ? "" : string(_reason);
    global.COUNTDOWN_TIMER_S = 4 * _spb;
    global.COUNTDOWN_TOTAL_S = global.COUNTDOWN_TIMER_S;

    if (!instance_exists(obj_countdown_controller))
    {
        var _layer = "Instances";
        if (!layer_exists(_layer))
        {
            var _lid = layer_get_id_at_depth(0);
            if (_lid != -1) _layer = layer_get_name(_lid);
        }
        if (_layer != "" && layer_exists(_layer)) instance_create_layer(0, 0, _layer, obj_countdown_controller);
    }
}
