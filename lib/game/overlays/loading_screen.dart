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