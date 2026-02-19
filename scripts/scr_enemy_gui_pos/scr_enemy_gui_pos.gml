/// scr_enemy_gui_pos(eid)
/// Returns struct {x,y} in GUI space (lane-free).
function scr_enemy_gui_pos(eid)
{
    var out = { x: 0, y: 0 };
    if (!instance_exists(eid)) return out;

    // Must have a valid timeline time
    if (!variable_instance_exists(eid, "t_anchor")) {
        out.x = display_get_gui_width() + 9999;
    } else if (!is_real(eid.t_anchor)) {
        out.x = display_get_gui_width() + 9999;
    } else {
        out.x = scr_note_screen_x(eid.t_anchor);
    }

    // Y is stored per-enemy (lane-free)
    if (variable_instance_exists(eid, "y_gui") && is_real(eid.y_gui)) out.y = eid.y_gui;
    else out.y = display_get_gui_height() * 0.5;

    return out;
}
