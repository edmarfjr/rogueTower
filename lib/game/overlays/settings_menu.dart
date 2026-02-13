import 'package:flutter/material.dart';
import '../tower_game.dart';
import '../components/core/pallete.dart';
import '../components/core/i18n.dart'; // Importe a classe I18n

class SettingsMenu extends StatelessWidget {
  final TowerGame game;

  const SettingsMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Escutamos a mudança de idioma para a tela se auto-traduzir na mesma hora!
    return ValueListenableBuilder<String>(
      valueListenable: game.progress.languageNotifier,
      builder: (context, currentLang, child) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.7),
          body: Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Pallete.azulEsc,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Pallete.branco, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'settings'.tr(), // Título Traduzido
                    style: const TextStyle(
                      fontSize: 28,
                      color: Pallete.branco,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- SEÇÃO DE IDIOMA ---
                  Text(
                    'language'.tr(),
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 15),
                  
                  // Botões de Idioma
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _langButton('pt', '🇧🇷 PT', currentLang),
                      _langButton('en', '🇺🇸 EN', currentLang),
                      _langButton('es', '🇪🇸 ES', currentLang),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Botão Fechar
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Pallete.vermelho,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      game.overlays.remove('SettingsMenu');
                    },
                    child: Text('close'.tr(), style: const TextStyle(fontSize: 18, color: Pallete.branco)),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  // Método auxiliar para criar os botões de idioma com destaque para o selecionado
  Widget _langButton(String langCode, String label, String currentLang) {
    bool isSelected = currentLang == langCode;
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Pallete.verdeCla : Pallete.cinzaEsc,
        side: isSelected ? const BorderSide(color: Pallete.branco, width: 2) : BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      onPressed: () {
        // Chama a função que criamos no Passo 1!
        game.progress.changeLanguage(langCode);
      },
      child: Text(
        label, 
        style: TextStyle(fontSize: 16, color: isSelected ? Pallete.branco: Pallete.cinzaCla)
      ),
    );
  }
}