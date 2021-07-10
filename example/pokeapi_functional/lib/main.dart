import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
    final requestStatus = ref.watch(pokemonProvider);
    useEffect(() {
      /// Fetch the initial pokemon information (random pokemon).
      Future.delayed(Duration.zero, () {
        ref.read(pokemonProvider.notifier).fetchRandom();
      });
    }, []);

    return MaterialApp(
      title: 'Fpdart PokeAPI',
      home: Scaffold(
        body: Column(
          children: [
            /// [TextField] and [ElevatedButton] to input pokemon id to fetch
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Insert pokemon id number',
              ),
            ),
            ElevatedButton(
              onPressed: () => ref
                  .read(
                    pokemonProvider.notifier,
                  )
                  .fetch(
                    controller.text,
                  ),
              child: Text('Get my pokemon!'),
            ),

            /// Map each [RequestStatus] to a different UI
            requestStatus.when(
              initial: () => Center(
                child: Column(
                  children: [
                    Text('Loading intial pokemon'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
              loading: () => Center(
                child: CircularProgressIndicator(),
              ),

              /// When either is [Left], display error message 💥
              error: (error) => Text(error),

              /// When either is [Right], display pokemon 🤩
              success: (pokemon) => Card(
                child: Column(
                  children: [
                    Image.network(
                      pokemon.sprites.front_default,
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
