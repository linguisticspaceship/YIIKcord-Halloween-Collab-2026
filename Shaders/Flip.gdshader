shader_type spatial;

uniform sampler2D texture_albedo : source_color, filter_nearest;
uniform sampler2D texture_normal: hint_normal, filter_nearest;
uniform bool h_flip = false;

void fragment() {
    // Determine UV coordinates horizontally
    vec2 uv = h_flip ? vec2(1.0 - UV.x, UV.y) : UV;

    // Sample the textures using the flipped UV coordinates
    vec4 albedo_color = texture(texture_albedo, uv);
    vec3 normal_map = texture(texture_normal, uv).rgb;

    // Adjust the normal map if flipping
    if (h_flip) {
        normal_map.r = 1.0 - normal_map.r; // Invert the X channel
    }

    // Apply the albedo color and handle transparency
    ALBEDO = albedo_color.rgb;
    ALPHA = albedo_color.a;

    // Apply the normal map
    NORMAL = normalize((normal_map * 2.0) - 1.0);
}