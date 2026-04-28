import 'dart:io';

void main() {
  // 1. Aponte para a pasta raiz das suas imagens
  // (Você pode mudar para 'assets/images/sprites/inimigos' se quiser uma pasta específica)
  final diretorio = Directory('assets/images');

  if (!diretorio.existsSync()) {
    print('Pasta não encontrada! Verifique o caminho.');
    return;
  }

  // 2. Lê todos os arquivos da pasta (o recursive: true faz ele entrar nas subpastas!)
  final arquivos = diretorio.listSync(recursive: true);

  print('// COPIE O CÓDIGO ABAIXO PARA O SEU OPLOAD:\n');

  for (var entidade in arquivos) {
    // 3. Filtra para pegar apenas arquivos que sejam imagens .png
    if (entidade is File && entidade.path.endsWith('.png')) {
      
      // 4. Limpa o caminho para o padrão que o Flame exige
      String caminhoFlame = entidade.path
          .replaceAll('\\', '/') // Resolve o problema de barras invertidas do Windows
          .replaceFirst('assets/images/', ''); // Remove a parte inútil do caminho

      // 5. Imprime o código já formatado para a lista do Dart
      print("  '$caminhoFlame',");
    }
  }
  
  print('\n// FIM DOS ASSETS');
}