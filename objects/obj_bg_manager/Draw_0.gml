/// obj_bg_manager : Draw (PAINTED TO CHUNKS) — no inner function

var cam = view_camera[0];
if (cam == noone) exit;

if (!variable_global_exists("CHUNK_W_TILES")
 || !variable_global_exists("TILE_W")
 || !variable_global_exists("BUFFER_CHUNKS")) exit;

var chunk_tiles = max(0, global.CHUNK_W_TILES);
var tile_w      = max(0, global.TILE_W);
var buf_chunks  = max(0, global.BUFFER_CHUNKS);

var chunk_w_px = chunk_tiles * tile_w;
var strip_w_px = buf_chunks * chunk_w_px;
if (chunk_w_px <= 0 || strip_w_px <= 0 || buf_chunks <= 0) exit;

var cx  = camera_get_view_x(cam);
var cy  = camera_get_view_y(cam);
var vw  = camera_get_view_width(cam);
var vh  = camera_get_view_height(cam);

// Parallax scroll source
var x_abs = (variable_global_exists("WORLD_X_ABS")) ? global.WORLD_X_ABS : cx;
var par = (variable_instance_exists(id, "parallax") && is_real(parallax)) ? parallax : 1.0;

// Camera position in BG-space (ring wrapped)
var cam_bg = (x_abs * par) mod strip_w_px;
if (cam_bg < 0) cam_bg += strip_w_px;

var d = "";
if (variable_global_exists("difficulty")) d = string(global.difficulty);
else if (variable_global_exists("DIFFICULTY")) d = string(global.DIFFICULTY);
d = string_lower(string_replace_all(d, " ", ""));

var use_pulse = (room == rm_level01) && (d == "hard");


var _old_col = draw_get_color();
var _old_alpha = draw_get_alpha();
draw_set_color(c_white);
draw_set_alpha(1.0);
var shader_is_on = false;

if (use_pulse)
{
    shader_set(shd_bpm_dual_pulse);
    shader_is_on = true;

    var t = (script_exists(scr_chart_time)) ? scr_chart_time() : 0.0;
    var spb = (variable_global_exists("SEC_PER_BEAT") && is_real(global.SEC_PER_BEAT) && global.SEC_PER_BEAT > 0)
        ? global.SEC_PER_BEAT
        : (60.0 / 165.0);

    var blue_col = $2FD9DF;
    var pink_col = $FF09E8;
    var blue_r = colour_get_red(blue_col) / 255.0;
    var blue_g = colour_get_green(blue_col) / 255.0;
    var blue_b = colour_get_blue(blue_col) / 255.0;
    var pink_r = colour_get_red(pink_col) / 255.0;
    var pink_g = colour_get_green(pink_col) / 255.0;
    var pink_b = colour_get_blue(pink_col) / 255.0;

    shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_time_s"), t);
    shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_spb"), spb);
    shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_tol"), 1.10);
    shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_str_blue"), 1.35);
    shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_str_pink"), 1.35);
    shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_decay"), 8.0);
    shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_enable_blue"), 1.0);
    shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_enable_pink"), 1.0);
    shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_blue_key"), blue_r, blue_g, blue_b);
    shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_pink_key"), pink_r, pink_g, pink_b);
}

// Draw each slot's painted sprite across its chunk width
for (var slot = 0; slot < buf_chunks; slot++)
{
    // Choose which painted array this manager uses
    // Near by default; set bg_profile="far" on the far instance
    var spr = -1;
    if (variable_instance_exists(id, "bg_profile") && bg_profile == "far")
        spr = global.bg_slot_far[slot];
    else
        spr = global.bg_slot_near[slot];

    if (spr == -1) spr = spr_bg_easy_00;

    // BG-space x for this slot
    var bgx = slot * chunk_w_px;

    // Convert BG-space X -> room-space X so the camera at cx sees the correct bg:
    // x_room = (bgx - cam_bg) + cx
    var x1 = (bgx - cam_bg) + cx;

    // Wrap coverage: draw 3 copies so edges never pop
    for (var k = -1; k <= 1; k++)
    {
        var xw = x1 + k * strip_w_px;

        // Quick cull
        if (xw > cx + vw + chunk_w_px) continue;
        if (xw < cx - chunk_w_px) continue;

        draw_sprite_stretched(spr, 0, xw, cy, chunk_w_px, vh);
    }
}

if (shader_is_on) shader_reset();

draw_set_color(_old_col);
draw_set_alpha(_old_alpha);
