#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;

out vec4 fragColor;

// Distorção de Barril (Abaulamento da Tela)
vec2 curveRemapUV(vec2 uv) {
    uv = uv * 2.0 - 1.0;
    // O fator de curvatura (Aumente para 5.0 se achar que está muito curvado)
    vec2 offset = abs(uv.yx) / vec2(4.0, 4.0);
    uv = uv + uv * offset * offset;
    uv = uv * 0.5 + 0.5;
    return uv;
}

void main() {
    vec2 coord = FlutterFragCoord().xy;
    vec2 baseUV = coord / uResolution;
    
    // 1. Aplica a curvatura do vidro
    vec2 uv = curveRemapUV(baseUV);

    // 2. MOLDURA ARREDONDADA (Correção da quina!)
    // Transformamos o UV para o centro (-1 a 1) para calcular a distância
    vec2 cUv = uv * 2.0 - 1.0;
    
    // A matemática da Superelipse (Cria o retângulo com cantos curvos perfeitos)
    // Se quiser o canto mais redondo, diminua de 8.0 para 6.0
    float corner = pow(abs(cUv.x), 8.0) + pow(abs(cUv.y), 8.0);
    
    // Smoothstep cria o degradê da borda preta (0.8 começa a escurecer, 1.2 é preto absoluto)
    float moldura = smoothstep(0.8, 1.2, corner); 

    // Cria uma linha imaginária que desce a tela
    float rollPhase = uv.y * 5.0 - uTime * 2.5;
    // O smoothstep garante que seja apenas uma faixa bem fina e afiada
    float waveTear = smoothstep(0.98, 1.0, sin(rollPhase));
    
    // A onda não fica na tela o tempo todo. Ela aparece de tempos em tempos.
    // Alterar o 0.3 para um número menor faz ela demorar mais para aparecer.
    float occasional = smoothstep(0.8, 1.0, sin(uTime * 0.3));
    
    // Entorta as coordenadas do eixo X na área da onda!
    // Aumentar o 0.03 faz o "puxão" para o lado ser mais violento.
    uv.x += waveTear * occasional * 0.03;

    // 3. SCANLINES (Linhas horizontais)
    // Calcula as listras com base na altura da resolução
    float scanline = sin(uv.y * 3.14159 * (uResolution.y * 0.2));
    float scanlineAlpha = (scanline * 0.5 + 0.5) * 0.10;

    // 4. MATRIZ DE PIXELS (Aperture Grille / Shadow Mask)
    // Usamos as coordenadas puras da tela para desenhar uma grade microscópica
    float matrixX = sin(coord.x * 3.14159 * 0.5); // Frequência vertical
    float matrixY = sin(coord.y * 3.14159 * 0.5); // Frequência horizontal
    
    // Onde o cruzamento é negativo, nós escurecemos (cria o buraco entre os fósforos)
    float pixelMatrixAlpha = (1.0 - (matrixX * matrixY)) * 0.08;

    // 5. VIGNETTE (Sombra profunda dos tubos)
    float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
    vignette = clamp(pow(16.0 * vignette, 0.25), 0.0, 1.0);
    float vignetteAlpha = (1.0 - vignette) * 0.4;

    // 6. FLICKER (A oscilação de energia da TV)
    float flicker = sin(uTime * 15.0) * 0.02;

    // COMBINANDO OS EFEITOS
    // Somamos as linhas, a grade de pixels, a sombra e o piscar
    float finalAlpha = scanlineAlpha + pixelMatrixAlpha + vignetteAlpha + flicker;
    
    // Aplicamos a moldura preta por cima de tudo
    // A função mix transiciona do nosso alpha atual para 1.0 (Preto Total) nos cantos
    finalAlpha = mix(finalAlpha, 1.0, moldura);

    finalAlpha -= waveTear * occasional * 0.15;

    // Trava de segurança gráfica (evita artefatos bizarros de cor)
    finalAlpha = clamp(finalAlpha, 0.0, 1.0);

    // O shader desenha PRETO, e o Alpha faz a máscara!
    fragColor = vec4(0.1137, 0.1686, 0.3255, finalAlpha);
}