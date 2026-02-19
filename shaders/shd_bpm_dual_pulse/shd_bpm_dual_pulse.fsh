// shd_bpm_dual_pulse.fsh
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
uniform float u_enable_blue; // 1.0 on, 0.0 off
uniform float u_enable_pink; // 1.0 on, 0.0 off

uniform float u_time_s;     // chart time in seconds
uniform float u_spb;        // seconds per beat

uniform vec3  u_blue_key;   // key color (0..1)
uniform vec3  u_pink_key;   // key color (0..1)
uniform float u_tol;        // color tolerance (bigger = affects more pixels)

uniform float u_str_blue;   // pulse strength for blues
uniform float u_str_pink;   // pulse strength for pinks
uniform float u_decay;      // decay per beat (bigger = faster fade)

float pulse_env(float phase01, float decay) {
    // phase01 goes 0->1 over the beat
    // quick hit then decay
    return exp(-phase01 * decay);
}

float color_mask(vec3 rgb, vec3 key, float tol) {
    // distance-based mask (soft)
    float d = distance(rgb, key);
    // 0 at d>=tol, 1 near key color
    return clamp(1.0 - (d / max(tol, 0.0001)), 0.0, 1.0);
}

void main() {
    vec4 base = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    vec3 rgb  = base.rgb;

    float spb = max(u_spb, 0.0001);
    float beat = u_time_s / spb;
    float idx  = floor(beat);
    float ph   = fract(beat);          // 0..1 within current beat
    float env  = pulse_env(ph, u_decay);

	// even beats -> blues, odd beats -> pinks
	float is_even = 1.0 - mod(idx, 2.0);
	float is_odd  = 1.0 - is_even;

	float m_blue = color_mask(rgb, u_blue_key, u_tol);
	float m_pink = color_mask(rgb, u_pink_key, u_tol);

	// HARD OFF gates + strength gates
	float blue_on = step(0.0001, u_str_blue) * step(0.5, u_enable_blue);
	float pink_on = step(0.0001, u_str_pink) * step(0.5, u_enable_pink);

	float blue_boost = env * is_even * u_str_blue * m_blue * blue_on;
	float pink_boost = env * is_odd  * u_str_pink * m_pink * pink_on;

	rgb += rgb * (blue_boost + pink_boost);


    // Additive-ish “glow” without nuking everything
    rgb += rgb * (blue_boost + pink_boost);

    gl_FragColor = vec4(clamp(rgb, 0.0, 1.0), base.a);
}
