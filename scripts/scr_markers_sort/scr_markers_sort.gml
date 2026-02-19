function scr_markers_sort()
{
    // simple stable-ish bubble sort (matches your project style)
    var n = array_length(global.markers);
    for (var i = 0; i < n - 1; i++) {
        for (var j = i + 1; j < n; j++) {
            if (global.markers[i].t > global.markers[j].t) {
                var tmp = global.markers[i];
                global.markers[i] = global.markers[j];
                global.markers[j] = tmp;
            }
        }
    }
}
