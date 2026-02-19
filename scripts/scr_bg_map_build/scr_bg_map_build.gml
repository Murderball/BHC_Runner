function scr_bg_map_build(_profile)
{
    var p = string_lower(string(_profile));
    var m = ds_map_create();

    switch (p)
    {
        case "near":
        default:

            ds_map_add(m, "intro", [
                spr_bg_easy_00, spr_bg_easy_01, spr_bg_easy_02, spr_bg_easy_03, spr_bg_easy_04
            ]);

            ds_map_add(m, "break", [
                spr_bg_easy_05
            ]);

            ds_map_add(m, "main", [
                spr_bg_easy_06, spr_bg_easy_07, spr_bg_easy_08, spr_bg_easy_00, spr_bg_easy_01, spr_bg_easy_02, spr_bg_easy_03, spr_bg_easy_04
            ]);

            ds_map_add(m, "verse", [
                spr_bg_easy_05, spr_bg_easy_06, spr_bg_easy_07, spr_bg_easy_08, spr_bg_easy_00, spr_bg_easy_01, spr_bg_easy_02, spr_bg_easy_03
            ]);

            ds_map_add(m, "pre chorus", [
                spr_bg_easy_04, spr_bg_easy_05, spr_bg_easy_06, spr_bg_easy_07
            ]);

            ds_map_add(m, "chorus", [
                spr_bg_easy_08, spr_bg_easy_00, spr_bg_easy_01, spr_bg_easy_02, spr_bg_easy_03, spr_bg_easy_04, spr_bg_easy_05, spr_bg_easy_06
            ]);

            ds_map_add(m, "chorus_2", [
                spr_bg_easy_07, spr_bg_easy_08, spr_bg_easy_00, spr_bg_easy_01, spr_bg_easy_02, spr_bg_easy_03, spr_bg_easy_04, spr_bg_easy_05
            ]);

            ds_map_add(m, "verse_2", [
                spr_bg_easy_06, spr_bg_easy_07, spr_bg_easy_08, spr_bg_easy_00, spr_bg_easy_01, spr_bg_easy_02
            ]);

            ds_map_add(m, "break_2", [
                spr_bg_easy_03, spr_bg_easy_04
            ]);

            ds_map_add(m, "breakdown", [
                spr_bg_easy_05, spr_bg_easy_06, spr_bg_easy_07, spr_bg_easy_08, spr_bg_easy_00, spr_bg_easy_01, spr_bg_easy_02, spr_bg_easy_03
            ]);

            ds_map_add(m, "pre chorus_2", [
                spr_bg_easy_04, spr_bg_easy_05, spr_bg_easy_06, spr_bg_easy_07, spr_bg_easy_08, spr_bg_easy_00, spr_bg_easy_01, spr_bg_easy_02
            ]);

            ds_map_add(m, "chorus_return", [
                spr_bg_easy_03, spr_bg_easy_04, spr_bg_easy_05, spr_bg_easy_06, spr_bg_easy_07, spr_bg_easy_08, spr_bg_easy_00
            ]);

            ds_map_add(m, "break_3", [
                spr_bg_easy_01
            ]);

            ds_map_add(m, "bridge", [
                spr_bg_easy_02, spr_bg_easy_03, spr_bg_easy_04, spr_bg_easy_05, spr_bg_easy_06, spr_bg_easy_07, spr_bg_easy_08, spr_bg_easy_00
            ]);

            ds_map_add(m, "build", [
                spr_bg_easy_01, spr_bg_easy_02, spr_bg_easy_03, spr_bg_easy_04, spr_bg_easy_05, spr_bg_easy_06, spr_bg_easy_07, spr_bg_easy_08
            ]);

            ds_map_add(m, "breakdown_2", [
                spr_bg_easy_00, spr_bg_easy_01, spr_bg_easy_02, spr_bg_easy_03, spr_bg_easy_04, spr_bg_easy_05, spr_bg_easy_06, spr_bg_easy_07
            ]);

            ds_map_add(m, "chorus_3", [
                spr_bg_easy_08, spr_bg_easy_00, spr_bg_easy_01, spr_bg_easy_02, spr_bg_easy_03, spr_bg_easy_04, spr_bg_easy_05, spr_bg_easy_06
            ]);

            ds_map_add(m, "outro", [
                spr_bg_easy_07, spr_bg_easy_08, spr_bg_easy_00, spr_bg_easy_01, spr_bg_easy_02, spr_bg_easy_03, spr_bg_easy_04, spr_bg_easy_05
            ]);

        break;

        case "far":
            // TODO: set your far layer sprites here (single or arrays)
        break;
    }

    return m;
}