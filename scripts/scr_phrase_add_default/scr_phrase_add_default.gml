function scr_phrase_add_default(time_sec) {
    // Default pattern: 4 hits at 0, 0.25 beat, 0.5 beat, 0.75 beat
    // Convert beat fractions to seconds
    var beat_s = global.SEC_PER_BEAT;

    var st = [
        { dt: 0.0 * beat_s,    b: 1 },
        { dt: 0.25 * beat_s,   b: 2 },
        { dt: 0.50 * beat_s,   b: 3 },
        { dt: 0.75 * beat_s,   b: 4 }
    ];

    array_push(global.phrases, { kind:"phrase", t: time_sec, steps: st });
    scr_phrases_sort();
}
