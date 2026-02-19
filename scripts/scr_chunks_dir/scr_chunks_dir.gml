/// scr_chunks_dir()
/// Writable output folder for chunk exports in THIS runtime.
/// Uses working_directory (always exists).

function scr_chunks_dir()
{
    var dir = working_directory + "chunks/";

    if (!directory_exists(dir)) directory_create(dir);
    return dir;
}