#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 u_size;  // Resolution of the canvas (width, height)

uniform sampler2D u_grid;

out vec4 FragColor;

void main() {

    vec2 uv = FlutterFragCoord() / u_size;

//    Sample the grid at this fragment's position
    float cellState = texture2D(u_grid, uv).r;

    // Apply Game of Life rules here (sample neighbors, etc.)
    int aliveNeighbors = 0;
    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            if(x == 0 && y == 0)
                continue; // Skip current cell
            vec2 offset = vec2(float(x), float(y)) / u_resolution;
            if(texture2D(u_grid, uv + offset).r > 0.5) {
                aliveNeighbors++;
            }
        }
    }

    // Compute next cell state based on Game of Life rules
    if(cellState > 0.5) {
        if(aliveNeighbors < 2 || aliveNeighbors > 3) {
            FragColor = vec4(0.0, 0.0, 0.0, 1.0); // Cell dies
        } else {
            FragColor = vec4(1.0, 1.0, 1.0, 1.0); // Cell lives
        }
    } else {
        if(aliveNeighbors == 3) {
            FragColor = vec4(1.0, 1.0, 1.0, 1.0); // Cell becomes alive
        } else {
            FragColor = vec4(0.0, 0.0, 0.0, 1.0); // Cell stays dead
        }
    }
}
    }
}