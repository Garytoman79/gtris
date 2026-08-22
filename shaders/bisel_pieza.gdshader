shader_type canvas_item;

// Colores del relieve.
uniform vec4 color_luz : source_color = vec4(0.75, 0.92, 1.0, 1.0);
uniform vec4 color_sombra : source_color = vec4(0.02, 0.08, 0.16, 1.0);

// Profundidad visual del bloque.
uniform float profundidad : hint_range(0.0, 6.0, 0.5) = 5.0;

// Grosor del borde exterior.
uniform float grosor_borde : hint_range(0.0, 4.0, 1.0) = 2.0;

void fragment() {
	// Color original de la textura + color aplicado al Sprite/Node2D.
	vec4 textura = texture(TEXTURE, UV);
	vec4 base = COLOR * textura;

	// ---------------------------------------------------------
	// COORDENADAS EN PÍXELES
	// ---------------------------------------------------------

	vec2 pixel = UV / TEXTURE_PIXEL_SIZE;

	float ancho = 1.0 / TEXTURE_PIXEL_SIZE.x;
	float alto = 1.0 / TEXTURE_PIXEL_SIZE.y;

	float izquierda = pixel.x;
	float arriba = pixel.y;
	float derecha = ancho - pixel.x;
	float abajo = alto - pixel.y;

	// ---------------------------------------------------------
	// BORDE EXTERIOR
	// ---------------------------------------------------------

	float borde_distancia = min(
		min(izquierda, derecha),
		min(arriba, abajo)
	);

	float borde = 1.0 - smoothstep(
		0.0,
		grosor_borde + 0.5,
		borde_distancia
	);

	// ---------------------------------------------------------
	// CARA CENTRAL
	// ---------------------------------------------------------

	float dentro_cara =
		step(profundidad, pixel.x) *
		step(profundidad, pixel.y) *
		step(pixel.x, ancho - profundidad) *
		step(pixel.y, alto - profundidad);

	// ---------------------------------------------------------
	// LUZ SUPERIOR / IZQUIERDA
	// ---------------------------------------------------------

	float luz_superior = 1.0 - smoothstep(
		0.0,
		profundidad,
		arriba
	);

	float luz_izquierda = 1.0 - smoothstep(
		0.0,
		profundidad,
		izquierda
	);

	float luz = max(luz_superior, luz_izquierda);

	// ---------------------------------------------------------
	// SOMBRA INFERIOR / DERECHA
	// ---------------------------------------------------------

	float sombra_inferior = 1.0 - smoothstep(
		0.0,
		profundidad,
		abajo
	);

	float sombra_derecha = 1.0 - smoothstep(
		0.0,
		profundidad,
		derecha
	);

	float sombra = max(
		sombra_inferior,
		sombra_derecha
	);

	// ---------------------------------------------------------
	// APLICAR RELIEVE
	// ---------------------------------------------------------

	vec3 color = base.rgb;

	// Borde exterior oscuro.
	color = mix(
		color,
		color_sombra.rgb,
		borde * 0.85
	);

	// Bisel superior/izquierdo.
	color = mix(
		color,
		color_luz.rgb,
		luz * 0.75
	);

	// Bisel inferior/derecho.
	color = mix(
		color,
		color_sombra.rgb,
		sombra * 0.85
	);

	// La cara central conserva completamente
	// el color original de la pieza.
	color = mix(
		color,
		base.rgb,
		dentro_cara
	);

	COLOR = vec4(color, base.a);
}