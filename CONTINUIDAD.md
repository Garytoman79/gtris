# Gtris — estado de continuidad

Última actualización: 10 de agosto de 2026.

## Preferencias de trabajo

- El proyecto es un Tetris en Godot para aprender desarrollo de videojuegos.
- El usuario viene de Ruby on Rails y prefiere realizar cambios desde el editor e IDE de Godot siempre que sea posible.
- Solo proponer cambios de GDScript cuando sean necesarios para la lógica, el comportamiento dinámico o cuando la interfaz no ofrezca una alternativa adecuada.
- Explicar el motivo de los cambios para que sirvan de aprendizaje.

## Estado actual del proyecto

- Motor: Godot 4.7, renderizador Compatibility.
- Escena principal: `scenes/board/board.tscn`.
- Script principal: `scenes/board/board.gd`.
- El juego ya incluye movimiento lateral con DAS, caída, caída rápida, rotación básica, bloqueo de piezas, eliminación de líneas, nivel y Game Over.

## Diseño y comportamiento de ventana

- En Project Settings se configuró:
  - Stretch Mode: `canvas_items`.
  - Stretch Aspect: `expand`.
  - Modo inicial de ventana: maximizado.
- En las pruebas incrustadas de Godot, para simular el comportamiento de una ventana real hay que usar la opción de tamaño `Stretch to Fit` del menú de la barra de juego.

## Fondo generado con Flux

- El fondo elegido es el resultado de inpaint `Inpaint_Flux_FondoGtris_00015_.png`.
- Se ha utilizado como fondo actual en `assets/background.png`.
- La versión anterior se conserva como `assets/background_original.png`; también existe una prueba recortada, `assets/background_recortado.png`.
- El resultado 00015 es el preferido: elimina el panel/marco interior generado por IA y deja una zona central oscura que no compite con el tablero de Godot.
- El `TextureRect` ocupa el viewport por código, con `Keep Aspect Covered`; por ello el fondo puede tener un encuadre ligeramente distinto en la vista 2D del editor y durante la ejecución maximizada. La referencia visual válida es el juego ejecutándose.

## Árbol de escena relevante

```text
Board
├── TextureRect
└── GameLayout
    ├── Playfield
    │   ├── BoardGlow
    │   ├── BoardFrame
    │   ├── WallLeft
    │   ├── WallRight
    │   └── Floor
    └── HUD
        ├── StatsPanel
        ├── NextPanel
        ├── LinesTextLabel
        ├── LevelTextLabel
        ├── NextPiecePreview
        ├── GameOverLabel
        └── NextTitle
```

`GameOverLabel` todavía permanece dentro de HUD. Más adelante conviene colocarlo visualmente sobre el tablero o convertirlo en un panel/modal propio.

## Layout responsivo actual

En `board.gd` hay constantes para el layout:

```gdscript
const HUD_WIDTH = 190
const LAYOUT_GAP = 32
```

`center_playfield()` realiza estas tareas al iniciar y al cambiar el tamaño del viewport:

- Da a `TextureRect` el tamaño real del viewport.
- Centra `GameLayout` completo.
- Sitúa `Playfield` a la derecha de HUD, con una separación de 32 px.

Para que la escena sea legible en el editor a la resolución base de 1152x648 se guardaron estas posiciones aproximadas:

```text
GameLayout: (305, 4)
Playfield:  (222, 0)
HUD:        (0, 0)
TextureRect Size: (1152, 648)
```

En la vista 2D del editor los nodos pueden parecer solapados o ligeramente desalineados respecto a la textura porque el código de `_ready()` no se ejecuta allí. En ejecución las posiciones se recalculan y el resultado maximizado es correcto.

## Marco del tablero

- El antiguo `Line2D` se renombró a `BoardFrame` y se añadió `BoardGlow` como duplicado para crear halo azul.
- `BoardGlow` debe estar antes de `BoardFrame` en el árbol para dibujarse detrás.
- El frame usa un borde azul fino; el glow usa más anchura, azul oscuro y alfa bajo.
- Ambos `Line2D` deben tener exactamente cuatro puntos, con `Closed` activado:

```text
(-3, -3)
(323, -3)
(323, 643)
(-3, 643)
```

No añadir un quinto punto que repita el primero: al estar `Closed` activado, Godot crea el lado final automáticamente. Un punto extra de coordenadas ligeramente distintas produjo un defecto en una esquina.

## UI actual

- `StatsPanel` agrupa visualmente Nivel y Líneas.
- `NextPanel` agrupa el título `SIGUIENTE` y la previsualización de la próxima pieza.
- Ambos son `Panel` con `StyleBoxFlat`: fondo azul oscuro semitransparente, borde azul fino y esquinas rectas, coherentes con el tablero.
- Los paneles se colocan antes que los textos y la previsualización en el árbol de HUD para que se dibujen detrás. No usar `Z Index = -1`, porque los colocaría detrás de `TextureRect` y desaparecerían.
- El centrado fino de textos y tamaños de panel se ha ajustado visualmente con los tiradores del editor, que es la forma preferida para este tipo de trabajo.

### Diseño previsto de la columna HUD

```text
Gtris / G-tris                 (nombre pendiente de decidir)

RÉCORD
Nombre · líneas

NIVEL · valor
LÍNEAS · valor

SIGUIENTE
previsualización de pieza
```

Todo dato debe mostrarse dentro de un panel/rectángulo con el mismo lenguaje visual azul del tablero.

## Previsualización de la siguiente pieza

Las escenas de tetrominós no tienen el mismo origen visual; por ello, algunas piezas aparecían centradas y otras no.

Se actualizó `update_next_piece_preview()` para llamar a `center_preview_piece(preview_instance)`. La función:

1. Recorre los bloques de `CanvasGroup`.
2. Calcula sus extremos mínimo y máximo.
3. Obtiene el centro visual del rectángulo ocupado.
4. Desplaza la instancia de previsualización para centrarla en `NextPiecePreview`.

`INF` se emplea para inicializar los mínimos/máximos sin imponer un límite arbitrario. `child as Node2D` permite usar `global_position` en un hijo que `get_children()` entrega como `Node` genérico.

Este centrado es exclusivamente visual. No debe reutilizarse directamente como pivote de rotación del juego: una rotación debe conservar bloques alineados con la cuadrícula de 32 px. El actual nodo `Pivot` por pieza sirve de pivote de rotación seguro.

## Pendiente

1. Probar la previsualización centrada con todas las piezas: I, O, T, J, L, S y Z.
2. Crear el panel de récord:
   - nombre del jugador;
   - número de líneas del récord.
3. Decidir el título definitivo: `Gtris` o `G-tris`, y crear su panel/cabecera.
4. Implementar persistencia local del récord y actualizar la UI cuando se supere.
5. Diseñar un panel/modal de Game Over integrado con la estética azul.
6. Revisar el acabado visual de los paneles y del marco del tablero tras probarlos en ventana maximizada.
7. Más adelante, si se desea un comportamiento de Tetris moderno, sustituir la rotación básica por SRS y wall kicks. El sistema SRS trata especialmente las piezas I y O; no usa simplemente el centro geométrico de cada figura.
8. Futuras mejoras habituales: puntuación, sonidos, pausa/reinicio, animaciones de líneas y pantalla de inicio.

