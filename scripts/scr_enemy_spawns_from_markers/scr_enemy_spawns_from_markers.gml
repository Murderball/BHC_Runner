/// scr_enemy_spawns_from_markers()
/// Returns an array of {t,kind,y_gui,spawned:false} sorted by t
/// Lane-free: ignores lane; generates y_gui if missing.
function scr_enemy_spawns_from_markers()
{
    var out = [];

    if (!variable_global_exists("markers") || !is_array(global.markers)) return out;

    // Pattern controls (optional)
    var y_mode = "random";
    if (variable_global_exists("enemy_y_mode")) y_mode = global.enemy_y_mode;

    if (!variable_global_exists("enemy_spawn_seed")) global.enemy_spawn_seed = irandom(999999);

    var top = 140;
    var bot = display_get_gui_height() - 140;

    // local helper: generate y_gui
    function _gen_y_gui(i, t_s)
    {
        if (script_exists(scr_enemy_y_pattern))
            return clamp(scr_enemy_y_pattern(y_mode, i, t_s, global.enemy_spawn_seed), top, bot);

        return irandom_range(top, bot);
    }

    var spawn_i = 0;

    for (var i = 0; i < array_length(global.markers); i++)
    {
        var m = global.markers[i];
        if (!is_struct(m)) continue;

        if (!variable_struct_exists(m, "type") || m.type != "spawn") continue;
        if (!variable_struct_exists(m, "t") || !is_real(m.t)) continue;

        // Kind default
        var kind = "poptart";
        if (variable_struct_exists(m, "enemy_kind")) kind = string(m.enemy_kind);

        // normalize legacy values (poptarts/scenekid/etc)
        if (script_exists(scr_enemy_kind_normalize))
            kind = scr_enemy_kind_normalize(kind);

        // Y in GUI space:
        var yg;
        if (variable_struct_exists(m, "y_gui") && is_real(m.y_gui)) {
            yg = m.y_gui;
        } else {
            yg = _gen_y_gui(spawn_i, m.t);
        }

        yg = clamp(yg, top, bot);

        array_push(out, { t: m.t, kind: kind, y_gui: yg, spawned: false });
        spawn_i++;
    }

    // Sort by time
    var n = array_length(out);
    for (var a = 0; a < n - 1; a++)
    for (var b = a + 1; b < n; b++)
    {
        if (out[a].t > out[b].t) {
            var tmp = out[a];
            out[a] = out[b];
            out[b] = tmp;
        }
    }

    return out;
}
