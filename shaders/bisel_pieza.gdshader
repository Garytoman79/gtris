shader_type canvas_item;

// Colores del relieve.
uniform vec4 color_luz : source_color = vec4(0.75, 0.92, 1.0, 1.0);
uniform vec4 color_sombra : source_color = vec4(0.02, 0.08, 0.16, 1.0);

// Medidas expresadas en píxeles.
uniform float tamano_bisel : hint_range(1.0, 8.0, 1.0) = 3.0;
uniform float grosor_borde : hint_range(0.0, 4.0, 1.0) = 1.0;

void fragment() {
	// Conserva la textura blanca y el color de cada pieza.
	COLOR *= texture(TEXTURE, UV);

	// Distancia desde este píxel hasta el borde más cercano del bloque.
	vec2 distancia_bordes = min(UV, vec2(1.0) - UV) / TEXTURE_PIXEL_SIZE;
	float borde_mas_cercano = min(distancia_bordes.x, distancia_bordes.y);

	// Borde oscuro: separa visualmente los bloques de una misma pieza.
	float borde = 1.0 - smoothstep(0.0, grosor_borde + 0.5, borde_mas_cercano);
	COLOR.rgb = mix(COLOR.rgb, color_sombra.rgb, borde * 0.7);

	// Luz en arriba/izquierda.
	float distancia_arriba_izquierda =
		min(UV.x, UV.y) / min(TEXTURE_PIXEL_SIZE.x, TEXTURE_PIXEL_SIZE.y);
	float luz = 1.0 - smoothstep(0.0, tamano_bisel, distancia_arriba_izquierda);
	COLOR.rgb = mix(COLOR.rgb, color_luz.rgb, luz * 0.35);

	// Sombra en abajo/derecha.
	float distancia_abajo_derecha =
		min(1.0 - UV.x, 1.0 - UV.y) /
		min(TEXTURE_PIXEL_SIZE.x, TEXTURE_PIXEL_SIZE.y);
	float sombra = 1.0 - smoothstep(0.0, tamano_bisel, distancia_abajo_derecha);
	COLOR.rgb = mix(COLOR.rgb, color_sombra.rgb, sombra * 0.35);
}