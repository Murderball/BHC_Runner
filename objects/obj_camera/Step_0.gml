/// obj_camera : Step
/// Ring-strip camera (no pauses): wrap within valid camera range
/// Beat-locked micro pulse zoom that DOES NOT move the hitline in world space.

	var cam = view_camera[0];

	// Preserve current camera Y unless you explicitly set it elsewhere
	var keep_y = camera_get_view_y(cam);

	// Boss room camera: static, no strip logic
	if (variable_global_exists("LEVEL_MODE") && global.LEVEL_MODE == "boss")
	{

	    // no pulse (optional)
	    cam_zoom = 1.0;
	    camera_set_view_size(cam, global.BASE_W, global.BASE_H);

	    cam_world_x = 0;
	    cam_world_y = camera_get_view_y(cam);
	    camera_set_view_pos(cam, cam_world_x, cam_world_y);
	    exit;
}

	// --- REQUIRED GLOBALS READY? ---
	if (!variable_global_exists("WORLD_PPS")
	 || !variable_global_exists("CHUNK_W_TILES")
	 || !variable_global_exists("TILE_W")
	 || !variable_global_exists("BUFFER_CHUNKS")
	 || !variable_global_exists("HITLINE_X")
	 || !variable_global_exists("BASE_W")
	 || !variable_global_exists("BASE_H")) {
	    cam_world_x = 0;
	    cam_world_y = keep_y;
	    camera_set_view_pos(cam, cam_world_x, cam_world_y);
	    dbg_cam_error = "camera waiting: globals not ready";
	    exit;
	}

	// --- TIME SOURCE ---
	var t_raw = (variable_global_exists("editor_on") && global.editor_on) ? scr_chart_time() : scr_song_time();
	if (!is_real(t_raw) || is_nan(t_raw)) t_raw = 0.0;
	var t = max(0, t_raw);

	// ----------------------------------------------------
	// 1) BEAT PULSE ZOOM (safe, tiny) — respects offsets
	// ----------------------------------------------------
	var zoom_pulse = 1.0;

if (variable_global_exists("CAM_PULSE_ON") && global.CAM_PULSE_ON) {
    var bpm = (variable_global_exists("BPM") && is_real(global.BPM) && global.BPM > 0) ? global.BPM : 140;
    var denom_bpm = bpm;
    if (denom_bpm == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_bpm = 1;
    }
    var beat_s = 60.0 / denom_bpm;

	var t_pulse = t;

	// If you use START_TIME_S as a musical zero, include it
	if (variable_global_exists("START_TIME_S")) t_pulse += global.START_TIME_S;

	// Keep hitline timing reference (this is "when the hit happens")
	if (variable_global_exists("HITLINE_TIME_OFFSET_S")) t_pulse += global.HITLINE_TIME_OFFSET_S;
	if (variable_global_exists("CAM_PULSE_TIME_OFFSET_S")) t_pulse += global.CAM_PULSE_TIME_OFFSET_S;

	// DO NOT include global.OFFSET here in your project

    // Beat index + phase (0..1)
    var denom_beat_i = beat_s;
    if (denom_beat_i == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_beat_i = 1;
    }
    var beat_i = floor(t_pulse / denom_beat_i);
    var denom_beat_phase = beat_s;
    if (denom_beat_phase == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_beat_phase = 1;
    }
    var beat_phase = (t_pulse - (beat_i * beat_s)) / denom_beat_phase; // 0..1

    // Pulse window length (fraction of beat)
    var len = (variable_global_exists("CAM_PULSE_LEN_BEATS")) ? global.CAM_PULSE_LEN_BEATS : 0.22;
    len = clamp(len, 0.05, 0.75);

    // Pulse shape: snap then relax within len, otherwise 0
    var pulse = 0.0;
    if (beat_phase < len) {
        var denom_len = len;
        if (denom_len == 0)
        {
            show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
            denom_len = 1;
        }
        var u = 1.0 - (beat_phase / denom_len); // 1 -> 0
        pulse = u * u * (3.0 - 2.0 * u);  // smoothstep
    }

    // Downbeat detection (assume 4/4 unless you change BEATS_PER_BAR)
    var bpb = (variable_global_exists("BEATS_PER_BAR")) ? global.BEATS_PER_BAR : 4;
    if (!is_real(bpb) || bpb <= 0) bpb = 4;

    var is_downbeat = ((beat_i mod bpb) == 0);

    var amp_beat = (variable_global_exists("CAM_PULSE_AMP_BEAT")) ? global.CAM_PULSE_AMP_BEAT : 0.035;
    var amp_down = (variable_global_exists("CAM_PULSE_AMP_DOWN")) ? global.CAM_PULSE_AMP_DOWN : 0.055;

    var amp = is_downbeat ? amp_down : amp_beat;
    amp = clamp(amp, 0.0, 0.15);

    zoom_pulse = 1.0 + (amp * pulse);
}

// Marker-driven camera track (zoom + pan).
var marker_zoom = 1.0;
var marker_pan_x = 0.0;
var marker_pan_y = 0.0;

if (variable_global_exists("camera_events") && is_array(global.camera_events) && array_length(global.camera_events) > 0)
{
    var ev_prev = -1;
    var ev_next = -1;

    for (var ei = 0; ei < array_length(global.camera_events); ei++)
    {
        var ev = global.camera_events[ei];
        if (!is_struct(ev)) continue;

        if (ev.t <= t) ev_prev = ei;
        if (ev.t > t) { ev_next = ei; break; }
    }

    if (ev_prev >= 0)
    {
        marker_zoom = global.camera_events[ev_prev].zoom;
        marker_pan_x = global.camera_events[ev_prev].pan_x;
        marker_pan_y = global.camera_events[ev_prev].pan_y;
    }

    if (ev_next >= 0)
    {
        var next_ev = global.camera_events[ev_next];

        var start_t = 0.0;
        var start_zoom = 1.0;
        var start_pan_x = 0.0;
        var start_pan_y = 0.0;

        if (ev_prev >= 0)
        {
            var prev_ev = global.camera_events[ev_prev];
            start_t = prev_ev.t;
            start_zoom = prev_ev.zoom;
            start_pan_x = prev_ev.pan_x;
            start_pan_y = prev_ev.pan_y;
        }

        var denom = max(0.0001, next_ev.t - start_t);
        var k = clamp((t - start_t) / denom, 0.0, 1.0);

        var ease_mode = (variable_struct_exists(next_ev, "ease") ? next_ev.ease : "smooth");
        if (ease_mode == "hold") k = (k >= 1.0) ? 1.0 : 0.0;
        else if (ease_mode == "smooth") k = k * k * (3.0 - (2.0 * k));

        marker_zoom = lerp(start_zoom, next_ev.zoom, k);
        marker_pan_x = lerp(start_pan_x, next_ev.pan_x, k);
        marker_pan_y = lerp(start_pan_y, next_ev.pan_y, k);
    }
}

var zoom = clamp(zoom_pulse * marker_zoom, cam_zoom_min, cam_zoom_max);

// Save for UI/debug
cam_zoom = zoom;
dbg_cam_marker_zoom = marker_zoom;
dbg_cam_marker_pan_x = marker_pan_x;
dbg_cam_marker_pan_y = marker_pan_y;

// Apply zoom by changing camera *view size* (port stays BASE_W/BASE_H)
var base_w = global.BASE_W;
var base_h = global.BASE_H;

var denom_zoom_w = zoom;
if (denom_zoom_w == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_zoom_w = 1;
}
var view_w = base_w / denom_zoom_w;
var denom_zoom_h = zoom;
if (denom_zoom_h == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_zoom_h = 1;
}
var view_h = base_h / denom_zoom_h;

camera_set_view_size(cam, view_w, view_h);

// ----------------------------------------------------
// 2) NORMAL RING-STRIP CAMERA X (timing critical)
// ----------------------------------------------------

// PPS
var pps = global.WORLD_PPS;
if (!is_real(pps) || is_nan(pps) || pps <= 0) pps = 1.0;

// Strip geometry
var chunk_w_px = global.CHUNK_W_TILES * global.TILE_W;
if (!is_real(chunk_w_px) || is_nan(chunk_w_px) || chunk_w_px < 1) {
    cam_world_x = 0;
    cam_world_y = keep_y + marker_pan_y;
    camera_set_view_pos(cam, cam_world_x, cam_world_y);
    dbg_cam_error = "camera waiting: bad chunk_w_px";
    exit;
}

var buf = global.BUFFER_CHUNKS;
if (!is_real(buf) || is_nan(buf) || buf < 2) {
    cam_world_x = 0;
    cam_world_y = keep_y + marker_pan_y;
    camera_set_view_pos(cam, cam_world_x, cam_world_y);
    dbg_cam_error = "camera waiting: BUFFER_CHUNKS < 2";
    exit;
}

var strip_w_px = buf * chunk_w_px;

// Camera can be positioned in [0 .. strip_w_px - view_w]
var wrap_w = strip_w_px - view_w;
if (!is_real(wrap_w) || is_nan(wrap_w) || wrap_w < 1) {
    cam_world_x = 0;
    cam_world_y = keep_y + marker_pan_y;
    camera_set_view_pos(cam, cam_world_x, cam_world_y);
    dbg_cam_error = "strip < view (increase BUFFER_CHUNKS)";
    exit;
}

// Absolute progression in world pixels
var x_abs = t * pps;

// NOTE: Do NOT add CHUNK_X_OFFSET_PX here.
// That offset belongs to the chunk/tile layer placement, not camera timing.
if (variable_global_exists("START_WORLD_X_PX")) x_abs += global.START_WORLD_X_PX;

// --- ABSOLUTE WORLD X (never wraps) ---
// Anything that should scroll smoothly (parallax, fog, clouds, distant city)
// should use this instead of camera_get_view_x().
global.WORLD_X_ABS = x_abs;

// Phase-locked X inside strip
var denom_ci = chunk_w_px;
if (denom_ci == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_ci = 1;
}
var ci_f = x_abs / denom_ci;     // fractional ci (shows smooth motion)
var ci   = floor(ci_f);            // integer ci (chunk index)

var phase = x_abs - (ci * chunk_w_px);

var slot = ci mod buf;
if (slot < 0) slot += buf;

var x_vis_raw = (slot * chunk_w_px) + phase;

// Wrap into valid camera-left range (prevents clamp pauses)
var x_vis = x_vis_raw mod wrap_w;
if (x_vis < 0) x_vis += wrap_w;

// ----------------------------------------------------
// 3) HITLINE ANCHOR COMPENSATION (keeps hitline fixed)
// ----------------------------------------------------
var hitx = global.HITLINE_X; // px from camera left at zoom=1
var denom_anchor = zoom;
if (denom_anchor == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_anchor = 1;
}
var anchor_shift = hitx - (hitx / denom_anchor);
x_vis += anchor_shift;
x_vis += marker_pan_x;

// Wrap again after shift
x_vis = x_vis mod wrap_w;
if (x_vis < 0) x_vis += wrap_w;

// Final (preserve Y)
cam_world_x = x_vis;
cam_world_y = keep_y + marker_pan_y;
camera_set_view_pos(cam, cam_world_x, cam_world_y);

// Debug
dbg_cam_ci = ci;
dbg_cam_slot = slot;
dbg_cam_phase = phase;
dbg_cam_x_vis = x_vis;
dbg_wrap_w = wrap_w;
dbg_zoom = zoom;
dbg_cam_error = "";
