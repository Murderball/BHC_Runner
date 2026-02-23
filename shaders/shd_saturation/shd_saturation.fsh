// shd_saturation.fsh
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_sat; // 0 = grayscale, 1 = normal, >1 = extra saturated

void main() {
    vec4 col = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);

    // Luma (perceived brightness)
    float luma = dot(col.rgb, vec3(0.299, 0.587, 0.114));

    // Interpolate between gray and original by saturation
    vec3 gray = vec3(luma);
    col.rgb = mix(gray, col.rgb, u_sat);

    gl_FragColor = col;
}