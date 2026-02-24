/// obj_lightning_strike : Draw GUI
if (irandom(2) == 0) exit; // flicker

var x1 = strike_x;
var y1 = strike_y_top;
var x2 = strike_x;
var y2 = strike_y_bot;

draw_set_alpha(0.95);
draw_set_color(c_aqua);

var px = x1;
var py = y1;

for (var i = 1; i <= segs; i++) {
    var denom = segs;
    if (denom == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom = 1;
    }
    var t = i / denom;
    var nx = lerp(x1, x2, t) + random_range(-jag, jag);
    var ny = lerp(y1, y2, t);

    // main bolt + fake thickness
    draw_line(px, py, nx, ny);
    draw_line(px + 1, py, nx + 1, ny);
    draw_line(px - 1, py, nx - 1, ny);

    px = nx;
    py = ny;
}

// hot core pass
draw_set_alpha(0.55);
draw_set_color(c_white);

px = x1; py = y1;
for (var i = 1; i <= segs; i++) {
    var denom = segs;
    if (denom == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom = 1;
    }
    var t = i / denom;
    var nx = lerp(x1, x2, t) + random_range(-jag * 0.5, jag * 0.5);
    var ny = lerp(y1, y2, t);

    draw_line(px, py, nx, ny);
    px = nx;
    py = ny;
}

draw_set_alpha(1);
draw_set_color(c_white);
