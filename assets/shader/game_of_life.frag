#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 u_size;  // Resolution of the canvas (width, height)
uniform vec4 u_backGround;    // Grid size (x, y), representing the number of columns and rows

uniform vec2 u_gridSize;


//FIXME:
uniform vec3 u_cellColors[100]; // Max of 100 cells

out vec4 FragColor;

void main() {

    vec2 pixel = FlutterFragCoord() / u_size;

    vec2 gridPos = floor(pixel * u_gridSize);
    int cellIndex = int(gridPos.y) * int(u_gridSize.x) + int(gridPos.x);
    if(cellIndex >= 100) {
        cellIndex = 99;
    }
    vec3 cellColor = u_cellColors[cellIndex];

    FragColor = vec4(cellColor, 1.0);
}
