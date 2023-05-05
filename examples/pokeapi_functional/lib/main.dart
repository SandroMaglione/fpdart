import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useTextEditingController;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pokeapi_functional/controllers/pokemon_provider.dart';

void main() {
  /// [ProviderScope] required for riverpod state management
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// [TextEditingController] using hooks
    final controller = useTextEditingController();
    final requestStatus = ref.watch(pokemonStateProvider);
    final pokemonNotifier = ref.watch(pokemonStateProvider.notifier);

    return MaterialApp(
      title: 'Fpdart PokeAPI',
      home: Scaffold(
        body: Column(
          children: [
            /// [TextField] and [ElevatedButton] to input pokemon id to fetch
            TextField(
              textInputAction: TextInputAction.next,
              textAlign: TextAlign.center,
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Insert pokemon id number',
              ),
            ),
            ElevatedButton(
              onPressed: () => pokemonNotifier.fetch(controller.text),
              child: Text('Get my pokemon!'),
            ),

            /// Map each [AsyncValue] to a different UI
            requestStatus.when(
              loading: () => Center(child: CircularProgressIndicator()),

              /// When either is [Left], display error message 💥
              error: (error, stackTrace) => Text(error.toString()),

              /// When either is [Right], display pokemon 🤩
              data: (pokemon) => Card(
                child: Column(
                  children: [
                    Image.network(
                      pokemon.sprites.frontDefault,
                      width: 200,
                      height: 200,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 24,
                      ),
                      child: Text(
                        pokemon.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
