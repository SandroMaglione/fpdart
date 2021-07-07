import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pokeapi_functional/controllers/pokemon_provider.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final eitherPokemon = ref.watch(pokemonProvider);
    useEffect(() {
      /// Fetch the initial pokemon information
      ref.read(pokemonProvider.notifier).init(1);
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
              onPressed: () =>
                  ref.read(pokemonProvider.notifier).fetch(controller.text),
              child: Text('Get my pokemon!'),
            ),

            /// Display either the [Pokemon] or the error [String]
            eitherPokemon.match(
              /// When either is [Left], display error message 💥
              (l) => Text(l),

              /// When either is [Right], display pokemon 🤩
              (r) => Card(
                child: Column(
                  children: [
                    Image.network(r.sprites.front_default),
                    Text(r.name),
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
