# Bella's Day Out

A one-button, Flappy Bird-style arcade game built with Godot 4 and GDScript. Help Bella, a dachshund with short legs and big dreams, hop her way through the forest and thread the gaps between the bones.

Inspired by Bella, my dachshund, who proves every day that a very long dog with very short legs can still reach for the sky. 🐕✨

<!--TODO: Add itch.io link -->
**[Play it in your browser on itch.io](https://YOUR-USERNAME.itch.io/YOUR-GAME)**

<!--TODO: Add gameplay screenshot -->
![Gameplay screenshot](docs/screenshot.png)

## Features

- One-button gameplay: hop through bones with randomly placed gaps
- Difficulty that ramps up as your score grows (faster bones, shorter spacing)
- A five-layer parallax forest background that scrolls at different speeds for depth
- Sound effects and looping music, with separate mute options for each
- A title screen with the audio settings, and a way back to it from the game
- A dramatic spin and fall off the screen when Bella crashes
- Settings are saved between sessions
- Runs in the browser through a web export

## Controls

| Input | Action |
| --- | --- |
| Space, left mouse click, or tap | Start the game, hop, and restart after a game over |
| **Menu** button or Esc (in game) | Return to the title screen |
| Esc (on the title screen) | Quit the game (desktop only) |

On the title screen, use **Play** to start and the **Mute SFX** and **Mute Music** checkboxes to silence either one. The Quit button is hidden in the web version, since a browser tab can't be closed by the game.

## Run it locally

You need [Godot 4](https://godotengine.org/download) (built with 4.7; 4.3 or newer is required). Use the **standard** build, not the .NET build, because this project uses GDScript only.

```bash
git clone https://github.com/mcneiljv/bellas-day-out.git
cd bellas-day-out
```

1. Open Godot, click **Import**, and select the `project.godot` file in the cloned folder.
2. Press **F5** to run. The game opens on the title screen (`menu.tscn`).

The first time you open the project, Godot builds a local cache in a `.godot/` folder, so the initial load takes a moment. That folder is git-ignored and is safe to delete.

## Development setup

Playing and exporting the game only need Godot. If you want to change the code, or set the project up on a new machine for development, install the code-quality tools as well. They check formatting and style automatically every time you commit.

### What you need

| Tool | Why |
| --- | --- |
| [Godot 4](https://godotengine.org/download) (standard build) | Game engine, see [Run it locally](#run-it-locally) |
| [Git](https://git-scm.com/downloads) | Version control |
| [Python 3](https://www.python.org/downloads/) and [pipx](https://pipx.pypa.io/) | Runs the code-quality tools |
| [Aseprite](https://www.aseprite.org/) (optional) | Only needed to edit the pixel art |

Installing pipx:

```bash
# macOS
brew install pipx && pipx ensurepath

# Windows (PowerShell)
py -m pip install --user pipx
py -m pipx ensurepath

# Debian/Ubuntu
sudo apt install pipx && pipx ensurepath
```

Restart your terminal afterward so the `pipx` command is found.

### Install the tools

Run these once on each machine, from the cloned project folder:

```bash
pipx install "gdtoolkit==4.*"   # provides gdformat and gdlint
pipx install pre-commit
pre-commit install              # enables the commit hook for this clone
```

To confirm everything works, check the whole project once:

```bash
pre-commit run --all-files
```

### Day-to-day workflow

- **On commit:** a hook runs `gdformat` and `gdlint` on the staged `.gd` files. If `gdformat` changes a file, run `git add` on it and commit again. If `gdlint` reports errors, fix them and commit again.
- **Manual check:** `gdformat scripts/ && gdlint scripts/`
- **Skip the hook once:** `git commit --no-verify -m "message"`
- **On push:** GitHub Actions (`.github/workflows/gdscript.yml`) re-runs the same checks.
- **Rules:** lint settings live in `.gdlintrc`, and the hook setup lives in `.pre-commit-config.yaml`. Third-party code in `addons/` is excluded from both.

### Troubleshooting

- **`gdformat`, `gdlint`, or `pre-commit`: command not found.** Run `pipx ensurepath`, then restart your terminal.
- **Parse errors on newer GDScript syntax.** Run `pipx upgrade gdtoolkit`.
- **The hook doesn't run on commit.** Run `pre-commit install` again in this clone. Git hooks aren't copied when you clone a repo, so every clone needs this once.

## How it works

The game is small enough to read in one sitting. The GDScript files live in `scripts/`. The main pieces:

| File | Role |
| --- | --- |
| `menu.gd` | Title screen. Starts the game, hosts the audio toggles, and handles quitting. |
| `main.gd` | Game loop. Tracks the state (ready, playing, game over), handles input, spawns bones on a timer, keeps score, and returns to the menu. |
| `player.gd` | Bella, a `CharacterBody2D`. Applies gravity, handles hopping, emits `crashed` on the ground, and plays the death spin. |
| `pipe.gd` | A pipe pair. Scrolls left, frees itself off-screen, and emits `hit` and `scored` signals. |
| `audio_settings.gd` | Autoload named `GameSettings`. Mutes the `SFX` and `Music` audio buses and saves the choices. |
| `music_player.tscn` | Autoload named `MusicPlayer`. Plays the looping music so it carries through restarts and menu visits. |

A few design choices worth knowing:

- **Signals up, calls down.** Bella and the bones report events through signals, and `main.gd` decides what those events mean.
- **Bones are `Area2D`s, the ground is solid.** Touching a pipe ends the run through `body_entered`, while Bella lands on the ground through `move_and_slide()` and `is_on_floor()`.
- **Collision layers.** The ground sits on layer 1 and the dachshund on layer 2. The bones only scan layer 2, so they react to the dachshund and ignore the ground.
- **Gameplay input uses `_unhandled_input`.** UI buttons consume their own clicks first, so pressing Menu doesn't also make the dachshund hop.
- **Audio buses.** Sound effects play on an `SFX` bus and music on a `Music` bus, so muting either is a single toggle with no per-sound code. The bus layout lives in `default_bus_layout.tres`.

## Settings and saved data

Mute choices are saved to `user://settings.cfg`. In the editor, **Project > Open User Data Folder** opens the folder that holds it. In a web build, the data is kept in the browser's storage, so it is per browser and device, and it is cleared if the player wipes site data.

## Exporting for the web

The web export requires the **Compatibility** renderer, which this project uses.

1. Install export templates in Godot (**Editor > Manage Export Templates**).
2. Open **Project > Export**, add a **Web** preset, and export to a folder as `index.html`.
3. Test locally with **Remote Debug > Run in Browser**. Web builds don't run from a double-clicked `index.html`.
4. Zip the contents of the export folder, with `index.html` at the top level, and upload it to itch.io as an HTML project that is played in the browser.

Browsers block audio until the player interacts with the page, so the music starts when **Play** is pressed. The export output is git-ignored, so build artifacts never end up in the repository.

## Credits

- Built with [Godot Engine](https://godotengine.org/).
- Gameplay inspired by *Flappy Bird*.
- Starring Bella, the dachshund. 🐾
- Forest parallax background: [Parallax Forest by Bongseng](https://bongseng.itch.io/parallax-forest-desert-sky-moon).
- Bone and character art by me.
- Sound effects: Created by me with [jsfxr](https://sfxr.me/).
<!-- TODO: Add music creds -->
- Music: [track, artist, and license].

## License

The source code is released under the [MIT License](LICENSE).
Art, music, and other third-party assets may have their own terms, so see [Credits](#credits).