#version 460 core

#include <flutter/runtime_effect.glsl>

#define MAX_GRID 2

uniform vec2 u_size;  // Resolution of the canvas (width, height)
uniform vec4 u_backGround;

uniform vec2 u_gridSize;

uniform vec2 u_list[5];

out vec4 FragColor;

void main() {

    vec2 pixel = FlutterFragCoord() / u_size;

    float gridX = u_gridSize.x;             // Use u_gridSize.x for grid X size
    float gridY = u_gridSize.y;             // Use u_gridSize.y for grid Y size

    vec2 gridPos = floor(pixel * vec2(gridX, gridY));

    bool contains = false;

    for(int i = 0; i < 5; i++) {
        if(u_list[i] == gridPos) {
            contains = true;
            break;
        }
    }

    if(contains) {
        // Set the color to black for cell (5, 5)
        FragColor = vec4(0.5333, 0.7059, 1.0, 1.0); // Black
    } else {
        // Set the color to white for all other cells
        FragColor = u_backGround; // White
    }

}
