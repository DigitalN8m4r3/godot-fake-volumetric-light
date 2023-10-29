shader_type spatial;
render_mode blend_add;

uniform vec4 base_color : source_color;
uniform sampler2D dust : source_color, filter_nearest;
uniform float proximity_fade_distance: hint_range(0.0, 5.0) = 2.0;
uniform sampler2D gradient;
uniform float dust_speed = 0.05;
uniform float brightness : hint_range(0.0,10.0) = 1.0;

float fresnel(float amount, vec3 normal, vec3 view)
{
    return pow(
        (clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)),
        amount
    );
}

void fragment() {
    float basic_fresnel = fresnel(2.0, NORMAL, VIEW);
	vec2 dust_uv = vec2(SCREEN_UV.x + dust_speed * TIME, SCREEN_UV.y);
	vec4 dust_overlay = texture(dust, dust_uv);
    vec4 particle = texture(dust, UV * vec2(0.5, 0.50) + vec2(0, dust_speed * TIME));
    vec4 color = texture(gradient, vec2(UV.y, 0));

    ALBEDO = base_color.rgb * particle.rgb * color.rgb * proximity_fade_distance;
    EMISSION = ALBEDO * brightness;
    ALPHA = particle.a * pow(UV.y, 1) * pow(basic_fresnel, brightness);
}