#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

[[ stitchable ]] half4 eventDetailProgressiveBlur(
    float2 position,
    SwiftUI::Layer layer,
    float4 bounds,
    float2 direction,
    float transitionHeight,
    float maximumRadius
) {
    float start = bounds.y + bounds.w - transitionHeight;
    float progress = smoothstep(0.0, 1.0, (position.y - start) / max(transitionHeight, 1.0));
    float radius = maximumRadius * progress;
    if (radius < 0.01) {
        return layer.sample(position);
    }

    float4 color = 0;
    float weightSum = 0;
    for (int index = -6; index <= 6; index++) {
        float distance = float(index) / 6.0;
        float weight = exp(-4.5 * distance * distance);
        float2 samplePosition = clamp(
            position + direction * (distance * radius),
            bounds.xy + 0.5,
            bounds.xy + bounds.zw - 0.5
        );
        color += float4(layer.sample(samplePosition)) * weight;
        weightSum += weight;
    }
    return half4(color / weightSum);
}
