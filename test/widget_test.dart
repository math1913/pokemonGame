import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/main.dart';

void main() {
  testWidgets('Muestra la pantalla de inicio', (tester) async {
    await tester.pumpWidget(const PokemonBattleApp());
    await tester.pumpAndSettle();

    expect(find.text('POKEMON'), findsOneWidget);
    expect(find.text('Comencar Batalla'), findsOneWidget);
    expect(find.text('Salir'), findsOneWidget);
  });
}
