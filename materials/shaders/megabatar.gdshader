shader_type spatial;

void vertex() {
    // Modify the vertex position in the vertex shader
    VERTEX.z += sin(TIME * 4.0 + VERTEX.y) * 0.5;
    VERTEX.x += sin(TIME * 8.0 + VERTEX.x * 0.5) * 0.5;
}

void fragment() {
    vec3 color;

    // Calculate the hue component based on time
    float hue = sin(TIME * 0.3 + VERTEX.x) * 0.5 + 0.5; // Map sine wave to range [0, 1]
    // Map hue to the range between 31127dark blue and bright orange
    vec3 dark_blue = vec3(0.0, 0.0, 0.1);
    vec3 bright_orange = vec3(0.5, 0.2, 0.0);
    color = mix(dark_blue, bright_orange, hue);

    // Add a foggy red light effect by emitting red light
    vec3 foggy_red = vec3(1.0, 0.0, 0.0);
    ALBEDO = color;

    // Emit a foggy red light
    EMISSION = foggy_red * 0.5; // Adjust the intensity of the red light emission
}
