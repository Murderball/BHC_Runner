/// scr_set_difficulty_band(band)  // 0 easy, 1 normal, 2 hard
function scr_set_difficulty_band(band)
{
    global.DIFF_VIS_BAND = clamp(band, 0, 2);
    global.force_visual_restamp = true;
}