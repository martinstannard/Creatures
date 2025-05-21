# Little Creatures

## Project Overview
Little Creatures is an interactive web-based simulation where users can observe creatures (referred to as "turtles" in the code, but depicted as bugs in the user interface) on an HTML canvas. The purpose of this project is to simulate various aspects of creature behavior, including their movement, aging process, health status changes, and their ability to seek out food sources.

Users can:
- Observe creature interactions and behaviors within the environment.
- Adjust simulation parameters (e.g., number of creatures, maximum speed, initial health, health change rate, health ceiling, initial food amount, food increment rate).
- Control simulation flow (restart, faster, slower, pause, resume).

## Features
- Canvas-based visual simulation of creatures.
- Adjustable parameters:
    - Number of creatures
    - Maximum speed
    - Initial health
    - Health change rate
    - Health ceiling
    - Initial food amount
    - Food increment rate
- Simulation controls:
    - Restart
    - Faster
    - Slower
    - Pause
    - Resume
- Display of individual creature statistics (ID, health, age).
- Display of average health and age for the population.
- Real-time updates of the simulation speed (interval in ms).

## Technology Stack
**Frontend:**
- HTML
- CSS
- JavaScript (compiled from CoffeeScript)
- jQuery
- Underscore.js
**Backend:**
- Ruby
- Rack (for serving static files)

## Project Structure
- `public/index.html`: The main HTML file that structures the web application interface, including the canvas for the simulation and user controls.
- `public/javascripts/turtles.coffee`: The CoffeeScript file containing the core logic for the simulation. This includes classes for managing creatures (referred to as "turtles" in the code), food, canvas drawing, and simulation parameters. (Compiled to `public/javascripts/turtles.js`)
- `public/stylesheets/turtles.css`: The CSS file used for styling the application's appearance.
- `public/images/`: This directory stores the images used for the creatures (e.g., `bug0.png` - `bug7.png`, which are depicted as bugs in the UI).
- `config.ru`: A Rack configuration file used to launch the application, primarily for serving the static files from the `public` directory.
- `Gemfile`: Defines the Ruby gem dependencies for the project (e.g., Rack).
- `.gitignore`: Specifies intentionally untracked files that Git should ignore.
- `README.md`: This documentation file.

## Setup and Running Instructions

### Prerequisites
- Ruby (it is recommended to use a version manager like RVM or rbenv)
- Bundler (Ruby gem for managing dependencies - `gem install bundler`)

### Steps
1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/little-creatures.git
    cd little-creatures
    ```
    (Replace `https://github.com/your-username/little-creatures.git` with the actual repository URL and `little-creatures` with the actual directory name.)

2.  **Install dependencies:**
    Navigate to the project's root directory in your terminal and run:
    ```bash
    bundle install
    ```

3.  **Start the server:**
    Once the dependencies are installed, start the Rack server:
    ```bash
    rackup config.ru
    ```

4.  **Access the application:**
    Open your web browser and navigate to `http://localhost:9292`.
    The server will typically start on port 9292. If this port is already in use, Rack might choose a different one. The correct URL and port will be displayed in your terminal output when `rackup` starts.

## How it Works
The simulation is driven by several key CoffeeScript components that manage the behavior and rendering of the creatures and their environment:

-   **`Canvas` Class:** Responsible for all drawing operations on the HTML canvas. This includes clearing the canvas at each step, drawing dots that represent food items, and rendering textual information for statistics.

-   **`Colour` Class:** Manages colour generation and conversion (e.g., RGB to hex). It plays a crucial role in dynamically determining the colour of each creature based on its current health, providing a visual cue for their status.

-   **`Food` Class:** Represents the food items available on the canvas. Each food object contains a certain amount of health points that it can transfer to a creature. When a food item is consumed by a creature, it is effectively "replaced" by a new food object appearing elsewhere on the canvas.

-   **`Turtle` Class (Creatures):** This is the central class for the simulated entities (referred to as "turtles" in the code, but depicted as bugs in the UI). Each instance of `Turtle` has several properties:
    -   Attributes: An ID, age, current health, speed, position (x, y coordinates), and a heading (direction of movement).
    -   Visuals: An associated image (from `bugN.png` files) to represent it on the canvas.
    -   Behavior:
        -   `move()`: Updates the turtle's position based on its current heading and speed. It also handles logic for wrapping around the edges of the canvas (e.g., a turtle exiting on the right side will reappear on the left). After updating its position, it draws the turtle on the canvas.
        -   `turn()`: Modifies the turtle's heading, allowing it to change direction.
        -   `tick()`: This method is called in each simulation step. It increments the turtle's age, adjusts its heading (through a combination of random changes and a tendency to move towards nearby food), calls `move()` to update its position, and modifies its health (e.g., health might decrease over time).
        -   `dead()`: A simple check to determine if the turtle's health has fallen below a critical threshold (e.g., less than 1), indicating it is no longer alive.
        -   `smell()`: Calculates the distance to the nearest food item. If a food item is within a certain range (the "smell" distance), the turtle will move towards it and "eat" it. Eating involves the turtle gaining health points from the food, and the consumed food item is then replaced.

-   **`Population` Class:** Manages the entire collection of `Turtle` objects. Its primary role is to orchestrate the simulation at a higher level. The `tick()` method of the `Population` class iterates through each `Turtle` in its collection, invoking their individual `tick()` methods. It also manages the interaction between turtles and food, and handles the replacement of "dead" turtles with new ones to maintain the population size.

-   **`Reporter` Class:** Responsible for displaying various statistics on the canvas. This includes information about individual creatures (like their ID, health, and age), as well as aggregate data such as the average health and age of the entire population. It also shows the current simulation speed (interval in milliseconds).

-   **Main Simulation Loop:** Located in the global scope of the `turtles.coffee` file, this is where the simulation is initialized and run.
    -   Initialization: Instances of the `Canvas`, `Food`, `Reporter`, and `Population` classes are created.
    -   Timer: A `setInterval` function creates a recurring loop. In each iteration of this loop, the following actions occur:
        1.  The canvas is cleared.
        2.  Food items are drawn.
        3.  The `population.tick()` method is called, which in turn updates each turtle (movement, aging, health changes) and their interactions with food (smelling, eating).
        4.  The status of food items is updated (e.g., replacing eaten food).
        5.  The `reporter` draws the updated statistics.
    -   User Interface Interaction: HTML elements (buttons for start/stop, speed controls, and input fields for parameters) allow users to modify simulation settings (like the number of turtles, their speed, etc.) and control the execution of the `setInterval` timer (pausing, resuming, or changing its frequency to speed up or slow down the simulation).

