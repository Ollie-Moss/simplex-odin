#version 430 core

out vec4 FragColor;
in vec2 texPos;
in vec4 color;

uniform sampler2D ourTexture;
uniform bool useTexture;

void main() {
    if (!useTexture){
        FragColor = color;
        return;
    }

    vec4 texColor = texture(ourTexture, texPos);
    if (texColor.a <= 0.0) {
        FragColor = texColor;
        return;
    } 

    vec4 mixed = mix(texColor, color, color.a);
    mixed.a = texColor.a;
    FragColor = mixed;
}
