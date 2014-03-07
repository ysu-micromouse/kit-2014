# Psuedocode

The following are examples of functions that the micromouse may need in order to traverse the maze.
Although the kit mouse will be programmed in BASIC, the psuedocode will resemble C-based language, since that is what most of us are used to.

## Functions/Classes

Each section could potentially be categorized in it's own class for organizational purposes.

EX: Movement class with method of forward, reverse, etc. 

### Movement

Not certain if the kit mouse uses servos, but when this document says servos, it's referring to turning the wheels.

#### Forward

Moves the mouse forward

```
move_forward(int Time){
    turn both servos on for T seconds in the forward direction;
}
```

#### Reverse

Moves the mouse backwards

```
move_reverse(int Time){
    turn both servos on for T seconds in the reverse direction
}
```

#### Rotate

Rotates the mouse

```
move_rotates(int Degree, bool Right){
    if(Right) { // RIGHT
        turn on the left servo in the forward direction;
        turn on the right servo in the reverse direction;
    } else { // LEFT
        turn on the right servo in the forward direction;
        turn on the left servo in the reverse direction;
    }
    wait for X seconds, based on Degree;
    turn off both servos;
}
```

#### Turn

Moves the mouse to an adjacent cell

```
move_turn(int Direction) {
    switch Direction {
        case 0: // Ahead
            move_rotates(0, true);
            move_forward(TIME_PER_CELL); //Time required to move from one cell to another
            break;
        case 1: // Right
            move_rotates(90, true);
            move_forward(TIME_PER_CELL);
            break;
        case 2: // Behind
            move_rotates(180, true);
            move_forward(TIME_PER_CELL);
            break;
        case 3: // Left
            move_rotates(90, false);
            move_forward(TIME_PER_CELL);
            break;
        default: // Not recognizable Direction
            break;
    }
}
```

### Sensory

Functions that relate to receive input from sensors

#### Wall Detection

```
sensory_wall() {
    returns if a wall is infront of it or not;
}
```

### Mapping

Functions related to mapping the maze

#### Map maze

```
map_maze() {

}
```

### Solving

Functions related to solving the maze

#### Solve maze

```
solve_maze() {

}
```

