#version 460 core

#include <flutter/runtime_effect.glsl>
precision mediump float;

const vec4 aliveCell = vec4(1.0, 1.0, 1.0, 1.0);
const vec4 deadCell = vec4(0, 0, 0, 1);

uniform vec2 uSize;  // Resolution of the canvas (width, height)
uniform sampler2D uSampler;

uniform float play;

uniform float uGridSize;

out vec4 fragColor;

void main() {

    vec2 uv = FlutterFragCoord().xy / uSize;
    uv.x *= (uSize.x / uSize.y);

      // Calculate the current cell's grid position
    vec2 gridPos = floor(uv * uSize / uGridSize);

    // Get the center of the current cell
    vec2 cellCenter = (gridPos + 0.5) * uGridSize / uSize;

    // Fetch the current state of the cell (alive or dead)
    float cellState = texture(uSampler, cellCenter).r;

    // Number of alive neighbors
    int aliveNeighbors = 0;

    // Loop through the 3x3 grid to check neighbors, with edge wrapping
    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            if(x == 0 && y == 0)
                continue; // Skip the current cell

            vec2 neighborPos = gridPos + vec2(float(x), float(y));

            // Wrap the neighbor position (toroidal wrapping)
            neighborPos = mod(neighborPos, uSize / uGridSize);

            // Convert neighbor position back to UV space
            vec2 neighborUV = (neighborPos + 0.5) * uGridSize / uSize;

            // Sample the state of the neighbor cell
            float neighborState = texture(uSampler, neighborUV).r;

            // Check if the neighbor is alive
            if(neighborState > 0.5) {
                aliveNeighbors++;
            }
        }
    }

    // Apply Conway's Game of Life rules
    if(cellState > 0.5) {
        // If the cell is alive
        if(aliveNeighbors < 2 || aliveNeighbors > 3) {
            fragColor = deadCell;
        } else {
            fragColor = aliveCell;
            ;
        }
    } else {
        if(aliveNeighbors == 3) {
            fragColor = aliveCell;
        } else {
            fragColor = deadCell;
        }
    }
}