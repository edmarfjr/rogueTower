#include <flutter/runtime_effect.glsl>

uniform float uTime;
uniform vec2 uResolution;
uniform sampler2D uTexture;

out vec4 fragColor;

const float curvature = 4.0; 
const float vignetteWidth = 30.0;
const float scanlineWidth = 2.0;
const float scanlineIntensity = 0.05;
const float chromaticAberration = 0.001;
const float scanlineSpeed = 0.15;

vec2 curve(vec2 uv) {
    uv = (uv - 0.5) * 2.0;
    uv.x *= 1.0 + pow((abs(uv.y) / curvature), 2.0);
    uv.y *= 1.0 + pow((abs(uv.x) / curvature), 2.0);
    uv = (uv / 2.0) + 0.5;
    
    // ---> O ZOOM CORRETO <---
    // Multiplicar por 0.92 (menor que 1) encolhe a imagem, 
    // revelando as partes da direita e do fundo que estavam cortadas!
    uv = (uv - 0.5) * 0.92 + 0.5;
    
    return uv;
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uResolution;

    vec2 curvedUV = curve(uv);

    // Carcaça de plástico preta da TV
    if (curvedUV.x < 0.0 || curvedUV.x > 1.0 || curvedUV.y < 0.0 || curvedUV.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    float r = texture(uTexture, curvedUV + vec2(chromaticAberration, 0.0)).r;
    float g = texture(uTexture, curvedUV).g;
    float b = texture(uTexture, curvedUV - vec2(chromaticAberration, 0.0)).b;

    vec3 color = vec3(r, g, b);

    // Animação das linhas
    float scanline = sin((curvedUV.y - uTime * scanlineSpeed) * uResolution.y * scanlineWidth) * 0.5 + 0.5;
    color *= 1.0 - (scanline * scanlineIntensity);

    // Escurecimento dos cantos
    float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
    color *= pow(16.0 * vignette, vignetteWidth / 100.0);

    fragColor = vec4(color, 1.0);
}