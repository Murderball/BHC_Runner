function scr_chart_sort() {
    array_sort(global.chart, function(a, b) {
        return (a.t > b.t) - (a.t < b.t);
    });
}
