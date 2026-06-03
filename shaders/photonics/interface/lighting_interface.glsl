uniform vec3 light_dir;
uniform float worldTime;

uniform sampler2D colortex4;

const float blocklight_scale = 6.0f;

vec3 get_sun_direction() {
    return light_dir;
}

const float rcp_blocklight_scale = 1/blocklight_scale;

vec3 get_sun_color() {
    #if defined OVERWORLD
        #ifdef SH_SKYLIGHT
            return texelFetch(colortex4, ivec2(191, 11), 0).rgb * rcp_blocklight_scale * SKYLIGHT_I;
        #else
            return texelFetch(colortex4, ivec2(191, 1), 0).rgb * rcp_blocklight_scale * SKYLIGHT_I;
        #endif
    #else
        return mix(texelFetch(colortex4, ivec2(191, 1), 0).rgb, vec3(1.0f), 0.5) * rcp_blocklight_scale * SKYLIGHT_I;
    #endif
}

#define get_sky_color get_sun_color

#if defined OVERWORLD

#define WORLD_OVERWORLD
#include "/photonics/interface/is_in_shadow.glsl"

#elif defined END

#define WORLD_END
#include "/photonics/interface/is_in_shadow.glsl"

#else
bool is_in_shadow_at(vec3 scene_pos, vec3 geo_normal) {
    return false;
}
#endif
