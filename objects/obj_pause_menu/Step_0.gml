/// obj_pause_menu : Step

if (move_cd > 0) move_cd--;

// Allow pause menu in both gameplay and editor

// inputs
var ok    = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
var back  = (variable_global_exists("in_pause") && global.in_pause) || keyboard_check_pressed(vk_escape);

var click = mouse_check_button_pressed(mb_left);

var up    = keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"));
var down  = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
var left  = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"));
var right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));

// --------------------------------------------------
// Keyboard usage detection (drives dashed outline)
// --------------------------------------------------
var held_dir =
    keyboard_check(vk_up)   || keyboard_check(ord("W")) ||
    keyboard_check(vk_down) || keyboard_check(ord("S")) ||
    keyboard_check(vk_left) || keyboard_check(ord("A")) ||
    keyboard_check(vk_right) || keyboard_check(ord("D"));

var used_kb = held_dir || ok || back;

if (used_kb) kb_nav_timer = 90;
if (kb_nav_timer > 0) kb_nav_timer--;

kb_dash_phase = (kb_dash_phase + 1) & 15;


// Editor-pause is a separate mode; do not stack pause menu on top of it.
if (variable_global_exists("EDITOR_PAUSE_OPEN") && global.EDITOR_PAUSE_OPEN) {
    paused = false;
    exit;
}

// Toggle pause with ESC
if (back && move_cd <= 0 && !menu_game_open)
{
    if (!paused)
    {
        global.pause_song_time = scr_song_time();

        paused = true;
        global.GAME_PAUSED = true;

        global.pause_song_was_playing = false;
        if (variable_global_exists("song_handle") && global.song_handle >= 0) {
            global.pause_song_was_playing = audio_is_playing(global.song_handle);
            audio_pause_sound(global.song_handle);
        }

        if (variable_global_exists("story_npc_handle") && global.story_npc_handle >= 0) {
            audio_pause_sound(global.story_npc_handle);
        }

        sel = 0;
        move_cd = 8;
    }
    else
    {
        paused = false;
        global.GAME_PAUSED = false;

        if (!(variable_global_exists("editor_on") && global.editor_on) &&
            variable_global_exists("pause_song_was_playing") && global.pause_song_was_playing) {
            if (variable_global_exists("song_handle") && global.song_handle >= 0) {
                audio_resume_sound(global.song_handle);
            }
        }

        if (variable_global_exists("story_npc_handle") && global.story_npc_handle >= 0) {
            audio_resume_sound(global.story_npc_handle);
        }

        global.pause_song_time = 0.0;
        move_cd = 8;
    }
}

// Not paused? nothing else
if (!paused) exit;


// Shared Game submenu
if (menu_game_open)
{
    scr_menu_game_update(id, ok, back, left, right, up, down);
    move_cd = 6;
    exit;
}

// --------------------------------------------------
// Build button rects in GUI space (for hover/click)
// Layout uses sprite sizes (fallback to fixed if missing)
// --------------------------------------------------
var gw = display_get_gui_width();
var gh = display_get_gui_height();

var panel_w = 640;
var panel_h = 360;
var panel_x = gw * 0.5 - panel_w * 0.5;
var panel_y = gh * 0.5 - panel_h * 0.5;

// Vertical stack area inside panel
var start_y = panel_y + 85;
var gap_y   = 14;

btn = [];

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// Button X center
var cx = panel_x + panel_w * 0.5;

for (var i = 0; i < array_length(items); i++)
{
    var spr = spr_items[i];

    // Sprite size fallback if asset missing
    var sw = (spr >= 0) ? sprite_get_width(spr)  : 360;
    var sh = (spr >= 0) ? sprite_get_height(spr) : 64;

    sw *= spr_scale;
    sh *= spr_scale;

    // Rect centered on cx
    var x1 = cx - sw * 0.5;
    var y1 = start_y + i * (sh + gap_y);
    var x2 = x1 + sw;
    var y2 = y1 + sh;

    btn[i] = { x1:x1, y1:y1, x2:x2, y2:y2 };
}

// Hover detect
hover_i = -1;
for (var j = 0; j < array_length(btn); j++)
{
    var r = btn[j];
    if (mx >= r.x1 && mx <= r.x2 && my >= r.y1 && my <= r.y2) {
        hover_i = j;
        break;
    }
}

// Mouse hover selects ONLY when keyboard isn't active
if (kb_nav_timer <= 0 && hover_i >= 0) sel = hover_i;

// Glow lerp
for (var k = 0; k < array_length(glow); k++)
{
    var target = (k == hover_i) ? 1 : 0;
    glow[k] = lerp(glow[k], target, glow_speed);
}

// Keyboard navigation
if (move_cd <= 0)
{
    if (up)
    {
        sel = (sel - 1 + array_length(items)) mod array_length(items);
        move_cd = 6;
    }
    if (down)
    {
        sel = (sel + 1) mod array_length(items);
        move_cd = 6;
    }
}

var pause_options_active = (sel == 2) || (hover_i == 2) || options_slider_drag;
if (array_length(btn) > 2)
{
    var _opr = btn[2];
    ui_mouse_x = mx;
    ui_mouse_y = my;
    ui_input_left = left;
    ui_input_right = right;
    var _pause_panel = scr_ui_master_volume_panel_update(_opr.x1, _opr.y1, _opr.x2 - _opr.x1, _opr.y2 - _opr.y1, pause_options_active);

    if (_pause_panel.hit_track || _pause_panel.hit_knob)
    {
        sel = 2;
        if (mouse_check_button_pressed(mb_left)) menu_game_adjust = true;
    }
}

// Activate selection (mouse click or keyboard confirm)
var activate = ok || (click && hover_i == sel);

if (activate)
{
    switch (sel)
    {
        case 0: // RESUME
            paused = false;
            global.GAME_PAUSED = false;

            if (!(variable_global_exists("editor_on") && global.editor_on) &&
                variable_global_exists("pause_song_was_playing") && global.pause_song_was_playing) {
                if (variable_global_exists("song_handle") && global.song_handle >= 0) {
                    audio_resume_sound(global.song_handle);
                }
            }

            if (variable_global_exists("story_npc_handle") && global.story_npc_handle >= 0) {
                audio_resume_sound(global.story_npc_handle);
            }

            global.pause_song_time = 0.0;
        break;

        case 1: // RESTART LEVEL
            paused = false;
            global.GAME_PAUSED = false;
            global.pause_song_time = 0.0;

            // Let a script do the heavy lifting
            if (script_exists(scr_restart_level)) {
                scr_restart_level();
            } else {
                // emergency fallback
                room_restart();
            }
        break;

        case 2: // GAME
            scr_menu_game_open(id);
        break;

        case 3: // TITLE MENU
            paused = false;
            scr_return_to_title();
        break;

        case 4: // EXIT GAME
            game_end();
        break;
    }

    move_cd = 8;
}
