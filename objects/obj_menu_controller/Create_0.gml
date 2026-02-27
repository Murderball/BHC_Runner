/// obj_menu_controller : Create

if (!variable_global_exists("game_mode")) global.game_mode = "arcade";

global.in_menu = true;
if (script_exists(scr_profiles_boot)) scr_profiles_boot();
global.in_loading = false;
global.GAME_PAUSED = false;
global.editor_on = false;

cam = view_camera[0];

// Menu music handle
if (!variable_global_exists("menu_music_handle")) global.menu_music_handle = -1;
if (global.menu_music_handle < 0) {
    global.menu_music_handle = audio_play_sound(snd_title_track, 1, true);
}

// ----------------------------------
// Keyboard-selection dashed outline
// ----------------------------------
kb_nav_timer = 0;
kb_dash_phase = 0;

cs_focus_back = false;
cs_focus_upgrade = false;
cs_focus_play = false;

diff_focus_back = false;

// View size (viewport 0)
view_w = display_get_gui_width();
view_h = display_get_gui_height();

// Menu world is a fixed 3840x1080 (two 1920px pages side-by-side).
MENU_WORLD_WIDTH = 3840;
MENU_WORLD_HEIGHT = 1080;
MENU_PAGE_WIDTH = 1920;
MENU_PAGE_1_X = 0;
MENU_PAGE_2_X = 1920;

// Note: we keep runtime camera math at 3840x1080 even if room size is authored differently.
// Camera bounds for menu world math (do not zoom/scale UI; we only offset by camera X).
min_cam_x = MENU_PAGE_1_X;
max_cam_x = MENU_PAGE_2_X;
min_cam_y = 0;
max_cam_y = max(0, MENU_WORLD_HEIGHT - view_h);

// Legacy aliases used by menu camera/page math.
page_left_x = MENU_PAGE_1_X;
page_right_x = MENU_PAGE_2_X;

// Camera motion
menu_cam_x = MENU_PAGE_1_X;
menu_cam_target_x = MENU_PAGE_1_X;
menu_cam_speed = 0.15;
menu_cam_y = 0;

// Legacy compatibility mirrors
cam_x = menu_cam_x;
cam_target_x = menu_cam_target_x;
cam_y = menu_cam_y;
scroll_lerp = menu_cam_speed;
global.menu_page_x = menu_cam_x;
menu_page_x = menu_cam_x;
menu_page_target_x = menu_cam_target_x;

// States: 0=left menu, 1=scrolling, 2=right page (LEVEL SELECT -> CHARACTER SELECT)
MENU_STATE_INIT = 0;
MENU_STATE_SCROLLING = 1;
MENU_STATE_PAGE2 = 2;
MENU_STATE_STORY_SUBMENU = 10;
MENU_STATE_NEW_GAME_PANEL = 11;
MENU_STATE_LOAD_GAME_PANEL = 12;
MENU_STATE_ARCADE_PANEL = 13;
MENU_STATE_OPTIONS_VOLUME_PANEL = 14;

menu_state = MENU_STATE_INIT;
right_target_state = 2;

// Button size
BTN_W = 256;
BTN_H = 91;

// Start submenu open/closed
start_open = false;
story_submenu_open = false;

// Options submenu open/closed
options_open = false;
menu_game_open = false;
menu_game_sel = 0;
menu_game_adjust = false;
menu_game_step = 0.05;
menu_game_slider_active = false;
menu_game_anchor_x = 0;
menu_game_anchor_y = 0;
menu_game_anchor_w = 0;
menu_game_anchor_h = 0;

options_panel_pad = 18;
options_panel_w = 380;
options_panel_h = 160;
options_panel_gap = 20;
options_panel_align_y = -12;
options_slider_drag = false;
options_slider_step = 0.05;
options_panel_x = 0;
options_panel_y = 0;
options_slider_min_x = 0;
options_slider_max_x = 0;
options_slider_y = 0;

// Arcade difficulty submenu open (LEFT page)
arcade_diff_open = false;
new_game_panel_open = false;
load_game_panel_open = false;
load_slot_sel = 0;
options_volume_panel_open = false;
debug_menu_overlay = false;
hovered_button_id = "none";
menu_click_armed = "";
active_top_item = "none";

spr_menu_newgame = asset_get_index("menu_newgame");
spr_menu_loadgame = asset_get_index("menu_loadgame");
spr_menu_newgame_ui_box = asset_get_index("menu_newgame_ui_box");
spr_menu_story_ui_box = asset_get_index("menu_story_ui_box");
spr_menu_arcade_ui_box = asset_get_index("menu_arcade_ui_box");
spr_menu_volume = asset_get_index("menu_volume");
spr_menu_game = asset_get_index("menu_game");
spr_menu_level_select = asset_get_index("menu_level_select");
spr_menu_pointer = asset_get_index("menu_pointer");

if (spr_menu_newgame < 0) spr_menu_newgame = menu_start;
if (spr_menu_loadgame < 0) spr_menu_loadgame = menu_story;

// Selection indices
sel_main = 0;
sel_opt  = 0;

// ----------------------------
// Layout (WORLD positions) — PAGE 1 LEFT COLUMN (Mockup 1)
// ----------------------------

// Mockups are 2048x1152, game is 1920x1080 => uniform scale 0.9375
// These values are already "game space" (1920x1080) approximations.
var left_x = page_left_x + 80;

// Top-left aligned like the mockup text blocks
var y_story  = 155;
var y_arcade = 558;
var y_opts   = 759;
var y_exit   = 951;

// Main menu buttons (page 1)
btn_story   = { spr: menu_story,   x: left_x, y: y_story,  w: BTN_W, h: BTN_H };
btn_arcade  = { spr: menu_arcade,  x: left_x, y: y_arcade, w: BTN_W, h: BTN_H };
btn_options = { spr: menu_options, x: left_x, y: y_opts,   w: BTN_W, h: BTN_H };
btn_game    = { spr: spr_menu_game, x: 0, y: 0, w: BTN_W, h: BTN_H };
btn_exit    = { spr: menu_exit,    x: left_x, y: y_exit,   w: BTN_W, h: BTN_H };

// Story submenu (will tune later; placeholder positions near story)
btn_newgame  = { spr: spr_menu_newgame,  x: left_x, y: y_story + 120, w: BTN_W, h: BTN_H };
btn_loadgame = { spr: spr_menu_loadgame, x: left_x, y: y_story + 220, w: BTN_W, h: BTN_H };

// Page right button (keep for now; we’ll position later)
btn_page_right = { spr: menu_main, x: left_x + 620, y: y_exit + 40, w: BTN_W, h: BTN_H };

// If you still use btn_start anywhere, keep it defined but parked offscreen
btn_start = { spr: menu_start, x: -9999, y: -9999, w: BTN_W, h: BTN_H };

// Default: left menu is expanded on load
start_open = true;
// ----------------------------
// ARCADE DIFFICULTY (LEFT PAGE — shows BEFORE pan)
// ----------------------------
var diffL_x = left_x + 290-75;
var diffL_y_easy   = y_arcade + 10;
var diffL_y_normal = diffL_y_easy + 110;
var diffL_y_hard   = diffL_y_normal + 110;

btn_easyL   = { spr: menu_easy,   x: diffL_x, y: diffL_y_easy,   w: BTN_W, h: BTN_H };
btn_normalL = { spr: menu_normal, x: diffL_x, y: diffL_y_normal, w: BTN_W, h: BTN_H };
btn_hardL   = { spr: menu_hard,   x: diffL_x, y: diffL_y_hard,   w: BTN_W, h: BTN_H };

sel_diff = 1; // default highlight = normal

// ----------------------------
// Character select layout (WORLD)
// ----------------------------
var UI_SHIFT_LEFT = 360; // tweak if needed

// (your char buttons are hard-coded to match your art placement)
char_btn = [];
char_btn[0] = { spr: menu_vocalist,  x: 1500, y: 75,  w: 220, h: 78, id: 0 };
char_btn[1] = { spr: menu_guitarist, x: 1520, y: 250, w: 220, h: 78, id: 1 };
char_btn[2] = { spr: menu_bassist,   x: 1500, y: 450, w: 220, h: 78, id: 2 };
char_btn[3] = { spr: menu_drummer,   x: 1520, y: 650, w: 220, h: 78, id: 3 };

sel_char = 0;

// picked state reveals Upgrade + Lets Go
char_picked = false;
picked_char_id = 0;

// ----------------------------
// NEW: Level Select (RIGHT PAGE, LEFT of characters)
// ----------------------------

// Small button size for level select
LVL_W = 150;
LVL_H = 53;

// Use asset_get_index so missing sprites won't hard-crash compile if not present yet
var spr_level1  = asset_get_index("menu_Level_1");
var spr_level3  = asset_get_index("menu_Level_3");
var spr_boss1	= asset_get_index("menu_ukes");
var spr_boss3   = asset_get_index("menu_punky");
var spr_locked  = asset_get_index("menu_locked");

// Columns (must stay LEFT of x~1500 character buttons)
var lvl_col_x  = 980;
var boss_col_x = 1160;   // tighter now that buttons are small
var row_y0     = 120;
var row_gap    = 66;     // tighter spacing for 53px height

// 12 entries total (6 levels + 6 bosses)
level_btn = [];
level_btn[0]  = { name:"Level 1",      spr:spr_level1, x:lvl_col_x,  y:row_y0 + row_gap*0, w:LVL_W, h:LVL_H, enabled:true, room:rm_level01 };
level_btn[1]  = { name:"Level 2",      spr:spr_locked, x:lvl_col_x,  y:row_y0 + row_gap*1, w:LVL_W, h:LVL_H, enabled:false, room:noone };
level_btn[2]  = { name:"Level 3",      spr:spr_level3, x:lvl_col_x,  y:row_y0 + row_gap*2, w:LVL_W, h:LVL_H, enabled:true,  room:rm_level03 };
level_btn[3]  = { name:"Level 4",      spr:spr_locked, x:lvl_col_x,  y:row_y0 + row_gap*3, w:LVL_W, h:LVL_H, enabled:false, room:noone };
level_btn[4]  = { name:"Level 5",      spr:spr_locked, x:lvl_col_x,  y:row_y0 + row_gap*4, w:LVL_W, h:LVL_H, enabled:false, room:noone };
level_btn[5]  = { name:"Level 6",      spr:spr_locked, x:lvl_col_x,  y:row_y0 + row_gap*5, w:LVL_W, h:LVL_H, enabled:false, room:noone };

level_btn[6]  = { name:"Level 1 Boss", spr:spr_boss1, x:boss_col_x, y:row_y0 + row_gap*0, w:LVL_W, h:LVL_H, enabled:true, room:rm_boss_1 };
level_btn[7]  = { name:"Level 2 Boss", spr:spr_locked, x:boss_col_x, y:row_y0 + row_gap*1, w:LVL_W, h:LVL_H, enabled:false, room:noone };
level_btn[8]  = { name:"Level 3 Boss", spr:spr_boss3,  x:boss_col_x, y:row_y0 + row_gap*2, w:LVL_W, h:LVL_H, enabled:true,  room:rm_boss_3 };
level_btn[9]  = { name:"Level 4 Boss", spr:spr_locked, x:boss_col_x, y:row_y0 + row_gap*3, w:LVL_W, h:LVL_H, enabled:false, room:noone };
level_btn[10] = { name:"Level 5 Boss", spr:spr_locked, x:boss_col_x, y:row_y0 + row_gap*4, w:LVL_W, h:LVL_H, enabled:false, room:noone };
level_btn[11] = { name:"Level 6 Boss", spr:spr_locked, x:boss_col_x, y:row_y0 + row_gap*5, w:LVL_W, h:LVL_H, enabled:false, room:noone };

// Apply story progression gating per active profile
if (script_exists(scr_story_is_level_unlocked)) {
    for (var _li = 0; _li < array_length(level_btn); _li++) {
        var _lb = level_btn[_li];
        var gm = (variable_global_exists("game_mode") && is_string(global.game_mode)) ? global.game_mode : "arcade";
        if (_lb.enabled && _lb.room != noone && gm == "story") {
            var _rk = room_get_name(_lb.room);
            _lb.enabled = scr_story_is_level_unlocked(_rk);
            level_btn[_li] = _lb;
        }
    }
}

// Level selection state
sel_level = -1;
level_picked = false;

// Persisted selection (optional)
if (!variable_global_exists("menu_selected_room")) global.menu_selected_room = rm_level03;
if (!variable_global_exists("menu_selected_level_name")) global.menu_selected_level_name = "Level 3";

// NEW: level glows
glow_level = array_create(array_length(level_btn), 0);

// ----------------------------
// Upgrade + LFG
// ----------------------------
global.upgrade_char_id = (variable_global_exists("char_id") ? global.char_id : 0);

btn_upgrade = {
    spr: menu_upgrade,
    x: (page_right_x + 1420) - UI_SHIFT_LEFT,
    y: 190,
    w: BTN_W,
    h: BTN_H
};

btn_play = {
    spr: menu_LFG,
    x: (page_right_x + 1420) - UI_SHIFT_LEFT,
    y: 320,
    w: BTN_W,
    h: BTN_H
};

// BACK button (right page)
btn_back = {
    spr: menu_back_esc,
    x: page_right_x + 40,
    y: view_h - BTN_H - 40,
    w: BTN_W,
    h: BTN_H
};

// Glows
glow_start   = 0;
glow_story   = 0;
glow_arcade  = 0;
glow_options = 0;
glow_game    = 0;
glow_exit    = 0;

glow_back    = 0;
glow_char0   = 0;
glow_char1   = 0;
glow_char2   = 0;
glow_char3   = 0;

glow_easyL   = 0;
glow_normalL = 0;
glow_hardL   = 0;

glow_upgrade = 0;
glow_play    = 0;

// NEW: level glows
glow_level = array_create(array_length(level_btn), 0);

glow_speed = 0.18;

// Globals
if (!variable_global_exists("char_id")) global.char_id = 0;
if (!variable_global_exists("game_mode")) global.game_mode = "arcade";

if (!variable_global_exists("DIFFICULTY")) global.DIFFICULTY = "normal";
if (!variable_global_exists("difficulty")) global.difficulty = string_lower(string(global.DIFFICULTY));

camera_set_view_pos(cam, cam_x, cam_y);

// ----------------------------------------------------
// If returning from Upgrade, start on RIGHT page
// (do NOT auto-show Upgrade/LFG)
// ----------------------------------------------------
if (variable_global_exists("menu_return_to_right") && global.menu_return_to_right)
{
    global.menu_return_to_right = false;

    menu_state = 2;

    menu_cam_x = MENU_PAGE_2_X;
    menu_cam_target_x = MENU_PAGE_2_X;
    cam_x = menu_cam_x;
    cam_target_x = menu_cam_target_x;

    sel_char = global.char_id;
    picked_char_id = global.char_id;
    char_picked = false;

    // Keep last selected level if any
    level_picked = (variable_global_exists("menu_selected_room") && global.menu_selected_room != noone);
    sel_level = -1; // unknown index, fine

    cs_focus_back = false;
    cs_focus_upgrade = false;
    cs_focus_play = false;
}


if (!variable_global_exists("profile_panel_focus")) global.profile_panel_focus = false;

lb_open = false;
lb_btn_x = 0;
lb_btn_y = 0;
lb_btn_w = 0;
lb_btn_h = 0;
global.leaderboard_open = false;

