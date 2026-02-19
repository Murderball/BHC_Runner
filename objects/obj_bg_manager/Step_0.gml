/// obj_bg_manager : Step Event

// Safety (Create should set sections, but don't crash if not)
if (is_undefined(sections)) exit;

var pps = 448;
if (variable_global_exists("WORLD_PPS")) pps = global.WORLD_PPS;
if (pps <= 0) pps = 1;

// Master time at HITLINE (same as chunk manager)
var t = global.editor_on
    ? scr_chart_time()
    : (scr_song_time() + (global.HITLINE_X / pps) + global.HITLINE_TIME_OFFSET_S);

// Find section
var next_i = cur_i;
for (var i = 0; i < array_length(sections); i++)
{
    var s = sections[i];
    if (t >= s.t0 && t < s.t1) { next_i = i; break; }
}

// Transition
if (next_i != cur_i)
{
    // lock what we were drawing as "prev" (for section fade)
    prev_i   = cur_i;
    prev_spr = cur_spr;

    cur_i = next_i;
    fade  = 0.0;
}

// --- Section progress 0..1 using your t0/t1 (use the SAME 't' we computed above) ---
var m = sections[cur_i];
var p01 = (m.t1 > m.t0) ? ((t - m.t0) / (m.t1 - m.t0)) : 0;
p01 = clamp(p01, 0, 1);

// Always pick current sprite from map (supports sequences)
cur_spr = scr_bg_seq_pick(bg_map, m.name, p01);

// Advance fade
if (fade < 1.0)
{
    fade += (delta_time / 1000000.0) / fade_s;
    if (fade > 1.0) fade = 1.0;
}