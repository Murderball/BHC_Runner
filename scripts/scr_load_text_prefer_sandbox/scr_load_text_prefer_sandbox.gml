///// @function scr_load_text_prefer_sandbox(fname)
///// @return string (file contents) or "" if missing
//function scr_load_text_prefer_sandbox(fname)
//{
//    // 1) sandbox path
//    if (file_exists(fname)) {
//        var f = file_text_open_read(fname);
//        var s = "";
//        while (!file_text_eof(f)) {
//            s += file_text_read_string(f);
//            file_text_readln(f);
//            if (!file_text_eof(f)) s += "\n";
//        }
//        file_text_close(f);
//        return s;
//    }

//    // 2) included files / datafiles
//    if (file_exists("datafiles/" + fname)) {
//        var g = file_text_open_read("datafiles/" + fname);
//        var t = "";
//        while (!file_text_eof(g)) {
//            t += file_text_read_string(g);
//            file_text_readln(g);
//            if (!file_text_eof(g)) t += "\n";
//        }
//        file_text_close(g);
//        return t;
//    }

//    return "";
//}
