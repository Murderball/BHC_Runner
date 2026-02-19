function scr_phrases_sort() {
    array_sort(global.phrases, function(a, b) {
        return (a.t > b.t) - (a.t < b.t);
    });
}
