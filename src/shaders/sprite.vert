#version 430 core

// vertex shader
layout(location = 0) in vec2 inVertexPos; // per-vertex
layout(location = 1) in vec3 inQuadPosition; // per-instance
layout(location = 2) in vec2 inQuadSize; // per-instance
layout(location = 3) in vec4 inColor; // per-instance
layout(location = 4) in vec2 inTexPosition; // per-instance
layout(location = 5) in vec2 inTexSize; // per-instance

out vec2 texPos;
out vec4 color;

uniform mat4 projection;

void main() {
    vec3 position = vec3(inVertexPos * inQuadSize, 0.0) + inQuadPosition;
    vec2 uv = (inVertexPos * inTexSize) + inTexPosition;

    gl_Position = projection * vec4(position, 1.0);
    texPos = uv;
    color = inColor;
}
