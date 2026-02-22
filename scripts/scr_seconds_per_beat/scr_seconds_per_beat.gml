function scr_seconds_per_beat()
{
    var bam = scr_bam_current();
    return 60 / max(1, bam);
}
