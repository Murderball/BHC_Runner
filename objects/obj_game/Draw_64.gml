/// obj_game : Draw GUI
// --------------------------------------------------
// MENU GUARD: never draw gameplay overlays in rm_menu
// --------------------------------------------------
if (room == rm_menu || (variable_global_exists("in_menu") && global.in_menu)) exit;

// --- Draw GUI stuff ONCE ---
scr_draw_gameplay_gui();

if (variable_global_exists("editor_on") && global.editor_on) {
    scr_editor_draw_gui();
}

scr_phrases_draw_gui();

// --- ALWAYS restore draw state so world sprites never inherit bad settings next frame ---
draw_set_alpha(1);
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);


// =====================================================
// DEBUG: Current Level Key + Section + Stem
// Left side, vertically centered
// =====================================================
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

var _x = 16;
var _y = gui_h * 0.5;

// Safe fetch LEVEL_KEY
var _level = "undefined";
if (variable_global_exists("LEVEL_KEY"))
    _level = string(global.LEVEL_KEY);

// Determine current section name (same logic as chunk manager)
var _sec = "none";

if (instance_exists(obj_chunk_manager))
{
    var cm = obj_chunk_manager;

    if (is_array(cm.chunk_sections))
    {
        var t = scr_chart_time();

        var arr = cm.chunk_sections;

        if (t < arr[0].t0)
        {
            _sec = arr[0].name;
        }
        else
        {
            for (var i = 0; i < array_length(arr); i++)
            {
                var s = arr[i];
                if (t >= s.t0 && t < s.t1)
                {
                    _sec = s.name;
                    break;
                }
            }
        }
    }
}

// Convert to stem using your script
var _stem = scr_sec_to_stem(_sec);

// Draw background panel
draw_set_alpha(0.5);
draw_set_color(c_black);
draw_rectangle(_x - 8, _y - 32, _x + 260, _y + 48, false);

draw_set_alpha(1);
draw_set_color(c_lime);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);

// Draw text
draw_text(_x, _y - 16, "LEVEL_KEY: " + _level);
draw_text(_x, _y + 0,  "SECTION: " + string(_sec));
draw_text(_x, _y + 16, "STEM: " + string(_stem));
