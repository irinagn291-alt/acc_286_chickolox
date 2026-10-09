#include <metal_stdlib>
using namespace metal;

/// Stepped fan sheen for the active quadrant. Colour comes from DesignTokens.
[[ stitchable ]] half4 fanSheen(float2 position, half4 color, float2 size, float3 accent) {
    float2 safe = max(size, float2(1.0));
    float2 uv = position / safe;
    float band = floor(uv.x * 7.0 + uv.y * 2.0);
    float edge = abs(fract(uv.y * 6.0 + band * 0.13) - 0.5);
    float sheen = step(0.38, edge) * 0.28;
    half3 tint = half3(accent);
    half3 mixed = mix(color.rgb, tint, half(sheen));
    return half4(mixed, color.a);
}
