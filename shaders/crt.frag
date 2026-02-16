#include <flutter/runtime_effect.glsl>

// uniform float uTime; // Comentado por enquanto (veja o aviso abaixo)
uniform vec2 uResolution;
uniform sampler2D uTexture; // O Flutter exige declarar a textura explicitamente

out vec4 fragColor; // Saída obrigatória do Impeller

void main() {
    // Pega a coordenada nativa do Flutter e normaliza (0..1)
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uResolution;

    // Curvatura da tela
    vec2 curve = uv * 2.0 - 1.0;
    curve *= 1.1;
    uv = curve * 0.5 + 0.5;

    // Fora da tela
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // Aberração cromática
    float offset = 0.003;
    float r = texture(uTexture, uv + vec2(offset, 0.0)).r;
    float g = texture(uTexture, uv).g;
    float b = texture(uTexture, uv - vec2(offset, 0.0)).b;

    vec3 color = vec3(r, g, b);

    // Scanlines
    float scan = sin(uv.y * uResolution.y * 1.5);
    color *= 0.9 + 0.1 * scan;

    // Vignette
    float dist = distance(uv, vec2(0.5, 0.5));
    color *= smoothstep(0.8, 0.4, dist);

    fragColor = vec4(color, 1.0);
}