#version 430 core

out vec4 FragColor;
in vec2 texPos;
in vec4 color;

uniform sampler2D ourTexture;

void main() {
    vec4 texColor = texture(ourTexture, texPos);
    if (texColor.a > 0.0) {
        vec4 mixed = mix(texColor, color, color.a);
        mixed.a = texColor.a;
        FragColor = mixed;
    } 
    else {
        FragColor = texColor;
    }
}
