import 'package:flutter/material.dart';
import '../tower_game.dart';

class BankMenu extends StatelessWidget {
  final TowerGame game;

  const BankMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E50), // Um cinza azulado
            border: Border.all(color: Colors.amber, width: 4),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance, size: 50, color: Colors.amber),
              const SizedBox(height: 10),
              const Text(
                "BANCO",
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5),
              ),
              const Divider(color: Colors.white24, height: 30),

              // --- MOSTRADORES DE SALDO ---
              _buildBalanceRow("Na Carteira", game.coinsNotifier, Colors.white),
              _buildBalanceRow("No Cofre", game.progress.bankNotifier, Colors.amberAccent),
              
              // NOVO: Mostrador de Dívida (Fica Vermelho para assustar!)
              _buildBalanceRow("Dívida Ativa", game.dividaNotifier, Colors.redAccent),

              const Divider(color: Colors.white24, height: 30),

              // --- AÇÕES NORMAIS DO BANCO ---
              _buildActionSection("DEPOSITAR (Guardar)", Colors.blue, (amount) {
                if (amount == -1) {
                  game.depositCoins(game.coinsNotifier.value);
                } else {
                  game.depositCoins(amount);
                }
              }),

              const SizedBox(height: 15),

              _buildActionSection("SACAR (Retirar)", Colors.green, (amount) {
                if (amount == -1) {
                  game.withdrawCoins(game.progress.bankBalance); 
                } else {
                  game.withdrawCoins(amount);
                }
              }),

              const Divider(color: Colors.white24, height: 30),

              // --- AGIOTA / EMPRÉSTIMO ---
              ValueListenableBuilder<int>(
                valueListenable: game.dividaNotifier,
                builder: (context, divida, child) {
                  // SE NÃO TEM DÍVIDA: Oferece o empréstimo
                  if (divida == 0) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          // Pega 50, fica a dever 75 (50% de juros)
                          game.coinsNotifier.value += 50;
                          game.dividaNotifier.value += 75;
                        },
                        child: const Text("PEGAR EMPRÉSTIMO (+50G)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    );
                  } 
                  
                  // SE TEM DÍVIDA: Obriga a pagar (Desativa o botão se não tiver dinheiro)
                  else {
                    return ValueListenableBuilder<int>(
                      valueListenable: game.coinsNotifier,
                      builder: (context, moedasAtuais, child) {
                        bool conseguePagar = moedasAtuais >= divida;

                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: conseguePagar ? Colors.orange : Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: conseguePagar 
                              ? () {
                                  // Quita a dívida!
                                  game.coinsNotifier.value -= divida;
                                  game.dividaNotifier.value = 0;
                                }
                              : null, // Desativa o botão se for pobre
                            child: Text(
                              conseguePagar ? "PAGAR DÍVIDA (-${divida}G)" : "FALTAM MOEDAS PARA PAGAR!", 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                            ),
                          ),
                        );
                      }
                    );
                  }
                },
              ),

              const SizedBox(height: 15),

              // Botão Sair
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    game.overlays.remove('bank_menu');
                    game.resumeEngine();
                  },
                  child: const Text("SAIR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceRow(String label, ValueNotifier<int> notifier, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          ValueListenableBuilder<int>(
            valueListenable: notifier,
            builder: (ctx, value, _) {
              return Text(
                "$value G",
                style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.bold),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(String title, Color color, Function(int) onAction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _btn("1", color, () => onAction(1)),
            _btn("10", color, () => onAction(10)),
            _btn("100", color, () => onAction(100)),
            _btn("TUDO", color, () => onAction(-1)),
          ],
        ),
      ],
    );
  }

  Widget _btn(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(50, 30),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white)),
    );
  }
}