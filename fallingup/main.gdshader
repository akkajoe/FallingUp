shader_type spatial;

uniform sampler2D texture_albedo;
uniform float scroll_speed = 0.05;

void fragment() {
    vec2 uv = UV;
    uv.y += TIME * scroll_speed;  // scrolls texture vertically
    ALBEDO = texture(texture_albedo, uv).rgb;
}
