#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution; // O tamanho da tela
uniform sampler2D uTexture; // A imagem do jogo

// O Flutter exige essa variável de saída para "pintar" o pixel na tela
out vec4 fragColor; 

const float curvature = 3.5;
const float vignetteWidth = 30.0;
const float scanlineWidth = 2.0;
const float scanlineIntensity = 0.05;
const float chromaticAberration = 0.003;

vec2 curve(vec2 uv) {
    uv = (uv - 0.5) * 2.0;
    uv *= 1.1;
    uv.x *= 1.0 + pow((abs(uv.y) / curvature), 2.0);
    uv.y *= 1.0 + pow((abs(uv.x) / curvature), 2.0);
    uv = (uv / 2.0) + 0.5;
    uv = uv * 0.92 + 0.04;
    return uv;
}

// O Flutter sempre procura pela função "main"
void main() {
    // Pega a coordenada exata do pixel usando a função nativa do Flutter
    vec2 fragCoord = FlutterFragCoord().xy;
    
    // Normaliza a coordenada para ficar entre 0.0 e 1.0
    vec2 uv = fragCoord / uResolution;
    
    // Aplica a curva da TV de tubo
    vec2 curvedUV = curve(uv);

    // Se o pixel sair da tela por causa da curva, pinta de preto
    if (curvedUV.x < 0.0 || curvedUV.x > 1.0 || curvedUV.y < 0.0 || curvedUV.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // Separa os canais RGB para fazer o efeito 3D retro (Aberração Cromática)
    float r = texture(uTexture, vec2(curvedUV.x + chromaticAberration, curvedUV.y)).r;
    float g = texture(uTexture, vec2(curvedUV.x, curvedUV.y)).g;
    float b = texture(uTexture, vec2(curvedUV.x - chromaticAberration, curvedUV.y)).b;

    vec3 color = vec3(r, g, b);

    // Desenha as linhas horizontais
    float scanline = sin(curvedUV.y * uResolution.y * scanlineWidth) * 0.5 + 0.5;
    color *= 1.0 - (scanline * scanlineIntensity);

    // Escurece os cantos (Vignette)
    float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
    color *= pow(16.0 * vignette, vignetteWidth / 100.0);

    // Entrega a cor final para o Flutter desenhar
    fragColor = vec4(color, 1.0);
}