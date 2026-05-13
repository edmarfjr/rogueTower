import 'dart:io';
import 'package:flutter/foundation.dart'; // <-- Traz a constante kIsWeb
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static RewardedAd? _rewardedAd;
  static int _numRewardedLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  static String get rewardedAdUnitId {
    if (kIsWeb) return ''; // Retorna vazio na Web para não quebrar
    
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    throw UnsupportedError('Plataforma não suportada');
  }

  static void loadRewardedAd() {
    // Aborta imediatamente se estiver no navegador
    if (kIsWeb) {
      //print('🌐 Web detectada: Ignorando carregamento de anúncios.');
      return; 
    }

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          //print('✅ Anúncio Premiado carregado!');
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          //print('❌ Falha ao carregar anúncio premiado: $error');
          _rewardedAd = null;
          _numRewardedLoadAttempts += 1;
          if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
            loadRewardedAd(); 
          }
        },
      ),
    );
  }

  static void showRewardedAd({
    required Function() onRewardEarned, 
    Function()? onAdClosedUnrewarded, // Adicionado para lidar com quem pula o anúncio
  }) {
    // Se for Web, simula que o cara assistiu o vídeo para você conseguir testar o jogo!
    if (kIsWeb) {
      //print('🎉 Simulando anúncio assistido na Web. Entregando recompensa livre!');
      onRewardEarned();
      return;
    }

    if (_rewardedAd == null) {
      //print('⚠️ Aviso: Tentou mostrar anúncio, mas não estava carregado ainda.');
      // Como não tem anúncio, tratamos como se ele não tivesse ganhado a recompensa
      if (onAdClosedUnrewarded != null) onAdClosedUnrewarded();
      return;
    }

    // A NOSSA VARIÁVEL DE CONTROLE!
    bool ganhouRecompensa = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) => print('Anúncio em tela cheia abriu.'),
      
      // O JOGADOR APERTOU NO 'X' PARA FECHAR O ANÚNCIO:
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        //print('Anúncio fechado pelo jogador.');
        ad.dispose();
        loadRewardedAd(); 
        
        // AGORA SIM nós checamos a variável e despausamos/revivemos o jogo!
        if (ganhouRecompensa) {
          onRewardEarned();
        } else {
          // O jogador pulou o vídeo no meio e fechou. Não ganha nada!
          if (onAdClosedUnrewarded != null) onAdClosedUnrewarded();
        }
      },
      
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
       // print('Falha ao mostrar o anúncio em tela cheia: $error');
        ad.dispose();
        loadRewardedAd();
        if (onAdClosedUnrewarded != null) onAdClosedUnrewarded();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        //print('🎉 O Jogador assistiu tudo! Marcando a variável...');
        // O VÍDEO ACABOU. Marcamos a variável, mas não mexemos no jogo ainda!
        ganhouRecompensa = true; 
      },
    );
    _rewardedAd = null; 
  }
}