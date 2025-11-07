import 'package:compaexpress/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSwitch extends ConsumerWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return ElevatedButton(
      onPressed: () {
        ref.read(themeModeProvider.notifier).state =
            themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      },
      child: const Text("Cambiar Tema"),
    );
  }
}
