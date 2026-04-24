#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;

out vec4 fragColor;

void main() {
    vec2 coord = FlutterFragCoord().xy;
    
    // 1. TELA PLANA (Sem a função curveRemapUV)
    vec2 uv = coord / uResolution;

    // --- EFEITO DE ONDA DE DISTORÇÃO (ROLL/TRACKING) ---
    // Cria uma linha imaginária que desce a tela
    float rollPhase = uv.y * 5.0 - uTime * 2.5;
    float waveTear = smoothstep(0.98, 1.0, sin(rollPhase));
    
    // A onda aparece de tempos em tempos
    float occasional = smoothstep(0.8, 1.0, sin(uTime * 0.3));
    
    // Entorta as coordenadas do eixo X na área da onda
    uv.x += waveTear * occasional * 0.03; 

    // 2. SCANLINES (Linhas horizontais)
    float scanline = sin(uv.y * 3.14159 * (uResolution.y * 0.4));
    float scanlineAlpha = (scanline * 0.5 + 0.5) * 0.20;

    // 3. MATRIZ DE PIXELS (AUMENTADA)
    //float matrixX = sin(coord.x * 3.14159 * 0.6); 
    //float matrixY = sin(coord.y * 3.14159 * 0.6); 
    //float pixelMatrixAlpha = (1.0 - (matrixX * matrixY)) * 0.08;

    // 4. VIGNETTE (Sombra profunda dos cantos)
    float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
    vignette = clamp(pow(16.0 * vignette, 0.25), 0.0, 1.0);
    float vignetteAlpha = (1.0 - vignette) * 0.4;

    // 5. FLICKER (A oscilação de energia da TV)
    float flicker = sin(uTime * 15.0) * 0.02;

    // COMBINANDO OS EFEITOS
    float finalAlpha = scanlineAlpha /*+ pixelMatrixAlpha*/ + vignetteAlpha + flicker;

    // Detalhe extra: Quando a onda de distorção passa, ela "clareia" a tela
    finalAlpha -= waveTear * occasional * 0.15;

    // Trava de segurança gráfica
    finalAlpha = clamp(finalAlpha, 0.0, 1.0);

    // O shader desenha PRETO, e o Alpha faz a máscara!
    fragColor = vec4(0.0, 0.0, 0.0, finalAlpha);
}