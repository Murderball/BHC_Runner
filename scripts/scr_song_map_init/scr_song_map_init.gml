function scr_song_map_init()
{
    global.SONG_SND_READY = true;
    global.__song_map_inited = true;
    global.song_map = {
        level01: { easy: "Level 1.1-Voice of Reason (Easy)", normal: "Level 1.2 - Voice of Reason (Normal)", hard: "Level 1.3 - Voice of Reason (Hard)", boss: "Level 1.4 -Hunger (BOSS)" },
        level03: { easy: "Level 3.1 - Bringer of Rain (Easy)", normal: "Level 3.2 - Bringer of Rain (Normal)", hard: "Level 3.3 - Bringer of Rain (Hard)", boss: "Level 3.4 - Faceless(BOSS)" }
    };
}
