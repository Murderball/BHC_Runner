function scr_bam_current()
{
    if (variable_global_exists("BAM") && is_real(global.BAM) && global.BAM > 0) return global.BAM;
    if (variable_global_exists("LEVEL_BAM") && is_real(global.LEVEL_BAM) && global.LEVEL_BAM > 0) return global.LEVEL_BAM;
    return 120;
}
