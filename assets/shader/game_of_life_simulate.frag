#version 460 core

#include <flutter/runtime_effect.glsl>
precision mediump float;

uniform vec2 uSize;  // Resolution of the canvas (width, height)
uniform sampler2D uSampler;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord() / uSize;
    fragColor = texture(uSampler, uv);

//     float cellState = texture(u_grid, uv).r;
// 
//     int aliveNeighbors = 0;
//     for(int x = -1; x <= 1; x++) {
//         for(int y = -1; y <= 1; y++) {
//             if(x == 0 && y == 0)
//                 continue; // Skip current cell
//             vec2 offset = vec2(float(x), float(y)) / u_size;
//             if(texture(u_grid, uv + offset).r > 0.5) {
//                 aliveNeighbors++;
//             }
//         }
//     }
// 
//     // Compute next cell state based on Game of Life rules
//     if(cellState > 0.5) {
//         // Cell is currently alive
//         if(aliveNeighbors < 2 || aliveNeighbors > 3) {
//             fragColor = vec4(0.0, 0.0, 0.0, 1.0); // Cell dies
//         } else {
//             fragColor = vec4(1.0, 1.0, 1.0, 1.0); // Cell lives
//         }
//     } else {
//         // Cell is currently dead
//         if(aliveNeighbors == 3) {
//             fragColor = vec4(1.0, 1.0, 1.0, 1.0); // Cell becomes alive
//         } else {
//             fragColor = vec4(0.0, 0.0, 0.0, 1.0); // Cell stays dead
//         }
//     }
}