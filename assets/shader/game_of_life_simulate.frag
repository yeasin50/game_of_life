#version 460 core

#include <flutter/runtime_effect.glsl>
precision mediump float;

uniform vec2 u_size;  // Resolution of the canvas (width, height)
uniform sampler2D image;

out vec4 fragColor;

void main() {
    vec2 uv = (FlutterFragCoord().xy / u_size.xy);
    vec3 imageColor = texture(image, uv).xyz;
    // float luminance = imageColor.r * 0.299 + imageColor.g * 0.587 + imageColor.b * 0.114;
    fragColor = vec4(imageColor, 1.0);

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
//             FragColor = vec4(0.0, 0.0, 0.0, 1.0); // Cell dies
//         } else {
//             FragColor = vec4(1.0, 1.0, 1.0, 1.0); // Cell lives
//         }
//     } else {
//         // Cell is currently dead
//         if(aliveNeighbors == 3) {
//             FragColor = vec4(1.0, 1.0, 1.0, 1.0); // Cell becomes alive
//         } else {
//             FragColor = vec4(0.0, 0.0, 0.0, 1.0); // Cell stays dead
//         }
//     }
}