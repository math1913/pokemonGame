# Videojuego de Batalla Pokemon (Flutter)

Aplicacion desarrollada para la actividad AE1. Incluye navegacion por pantallas,
sistema de turnos, movimientos con coste de PP, estadisticas de batalla y
mejoras visuales.

## Funcionalidades implementadas

- Pantalla de inicio con:
  - titulo del juego
  - seleccion de Pokemon para Jugador 1 y Jugador 2
  - boton `Comenzar Batalla`
  - boton `Salir` con confirmacion
- Pantalla de batalla con:
  - turnos alternos
  - PS y PP con barras visuales
  - movimientos: Ataque Rapido, Ataque Normal, Ataque Fuerte, Curacion
  - critico (10%) y fallo (5%, sin consumo de PP)
  - desactivacion de botones cuando no hay turno o PP suficiente
  - historial de ultimos movimientos
  - animaciones basicas al atacar y recibir daño
- Pantalla final con:
  - ganador
  - ataques totales
  - duracion aproximada
  - estadisticas avanzadas por jugador
  - nueva batalla (reinicia valores)
  - volver al inicio

## Estructura

- `lib/main.dart`: punto de entrada y tema de la app.
- `lib/models/pokemon.dart`: datos y estado de Pokemon.
- `lib/models/battle_stats.dart`: movimientos, historial y estadisticas.
- `lib/screens/home_screen.dart`: pantalla de inicio y seleccion.
- `lib/screens/battle_screen.dart`: logica principal de combate.
- `lib/screens/result_screen.dart`: resumen final y acciones de navegacion.

## Ejecucion

1. Instalar dependencias:
   - `flutter pub get`
2. Ejecutar en emulador o dispositivo:
   - `flutter run`
3. Analizar el proyecto:
   - `flutter analyze`
4. Ejecutar test basico:
   - `flutter test`
