<!-- Add proper contents to markdown file -->
# Bella Takes Off

A one-button, Flappy Bird-style arcade game built with Godot 4 and GDScript. Left-click or press Space to flap, thread the gaps between the pipes, and beat your best score.

Inspired by Bella, my dachshund, who proves every day that a very long dog with very short legs can still reach for the sky. 🐕✨

**[Play it in your browser on itch.io](https://YOUR-USERNAME.itch.io/YOUR-GAME)**

![Gameplay screenshot](docs/screenshot.png)

## Controls

| Input | Action |
| --- | --- |
| Space, left mouse click, or tap | Start the game, flap, and restart after a game over |

## Run it locally

You need [Godot 4](https://godotengine.org/download) (built with 4.7; 4.3 or newer is required). Use the **standard** build, not the .NET build, because this project uses GDScript only.

```bash
git clone https://github.com/YOUR-USERNAME/lo-fi-liftoff.git
```

1. Open Godot, click **Import**, and select the `project.godot` file in the cloned folder.
2. Press **F5** to run. The main scene is `main.tscn`.

## How it works

The game is small enough to read in one sitting. The main pieces:

| File | Role |
| --- | --- |
| `main.gd` | Game loop. Tracks the state (ready, playing, game over), handles input, spawns pipes on a timer, and keeps score. |
| `player.gd` | The bird, a `CharacterBody2D`. Applies gravity, handles flapping, and emits `crashed` when it lands on the ground. |
| `pipe.gd` | A pipe pair. Scrolls left, frees itself off-screen, and emits `hit` and `scored` signals. |

A few design choices worth knowing:

- **Signals up, calls down.** The bird and pipes report events through signals, and `main.gd` decides what those events mean.
- **Pipes are `Area2D`s, the ground is solid.** Touching a pipe ends the run through `body_entered`, while the bird lands on the ground through `move_and_slide()` and `is_on_floor()`.
- **Collision layers.** The ground and world are on layer 1 and the bird is on layer 2. The pipes' masks only scan layer 2, so they react to the bird and ignore the ground.

## Exporting for the web

The web export requires the **Compatibility** renderer, which this project uses.

1. Install export templates in Godot (**Editor > Manage Export Templates**).
2. Open **Project > Export**, add a **Web** preset, and export to a folder as `index.html`.
3. Test locally with **Remote Debug > Run in Browser**. Web builds don't run from a double-clicked `index.html`.
4. Zip the contents of the export folder, with `index.html` at the top level, and upload it to itch.io as an HTML project that is played in the browser.

The export output is git-ignored, so build artifacts never end up in the repository.

## Credits

- Built with [Godot Engine](https://godotengine.org/).
- Gameplay inspired by *Flappy Bird*.
- Art and audio: [add your sources here, or note that the game uses placeholder shapes].

## License

[Choose a license, for example MIT, and add a `LICENSE` file.]