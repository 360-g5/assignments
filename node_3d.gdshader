shader_type spatial;

uniform sampler2D heightmap : source_color;
uniform float height_scale = 20.0;

void vertex() {
    vec2 uv = UV;
    float h = texture(heightmap, uv).r; // read noise brightness
    VERTEX.y += h * height_scale;       // push vertex up
}

void fragment() {
    ALBEDO = vec3(0.9, 0.85, 0.6);
}