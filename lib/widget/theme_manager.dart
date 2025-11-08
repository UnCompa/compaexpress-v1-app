import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compaexpress/providers/theme_provider.dart';
import 'package:compaexpress/widget/color_selector.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ThemeManager extends ConsumerWidget {
  const ThemeManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePrefs = ref.watch(themeProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: _colorCard(context, ref)),
                    const SizedBox(width: 20),
                    Expanded(flex: 1, child: _themeAndPreview(context, ref)),
                  ],
                )
              : Column(
                  children: [
                    _colorCard(context, ref),
                    const SizedBox(height: 20),
                    _themeAndPreview(context, ref),
                  ],
                ),
        );
      },
    );
  }

  Widget _colorCard(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Color principal',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const ColorSelector(),
          ],
        ),
      ),
    );
  }

  Widget _themeAndPreview(BuildContext context, WidgetRef ref) {
    final themePrefs = ref.watch(themeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tema', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode),
                      label: Text('Claro'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode),
                      label: Text('Oscuro'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto),
                      label: Text('Sistema'),
                    ),
                  ],
                  selected: {themePrefs.themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    ref
                        .read(themeProvider.notifier)
                        .setThemeMode(newSelection.first);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vista previa',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.palette),
                      label: const Text('Ejemplo'),
                    ),
                    FilledButton(
                      onPressed: () {},
                      child: const Text('Relleno'),
                    ),
                    TextButton(onPressed: () {}, child: const Text('Texto')),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: 0.5,
                  onChanged: (double value) {},
                  label: 'Ejemplo de Slider',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Modo Pro'),
                    const Spacer(),
                    Switch(value: true, onChanged: (bool value) {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
