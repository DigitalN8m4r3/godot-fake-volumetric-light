shader_type spatial;
render_mode blend_add;

uniform vec4 albedo : source_color;
uniform sampler2D dust : source_color;
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
    vec4 pixel = texture(dust, UV * vec2(0.5, 0.50) + vec2(0, dust_speed * TIME));
    vec4 color = texture(gradient, vec2(UV.y, 0));

    ALBEDO = albedo.rgb * pixel.rgb * color.rgb * proximity_fade_distance;
    EMISSION = ALBEDO * brightness;
    ALPHA = pixel.a * pow(UV.y, 1) * pow(basic_fresnel, 15.25);
    vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV*brightness,1.0,1.0);
    world_pos.xyz/=world_pos.w;
    ALPHA*=clamp(2.0-smoothstep(world_pos.z,world_pos.z,VERTEX.z),1.0,1.0);
}