varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time_s;
uniform float u_spb;
uniform float u_tol;
uniform float u_decay;
uniform float u_str_teal;
uniform float u_str_pink;
uniform vec3  u_teal_key;
uniform vec3  u_pink_key;

float color_mask(vec3 rgb, vec3 key, float tol) {
    float t = max(tol, 0.0001);
    return clamp(1.0 - (distance(rgb, key) / t), 0.0, 1.0);
}

void main() {
    vec4 base = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    vec3 rgb  = base.rgb;

    float spb  = max(u_spb, 0.0001);
    float beat = u_time_s / spb;
    float idx  = floor(beat);
    float ph   = fract(beat);

    float env = exp(-ph * u_decay);

    float is_even = 1.0 - mod(idx, 2.0);
    float is_odd  = 1.0 - is_even;

    float tealMask = color_mask(rgb, u_teal_key, u_tol);
    float pinkMask = color_mask(rgb, u_pink_key, u_tol);

    rgb += rgb * (
        env * is_even * u_str_teal * tealMask +
        env * is_odd  * u_str_pink * pinkMask
    );

    gl_FragColor = vec4(clamp(rgb, 0.0, 1.0), base.a);
}
