import 'package:flutter/material.dart';
import 'package:towerrogue/game/components/core/i18n.dart';
import 'package:towerrogue/game/components/core/pallete.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(const AssetImage('assets/images/sprites/mainMenu.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/hud/setaEsq.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/hud/setaDir.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/chars/arqueiro.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/chars/bomberman.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/chars/char.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/chars/cowboy.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/chars/defensor.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/chars/exterminador.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/chars/guerreiro.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/chars/licantropo.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/chars/multidao.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/chars/ninja.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/chars/piromante.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/chars/samuela.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/gameObjs/lock.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/flags/en.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/flags/pt.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/flags/es.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/flags/fr.png'), context);

    // --- INIMIGOS ---
    precacheImage(const AssetImage('assets/images/sprites/inimigos/agiota.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/anemona.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/bat.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/bee.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/beehive.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/besta.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/bird.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/bishop.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/bug.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/coffin.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/cultista.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/cyborg.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/deepone.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/dolphin.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/drone.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/dullahan.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/dummy.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/elder.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/elephant.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/fish.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/ghost.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/goblin.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/headless.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/jellyfish.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/king.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/knight.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/mare.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/mecha.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/megalodon.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/mushroom.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/olho.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/olhoBoss.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/orc.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/orcBerserk.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/orcChief.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/orcDefensor.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/orcShaman.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/pawn.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/queen.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/rabbit.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/rastejante.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/rat.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/ratKing.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/rook.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/shark.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/slime.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/slimeP.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/snail.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/snake.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/spider.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/starspawn.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/tank.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/tank2.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/tortoise.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/trueQueen.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/turret1.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/turret2.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/turtle.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/unicorn.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/warg.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/inimigos/worm.png'), context);

    // --- ITENS ---
    precacheImage(const AssetImage('assets/images/sprites/itens/adagaRitual.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/alqBrutal.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/antimateria.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/aquarius.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/aries.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/asa.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bandage.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bateria.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bloodBag.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bloquel.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bltBuracoNegro.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bltRastroFogo.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bolaCorrente.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bomba.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bombaBuracoNegro.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bombaConfusao.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bombaDecoy.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bombaDiarreia.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bombaGlitter.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bombardeio.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bombaVeneno.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bombsAreKeys.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/book.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/boss.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bota.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bounceShot.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/bumerangue.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/buracoNegro.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/cabecaUnicornio.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/cafe.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/caixa.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/cajado.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/cajadoQuebrado.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/cancer.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/capa.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/capricorn.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/cardinal.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/cash.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/cat.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/caveira.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/certificado.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/charm.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/cinturao.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/circuloProt.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/cogumelo.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/coin.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/coins.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/colar.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/confuseShot.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/console.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/coroa.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/cupon.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/d10.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/d20.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/d6.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/dash.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/decoy.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/dedo.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/detonador.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/devil.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/dummy.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/duplicado.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/encolhe.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/escada.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/escudo.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/escudoDivino.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/escudoExplode.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/escudoOrbital.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/escudoRegen.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/espelho.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/espelho2.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/espirito.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/faca.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/fada.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/fantasma.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/flail.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/fogo.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/fogoRastro.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/foice.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/fragmento.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/furia.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/gameboy.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/gemini.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/glifo.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/hpCheio.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/hpMeio.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/hpVazio.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/jarroCoracao.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/jarroFada.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/jumperCable.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/key.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/lamina.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/lanca.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/laser.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/leo.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/libra.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/licantropo.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/loja.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/machado.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/machadoArremeco.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/mao.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/masterOrb.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/mina.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/molhoChaves.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/molotov.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/neve.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/noItem.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/nuke.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/nuke2.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/olho.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/onda.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/patins.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/pet.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/piercing.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/pilha.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/pill.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/pisces.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/pocaVeneno.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/portal.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/potCura.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/potion.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/prego.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/presente.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/prisma.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/r.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/raio.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/raiva.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/restock.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/retribuicao.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/sacoBomba.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/sacoMoedas.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/sagittarius.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/sanduiche.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/sangue.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/satelite.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/saw.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/scorpio.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/scroll.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/seringa.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/slot.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/soda.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/sonicBoom.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/soul.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/spectralShot.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/taurus.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/telecinese.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/tiroOrbital.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/tornado.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/tripleShot.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/turret.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/turret2.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/vampirismo.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/veneno.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/vinho.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/virgo.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/wisp.png'), context);
    precacheImage(const AssetImage('assets/images/sprites/itens/zodiac.png'), context);

    
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Pallete.preto, 
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            const CircularProgressIndicator(
              color: Pallete.branco, 
            ),
            const SizedBox(height: 24),
            Text(
              "loading".tr(),
              style:const TextStyle(
                fontFamily: 'pixelFont', 
                color: Pallete.branco,
                fontSize: 24,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}