/// obj_chunk_manager : Draw GUI
/// Debug: chunk under mouse + chunk start/end time (top-right)

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

// Ensure chunk timing exists
if (!variable_global_exists("CHUNK_W_TILES")) scr_chunk_system_init();
if (!variable_global_exists("chunk_seconds")) scr_chunk_build_section_sequences();

var cam = view_camera[0];

// Mouse -> world (your project already uses this pattern in obj_tile_picker)
var mxw = camera_get_view_x(cam) + device_mouse_x_to_gui(0);
var myw = camera_get_view_y(cam) + device_mouse_y_to_gui(0);

// Chunk math
var chunk_w_px = global.CHUNK_W_TILES * global.TILE_W;
var pps = global.WORLD_PPS;
if (pps <= 0) pps = 1;

var ci = floor(mxw / chunk_w_px);
if (ci < 0) ci = 0;

// Convert mouse world-x into song/world time
var t = mxw / pps;

// Find section (name + t0/t1)
var sec_name = "intro";
var sec_t0 = 0.0;
var sec_t1 = 0.0;

if (variable_global_exists("level3_master_sections") && !is_undefined(global.level3_master_sections)) {
    var arr = global.level3_master_sections;
    if (array_length(arr) > 0) {
        sec_name = arr[0].name;
        sec_t0 = arr[0].t0;
        sec_t1 = arr[0].t1;

        for (var i = 0; i < array_length(arr); i++) {
            var s = arr[i];
            if (t >= s.t0 && t < s.t1) {
                sec_name = s.name;
                sec_t0 = s.t0;
                sec_t1 = s.t1;
                break;
            }
        }

        // If past the end, clamp to last
        if (t >= arr[array_length(arr) - 1].t1) {
            var sl = arr[array_length(arr) - 1];
            sec_name = sl.name;
            sec_t0 = sl.t0;
            sec_t1 = sl.t1;
        }
    }
}

// Chunk index within section
var k = floor((t - sec_t0) / global.chunk_seconds);
if (k < 0) k = 0;

// Build chunk key (stem + _NN)
var stem = scr_sec_to_stem(sec_name);
var kk = string(k);
if (k < 10) kk = "0" + kk;
var chunk_key = stem + "_" + kk;

// Start/end time for THIS chunk (clamped to section)
var t_start = sec_t0 + (k * global.chunk_seconds);
var t_end   = t_start + global.chunk_seconds;
if (t_end > sec_t1) t_end = sec_t1;

// Format strings
var line1 = "Mouse Chunk: ci=" + string(ci) + "  key=" + chunk_key + "  sec=" + sec_name;
var line2 = "Chunk time: " + string_format(t_start, 0, 3) + "  →  " + string_format(t_end, 0, 3);

// Layout (top-right)
draw_set_font(-1);
draw_set_halign(fa_right);
draw_set_valign(fa_top);

var pad = 8;
var lh = 18;

var w1 = string_width(line1);
var w2 = string_width(line2);
var box_w = max(w1, w2) + pad * 2;
var box_h = (lh * 2) + pad * 2;

var x2 = gui_w - 10;
var x1 = x2 - box_w;
var y1 = 10;
var y2 = y1 + box_h;

// Background (black, semi-transparent)
draw_set_alpha(0.55);
draw_set_color(c_black);
draw_rectangle(x1, y1, x2, y2, false);

// Text (red)
draw_set_alpha(1);
draw_set_color(c_red);
draw_text(x2 - pad, y1 + pad, line1);
draw_text(x2 - pad, y1 + pad + lh, line2);

// Restore defaults
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);


if (script_exists(scr_microprof_draw_overlay)) {
    scr_microprof_draw_overlay(12, 12, 5);
}
