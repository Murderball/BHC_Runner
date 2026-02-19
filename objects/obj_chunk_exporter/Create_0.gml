/// obj_chunk_exporter : Create
/// Manual export helper (press E) — uses shared 3-visual exporter script.

scr_chunk_system_init();

// Keybind
export_key = ord("E");

// Optional: keep some debug strings if you draw them
dbg_line1 = "";
dbg_line2 = "";
dbg_line3 = "";
dbg_line4 = "";
last_export_fname = "";

// (Optional) if you still want a custom stem override per-instance:
if (!variable_instance_exists(id, "export_stem_override")) export_stem_override = "";