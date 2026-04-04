const mat3 PSYCHO11_BT709_TO_XYZ_MAT = BT709_TO_XYZ_MAT; /* mat3( */
    // vec3(0.4123907993f, 0.3575843394f, 0.1804807884f),
    // vec3(0.2126390059f, 0.7151686788f, 0.0721923154f),
    // vec3(0.0193308187f, 0.1191947798f, 0.9505321522f));

const mat3 PSYCHO11_XYZ_TO_BT709_MAT = XYZ_TO_BT709_MAT; /* mat3( */
    // vec3(3.2409699419f, -1.5373831776f, -0.4986107603f),
    // vec3(-0.9692436363f, 1.8759675015f, 0.0415550574f),
    // vec3(0.0556300797f, -0.2039769589f, 1.0569715142f));

const mat3 PSYCHO11_BT2020_TO_XYZ_MAT = BT2020_TO_XYZ_MAT; /* mat3( */
    // vec3(0.6369580483f, 0.1446169036f, 0.1688809752f),
    // vec3(0.2627002120f, 0.6779980715f, 0.0593017165f),
    // vec3(0.0000000000f, 0.0280726930f, 1.0609850577f));

const mat3 PSYCHO11_XYZ_TO_BT2020_MAT = XYZ_TO_BT2020_MAT; /* mat3( */
    // vec3(1.7166511880f, -0.3556707838f, -0.2533662814f),
    // vec3(-0.6666843518f, 1.6164812366f, 0.0157685458f),
    // vec3(0.0176398574f, -0.0427706133f, 0.9421031212f));

const mat3 PSYCHO11_XYZ_TO_STOCKMAN_SHARP_LMS_MAT = mat3(
    vec3(0.2670502842655792f, -0.38706882411220156f, 0.026727793989083093f),
    vec3(0.8471990148492798f, 1.165429935890458f, -0.02729131667566509f),
    vec3(-0.03470416612462053f, 0.10302286696614202f, 0.5333267257603284f));
    // vec3(0.2670502842655792f, 0.8471990148492798f, -0.03470416612462053f),
    // vec3(-0.38706882411220156f, 1.165429935890458f, 0.10302286696614202f),
    // vec3(0.026727793989083093f, -0.02729131667566509f, 0.5333267257603284f));

const mat3 PSYCHO11_XYZ_TO_STOCKMAN_SHARP_LMS_MAT_INV = mat3(
    vec3(1.811462963687362,0.6069124057314326,-0.05972505917019777),
    vec3(-1.308149261253547,0.4159062592830002,0.08684090099781154),
    vec3(0.3705694640609474,-0.04084825533137023,1.854361773496562));

const vec3 PSYCHO11_CIE1702_MB_CIE_WEIGHTS = vec3(
    0.68990272f, 0.34832189f, 0.0371597f);

const vec2 PSYCHO11_WHITE_POINT_D65 = vec2(0.31272f, 0.32903f);

float psycho11_DivideSafe(float dividend, float divisor, float fallback) {
  return divisor == 0.f ? fallback : (dividend / divisor);
}

vec3 psycho11_SignPow(vec3 x, vec3 exponent) {
  return vec3(
      (x.x < 0.f ? -1.f : 1.f) * pow(abs(x.x), exponent.x),
      (x.y < 0.f ? -1.f : 1.f) * pow(abs(x.y), exponent.y),
      (x.z < 0.f ? -1.f : 1.f) * pow(abs(x.z), exponent.z));
}

// mat3 psycho11_Invert3x3(mat3 m) {
//   float a = m[0][0], b = m[1][0], c = m[2][0];
//   float d = m[0][1], e = m[1][1], f = m[2][1];
//   float g = m[0][2], h = m[1][2], i = m[2][2];
// 
//   float A = (e * i - f * h);
//   float B = -(d * i - f * g);
//   float C = (d * h - e * g);
//   float D = -(b * i - c * h);
//   float E = (a * i - c * g);
//   float F = -(a * h - b * g);
//   float G = (b * f - c * e);
//   float H = -(a * f - c * d);
//   float I = (a * e - b * d);
// 
//   float det = a * A + b * B + c * C;
//   float inv_det = psycho11_DivideSafe(1.f, det, 0.f);
// 
//   return mat3(
//              A, D, G,
//              B, E, H,
//              C, F, I)
//          * inv_det;
// }

vec3 psycho11_XYZFromxyY(vec3 xyY) {
  vec3 xyz;
  xyz.xz = vec2(xyY.x, (1.f - xyY.x - xyY.y)) / xyY.y * xyY.z;
  xyz.y = xyY.z;
  return xyz;
}

vec3 psycho11_BT2020FromBT709(vec3 bt709) {
  return (PSYCHO11_XYZ_TO_BT2020_MAT * (PSYCHO11_BT709_TO_XYZ_MAT * bt709));
}

vec3 psycho11_BT709FromBT2020(vec3 bt2020) {
  return (PSYCHO11_XYZ_TO_BT709_MAT * (PSYCHO11_BT2020_TO_XYZ_MAT * bt2020));
}

vec3 psycho11_LMSFromBT2020(vec3 bt2020) {
  vec3 xyz = (PSYCHO11_BT2020_TO_XYZ_MAT * bt2020);
  return (PSYCHO11_XYZ_TO_STOCKMAN_SHARP_LMS_MAT * xyz);
}

vec3 psycho11_BT2020FromLMS(vec3 lms_abs) {
  mat3 lms_to_xyz = PSYCHO11_XYZ_TO_STOCKMAN_SHARP_LMS_MAT_INV/* psycho11_Invert3x3(PSYCHO11_XYZ_TO_STOCKMAN_SHARP_LMS_MAT) */;
  vec3 xyz = (lms_to_xyz * lms_abs);
  return (PSYCHO11_XYZ_TO_BT2020_MAT * xyz);
}

float psycho11_StockmanLuminanceFromLMS(vec3 lms_abs) {
  return dot(lms_abs, vec3(0.68990272f, 0.34832189f, 0.0f));
}

vec3 psycho11_MB2FromLMS(vec3 lms_abs) {
  const float mb2_eps = 1e-12f;

  float weighted_l = PSYCHO11_CIE1702_MB_CIE_WEIGHTS.x * lms_abs.x;
  float weighted_m = PSYCHO11_CIE1702_MB_CIE_WEIGHTS.y * lms_abs.y;
  float y_mb = weighted_l + weighted_m;
  if (y_mb <= mb2_eps) return vec3(0);

  float inv = psycho11_DivideSafe(1.f, y_mb, 0.f);
  return vec3(
      weighted_l * inv,
      PSYCHO11_CIE1702_MB_CIE_WEIGHTS.z * lms_abs.z * inv,
      y_mb);
}

vec3 psycho11_LMSFromMB2(vec3 mb2_lsy) {
  float l = mb2_lsy.x;
  float s = mb2_lsy.y;
  float y = max(mb2_lsy.z, 0.f);

  float L = psycho11_DivideSafe(l * y, PSYCHO11_CIE1702_MB_CIE_WEIGHTS.x, 0.f);
  float M = psycho11_DivideSafe((1.f - l) * y, PSYCHO11_CIE1702_MB_CIE_WEIGHTS.y, 0.f);
  float S = psycho11_DivideSafe(s * y, PSYCHO11_CIE1702_MB_CIE_WEIGHTS.z, 0.f);
  return vec3(L, M, S);
}

vec2 psycho11_WhiteD65Chromaticity() {
  vec3 d65_xyz = psycho11_XYZFromxyY(vec3(PSYCHO11_WHITE_POINT_D65, 1.f));
  vec3 d65_lms = (PSYCHO11_XYZ_TO_STOCKMAN_SHARP_LMS_MAT * d65_xyz);
  return psycho11_MB2FromLMS(d65_lms).xy;
}

float psycho11_ContrastSafe(float x, float contrast, float mid_gray) {
  float ratio = x / mid_gray;
  float signed_pow = (ratio < 0.f ? -1.f : 1.f) * pow(abs(ratio), contrast);
  return signed_pow * mid_gray;
}

float psycho11_Highlights(float x, float highlights, float mid_gray) {
  if (highlights > 1.f) {
    return max(x, mix(x, mid_gray * pow(x / mid_gray, highlights), x));
  }
  if (highlights < 1.f) {
    return min(x, x / (1.f + mid_gray * pow(x / mid_gray, 2.f - highlights) - x));
  }
  return x;
}

float psycho11_Shadows(float x, float shadows, float mid_gray) {
  if (shadows > 1.f) {
    return max(x, x * (1.f + (x * mid_gray / pow(x / mid_gray, shadows))));
  }
  if (shadows < 1.f) {
    return clamp(x * (1.f - (x * mid_gray / pow(x / mid_gray, 2.f - shadows))), 0.f, x);
  }
  return x;
}

float psycho11_Neutwo(float x) {
  return x * inversesqrt(((x * x) + 1.f));
}

float psycho11_Neutwo(float x, float peak) {
  return (peak * x) * inversesqrt(((x * x) + (peak * peak)));
}

float psycho11_Neutwo(float x, float peak, float clip) {
  float cc = clip * clip;
  float pp = peak * peak;
  float xx = x * x;
  float numerator = clip * peak * x;
  float denominator_squared = ((xx * (cc - pp)) + (cc * pp));
  return numerator * inversesqrt(denominator_squared);
}

vec3 psycho11_NeutwoPerChannel(vec3 color, vec3 peak) {
  return vec3(
      psycho11_Neutwo(color.r, peak.r),
      psycho11_Neutwo(color.g, peak.g),
      psycho11_Neutwo(color.b, peak.b));
}

vec3 psycho11_NeutwoPerChannel(vec3 color, vec3 peak, vec3 clip) {
  return vec3(
      psycho11_Neutwo(color.r, peak.r, clip.r),
      psycho11_Neutwo(color.g, peak.g, clip.g),
      psycho11_Neutwo(color.b, peak.b, clip.b));
}

vec3 psycho11_NakaRushton(vec3 x, vec3 peak, vec3 gray, float cone_response_exponent) {
  vec3 n = cone_response_exponent * peak / (peak - gray);
  vec3 x_n = psycho11_SignPow(x, n);
  vec3 num = peak * x_n;
  vec3 den = ((pow(gray, n - 1.f) * (peak - gray)) + x_n);
  return num / den;
}

float psycho11_MBYFromLMS(vec3 lms) {
  return PSYCHO11_CIE1702_MB_CIE_WEIGHTS.x * lms.x + PSYCHO11_CIE1702_MB_CIE_WEIGHTS.y * lms.y;
}

vec2 psycho11_MBFromLMS(vec3 lms) {
  float y_mb = psycho11_MBYFromLMS(lms);
  if (y_mb <= 0.f) {
    return vec2(0.f, 0.f);
  }

  return vec2(
      psycho11_DivideSafe(PSYCHO11_CIE1702_MB_CIE_WEIGHTS.x * lms.x, y_mb, 0.f),
      psycho11_DivideSafe(PSYCHO11_CIE1702_MB_CIE_WEIGHTS.z * lms.z, y_mb, 0.f));
}

vec2 psycho11_MBFromBT2020Primary(vec3 primary_rgb) {
  vec3 xyz = (PSYCHO11_BT2020_TO_XYZ_MAT * primary_rgb);
  vec3 lms = (PSYCHO11_XYZ_TO_STOCKMAN_SHARP_LMS_MAT * xyz);
  return psycho11_MBFromLMS(lms);
}

float psycho11_Cross2(vec2 a, vec2 b) {
  return a.x * b.y - a.y * b.x;
}

bool psycho11_RaySegmentHit2D(vec2 origin, vec2 direction, vec2 a, vec2 b, out float t_hit) {
  const float eps = 1e-20f;

  t_hit = 0.f;
  vec2 e = b - a;
  float denom = psycho11_Cross2(direction, e);
  if (abs(denom) <= eps) return false;

  vec2 ao = a - origin;
  float t = psycho11_Cross2(ao, e) / denom;
  float u = psycho11_Cross2(ao, direction) / denom;
  if (t < 0.f || u < 0.f || u > 1.f) return false;

  t_hit = t;
  return true;
}

float psycho11_RayMaxT_BT2020TriangleInMB(vec2 origin, vec2 direction, out bool has_solution) {
  const float interval_max = 1e30f;
  const float mb_near_white_epsilon = 1e-14f;

  has_solution = false;
  if (dot(direction, direction) <= mb_near_white_epsilon) return 0.f;

  vec2 r = psycho11_MBFromBT2020Primary(vec3(1.f, 0.f, 0.f));
  vec2 g = psycho11_MBFromBT2020Primary(vec3(0.f, 1.f, 0.f));
  vec2 b = psycho11_MBFromBT2020Primary(vec3(0.f, 0.f, 1.f));

  float t_best = interval_max;
  float t;
  bool hit_any = false;

  if (psycho11_RaySegmentHit2D(origin, direction, r, g, t)) {
    t_best = min(t_best, t);
    hit_any = true;
  }
  if (psycho11_RaySegmentHit2D(origin, direction, g, b, t)) {
    t_best = min(t_best, t);
    hit_any = true;
  }
  if (psycho11_RaySegmentHit2D(origin, direction, b, r, t)) {
    t_best = min(t_best, t);
    hit_any = true;
  }

  has_solution = hit_any;
  return hit_any ? max(t_best, 0.f) : 0.f;
}

vec3 psycho11_GamutCompressAddWhiteBT2020Bounded(vec3 lms) {
  const float mb_near_white_epsilon = 1e-14f;

  float y_mb = psycho11_MBYFromLMS(abs(lms));
  vec2 white = psycho11_WhiteD65Chromaticity();

  vec2 mb0 = psycho11_MBFromLMS(lms);
  vec2 direction = mb0 - white;
  if (dot(direction, direction) < mb_near_white_epsilon) {
    return lms;
  }

  bool has_solution;
  float t_max = psycho11_RayMaxT_BT2020TriangleInMB(white, direction, has_solution);
  if (!has_solution) {
    return lms;
  }

  float white_ratio = max(psycho11_DivideSafe(1.f - t_max, t_max, 0.f), 0.f);
  float white_add = y_mb * white_ratio;
  vec3 white_unit_lms = psycho11_LMSFromMB2(vec3(white, 1.f));
  return lms + white_unit_lms * white_add;
}

vec3 psycho11_RestoreHueMB2(
    vec3 lms_source_raw_d65,
    vec3 lms_target_raw_d65,
    float amount,
    float eps/*  = 1e-6f */) {
  float restore = clamp(amount, 0, 1);
  if (restore <= 0.f) return lms_target_raw_d65;

  vec3 mb_source = psycho11_MB2FromLMS(lms_source_raw_d65);
  vec3 mb_target = psycho11_MB2FromLMS(lms_target_raw_d65);
  vec2 mb_white = psycho11_WhiteD65Chromaticity();

  vec2 source_offset = mb_source.xy - mb_white;
  vec2 target_offset = mb_target.xy - mb_white;
  float src2 = dot(source_offset, source_offset);
  float tgt2 = dot(target_offset, target_offset);
  if (src2 <= eps || tgt2 <= eps) {
    return lms_target_raw_d65;
  }

  vec2 source_dir = source_offset * inversesqrt(src2);
  vec2 target_dir = target_offset * inversesqrt(tgt2);
  vec2 blended_dir = mix(target_dir, source_dir, restore);
  float blended_len2 = dot(blended_dir, blended_dir);
  if (blended_len2 <= eps) {
    blended_dir = target_dir;
  } else {
    blended_dir *= vec2(inversesqrt(blended_len2));
  }

  float target_radius = sqrt(tgt2);
  vec2 mb_restored_xy = mb_white + blended_dir * target_radius;
  vec3 mb_restored = vec3(mb_restored_xy, mb_target.z);
  return psycho11_LMSFromMB2(mb_restored);
}

vec3 psycho11_ScalePurityMB2(vec3 lms_raw_d65, float purity_scale, float eps/*  = 1e-6f */) {
  float scale = max(purity_scale, 0.f);
  if (abs(scale - 1.f) <= eps) return lms_raw_d65;

  vec3 mb = psycho11_MB2FromLMS(lms_raw_d65);
  vec2 mb_white = psycho11_WhiteD65Chromaticity();
  vec2 mb_offset = mb.xy - mb_white;
  vec2 mb_scaled = mb_white + mb_offset * scale;
  return psycho11_LMSFromMB2(vec3(mb_scaled, mb.z));
}

vec3 psychotm_test11(
    vec3 bt2020_linear_input,
    float peak_value/*  = 1000.f / 203.f */,
    /* float exposure = 1.f, */
    float highlights/*  = 1.f */,
    float shadows/*  = 1.f */,
    float contrast/*  = 1.f */,
    float purity_scale/*  = 1.f */,
    float bleaching_intensity/*  = 0.f */,
    float clip_point/*  = 100.f */,
    float hue_restore/*  = 1.f */,
    float adaptation_contrast/*  = 1.f */,
    int white_curve_mode/*  = 0 */,
    float cone_response_exponent/*  = 1.f */) {

  const float kEps = 1e-6f;
  const float kHalfBleachTrolands = 20000.f;
  const int kWhiteCurveNeutwo = 0;
  const int kWhiteCurveNakaRushton = 1;
  /* const */ vec3 lms_midgray_raw = psycho11_LMSFromBT2020(vec3(0.18f));
  /* const */ float lum_midgray = psycho11_StockmanLuminanceFromLMS(vec3(lms_midgray_raw));

  vec3 bt2020 = bt2020_linear_input/* psycho11_BT2020FromBT709(bt709_linear_input * exposure) */;
  vec3 lms_color_raw = psycho11_LMSFromBT2020(bt2020);
  lms_color_raw = psycho11_GamutCompressAddWhiteBT2020Bounded(lms_color_raw);

  float lum_current = psycho11_StockmanLuminanceFromLMS(lms_color_raw);
  float lum_target = lum_current;

  if (highlights != 1.f) {
    lum_target = psycho11_Highlights(lum_target, highlights, lum_midgray);
  }
  if (shadows != 1.f) {
    lum_target = psycho11_Shadows(lum_target, shadows, lum_midgray);
  }
  if (contrast != 1.f) {
    lum_target = psycho11_ContrastSafe(lum_target, contrast, lum_midgray);
  }

  float lum_scale = psycho11_DivideSafe(lum_target, lum_current, 1.f);
  clip_point *= lum_scale;

  vec3 lms_scene_unit = lms_color_raw * lum_scale;
  vec3 lms_midgray_unit = lms_midgray_raw;

  if (purity_scale != 1.f) {
    lms_scene_unit = psycho11_ScalePurityMB2(lms_scene_unit, purity_scale, kEps);
  }

  vec3 lms_scene_unit_source = lms_scene_unit;
  if (adaptation_contrast != 1.f) {
    vec3 lms_sigma_unit = max(lms_midgray_unit, kEps);
    float exponent = max(adaptation_contrast, kEps);

    vec3 ax = abs(lms_scene_unit);
    vec3 ax_n = pow(ax, vec3(exponent));
    vec3 s_n = pow(lms_sigma_unit, vec3(exponent));
    vec3 response_target = ax_n / max(ax_n + s_n, kEps);
    vec3 response_baseline = ax / max(ax + lms_sigma_unit, kEps);
    vec3 gain = response_target / max(response_baseline, kEps);
    vec3 sign_raw = vec3(
        lms_scene_unit.x < 0.f ? -1.f : 1.f,
        lms_scene_unit.y < 0.f ? -1.f : 1.f,
        lms_scene_unit.z < 0.f ? -1.f : 1.f);
    lms_scene_unit = sign_raw * (ax * gain);

    if (hue_restore > 0.f) {
      lms_scene_unit = psycho11_RestoreHueMB2(
          lms_scene_unit_source,
          lms_scene_unit,
          hue_restore,
          kEps);
    }
  }

  vec3 lms_unit = lms_scene_unit;
  if (bleaching_intensity != 0.f) {
    float blend_weight = clamp(bleaching_intensity, 0, 1);

    float adapted_lum = max(
        psycho11_StockmanLuminanceFromLMS(max(lms_unit, 0.f)),
        0.18f);
    vec3 adapted_bt2020 = vec3(adapted_lum);
    vec3 lms_adapted_unit = psycho11_LMSFromBT2020(adapted_bt2020);
    vec3 lms_signal_unit = lms_unit;

    vec3 stimulus_nits = max(lms_adapted_unit, 0.f) * 100.f;
    vec3 stimulus_trolands = stimulus_nits * 4.f;
    vec3 availability_raw = 1.f / (1.f + stimulus_trolands / max(kHalfBleachTrolands, kEps));
    vec3 availability = mix(vec3(1), availability_raw, vec3(blend_weight));
    lms_unit = lms_signal_unit * max(availability, 0.f);
  }

  vec3 lms_peak_unit = psycho11_LMSFromBT2020(vec3(peak_value));
  vec3 lms_toned_unit;
  if (white_curve_mode == kWhiteCurveNakaRushton) {
    lms_toned_unit = psycho11_NakaRushton(
        lms_unit,
        lms_peak_unit,
        lms_midgray_unit,
        cone_response_exponent);
  } else if (white_curve_mode == kWhiteCurveNeutwo && clip_point > peak_value) {
    vec3 lms_clip_unit = psycho11_LMSFromBT2020(vec3(clip_point));
    lms_toned_unit = psycho11_NeutwoPerChannel(lms_unit, lms_peak_unit, lms_clip_unit);
  } else {
    lms_toned_unit = psycho11_NeutwoPerChannel(lms_unit, lms_peak_unit);
  }

  if (hue_restore > 0.f) {
    lms_toned_unit = psycho11_RestoreHueMB2(
        lms_unit,
        lms_toned_unit,
        hue_restore,
        kEps);
  }

  lms_toned_unit = psycho11_GamutCompressAddWhiteBT2020Bounded(lms_toned_unit);
  vec3 bt2020_toned = psycho11_BT2020FromLMS(lms_toned_unit);
  return /* psycho11_BT709FromBT2020 */(bt2020_toned);
}

