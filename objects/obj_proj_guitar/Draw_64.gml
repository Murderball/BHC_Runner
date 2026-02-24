/// obj_proj_guitar : Draw GUI

var bolt_col = c_aqua;
if (variable_instance_exists(id, "proj_color")) bolt_col = proj_color;
draw_set_color(bolt_col);
draw_set_alpha(0.9);

// Use GUI-space position instead of room-space x/y
var x1 = gui_x;
var y1 = gui_y;

// Compute bolt end in GUI-space
var x2 = gui_x + lengthdir_x(len, dir);
var y2 = gui_y + lengthdir_y(len, dir);

var segs_local = 4; // keep it local like before (or use segs var)
var px = x1;
var py = y1;

for (var i = 1; i <= segs_local; i++)
{
    var t = i / segs_local;

    var nx = lerp(x1, x2, t) + random_range(-jag, jag);
    var ny = lerp(y1, y2, t) + random_range(-jag, jag);

    // main bolt
    draw_line(px, py, nx, ny);

    // fake thickness / glow (same as before)
    draw_line(px + 1, py, nx + 1, ny);
    draw_line(px - 1, py, nx - 1, ny);

    px = nx;
    py = ny;
}

// reset state
draw_set_alpha(1);
draw_set_color(c_black);
