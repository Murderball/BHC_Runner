/// scr_score_award(reason, base_points, accuracy)
/// Awards score ONLY when a real hit is confirmed, or when autohit is enabled.
function scr_score_award(_reason, _base_points, _accuracy)
{
    var is_auto = (_reason == "AUTO");
    if (is_auto && !scr_autohit_enabled()) return 0;

    if (!variable_global_exists("score_state") || !is_struct(global.score_state)) {
        scr_score_init();
    }

    var pts = max(0, floor(_base_points * _accuracy));
    global.score_state.score_total += pts;

    show_debug_message("[SCORE] +" + string(pts) + " reason=" + string(_reason) + " auto=" + string(scr_autohit_enabled()));

    return pts;
}
