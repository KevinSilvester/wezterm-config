# My WezTerm Config

<p align="center">
  <a href="https://github.com/KevinSilvester/wezterm-config/stargazers">
    <img alt="Stargazers" src="https://img.shields.io/github/stars/KevinSilvester/wezterm-config?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41">
  </a>
  <a href="https://github.com/KevinSilvester/wezterm-config/issues">
    <img alt="Issues" src="https://img.shields.io/github/issues/KevinSilvester/wezterm-config?style=for-the-badge&logo=gitbook&color=B5E8E0&logoColor=D9E0EE&labelColor=302D41">
  </a>
  <a href="https://github.com/KevinSilvester/wezterm-config/actions/workflows/lint.yml">
    <img alt="Build" src="https://img.shields.io/github/actions/workflow/status/KevinSilvester/wezterm-config/lint.yml?&style=for-the-badge&logo=githubactions&color=A6E3A1&logoColor=D9E0EE&labelColor=302D41">
  </a>
</p>

![screenshot](./.github/screenshots/wezterm.gif)

&nbsp;

### Features

- [**Background Image Selector**](https://github.com/KevinSilvester/wezterm-config/blob/master/utils/backdrops.lua)

  Uses `wezterm.read_dir` to scan the `backdrops` directory for images.

  - Usage:
    - <kbd>SUPER</kbd>+<kbd>/</kbd>: Select random image
    - <kbd>SUPER</kbd>+<kbd>,</kbd>: Cycle images forward
    - <kbd>SUPER</kbd>+<kbd>.</kbd>: Cycle images backwards
    - <kbd>SUPER_REV</kbd>+<kbd>/</kbd>: Fuzzy select image

- [**GPU Adapter Selector**](https://github.com/KevinSilvester/wezterm-config/blob/master/utils/gpu_adapter.lua)

  > :bulb: Only works if the [`front_end`](https://github.com/KevinSilvester/wezterm-config/blob/master/config/appearance.lua#L8) option is set to `WebGpu`.

  A small utility to select the best GPU + Adapter (graphics API) combo for your machine.

  GPU + Adapter combo is selected based on the following criteria:

  1.  <details>
      <summary>Best GPU available</summary>

      (`Discrete` > `Integrated` > `Other` (for `wgpu`'s OpenGl implementation on Discrete GPU) > `Cpu`)
      </details>

  2.  <details>
      <summary>Best graphics API available (based off my very scientific scroll a big log file in Neovim test 😁)</summary>

      > see: <https://github.com/gfx-rs/wgpu#supported-platforms> for more info

      - Windows: `Dx12` > `Vulkan` > `OpenGl`
      - Linux: `Vulkan` > `OpenGl`
      - Mac: `Metal`

      </details>

&nbsp;

### All Key Binbdings

Most of the key bindings revolve around a <kbd>SUPER</kbd> and a <kbd>SUPER_REV</kbd>(super reversed) keys.<br>

- On MacOs:
  - <kbd>SUPER</kbd> ⇨ <kbd>Super</kbd>
  - <kbd>SUPER_REV</kbd> ⇨ <kbd>Super</kbd>+<kbd>Ctrl</kbd>
- On Windows and Linux
  - <kbd>SUPER</kbd> ⇨ <kbd>Alt</kbd>
  - <kbd>SUPER_REV</kbd> ⇨ <kbd>Alt</kbd>+<kbd>Ctrl</kbd>

> To avoid confusion when switching between different OS and to avoid conflicting<br>
> with OS's built-in keyboard shortcuts.

- On all platforms: <kbd>LEADER</kbd> ⇨ <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Space</kbd>

<details>
<summary><i>Click to expand:</i></summary>
        
#### Miscellaneous/Useful

| Keys                          | Action                                      |
| ----------------------------- | ------------------------------------------- |
| <kbd>F1</kbd>                 | `ActivateCopyMode`                          |
| <kbd>F2</kbd>                 | `ActivateCommandPalette`                    |
| <kbd>F3</kbd>                 | `ShowLauncher`                              |
| <kbd>F4</kbd>                 | `ShowLauncher` <sub>(tabs only)</sub>       |
| <kbd>F5</kbd>                 | `ShowLauncher` <sub>(workspaces only)</sub> |
| <kbd>F11</kbd>                | `ToggleFullScreen`                          |
| <kbd>F12</kbd>                | `ShowDebugOverlay`                          |
| <kbd>SUPER</kbd>+<kbd>f</kbd> | Search Text                                 |
| <kbd>SUPER</kbd>+<kbd>f</kbd> | Open URL                                    |

&nbsp;

#### Copy+Paste

| Keys                                          | Action               |
| --------------------------------------------- | -------------------- |
| <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>c</kbd> | Copy to Clipborad    |
| <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>v</kbd> | Paste from Clipborad |

&nbsp;

#### Tabs

##### Tabs: Spawn+Close

| Keys                              | Action                                |
| --------------------------------- | ------------------------------------- |
| <kbd>SUPER</kbd>+<kbd>t</kbd>     | `SpawnTab` <sub>(DefaultDomain)</sub> |
| <kbd>SUPER_REV</kbd>+<kbd>f</kbd> | `SpawnTab` <sub>(WSL:Ubuntu)</sub>    |
| <kbd>SUPER_REV</kbd>+<kbd>w</kbd> | `CloseCurrentTab`                     |

##### Tabs: Navigation

| Keys                              | Action         |
| --------------------------------- | -------------- |
| <kbd>SUPER</kbd>+<kbd>[</kbd>     | Next Tab       |
| <kbd>SUPER</kbd>+<kbd>]</kbd>     | Previous Tab   |
| <kbd>SUPER_REV</kbd>+<kbd>[</kbd> | Move Tab Left  |
| <kbd>SUPER_REV</kbd>+<kbd>]</kbd> | Move Tab Right |

&nbsp;

#### Windows

| Keys                          | Action        |
| ----------------------------- | ------------- |
| <kbd>SUPER</kbd>+<kbd>n</kbd> | `SpawnWindow` |

&nbsp;

#### Panes

##### Panes: Split Panes

| Keys                               | Action                                           |
| ---------------------------------- | ------------------------------------------------ |
| <kbd>SUPER</kbd>+<kbd>\\</kbd>     | `SplitVertical` <sub>(CurrentPaneDomain)</sub>   |
| <kbd>SUPER_REV</kbd>+<kbd>\\</kbd> | `SplitHorizontal` <sub>(CurrentPaneDomain)</sub> |

##### Panes: Zoom+Close Pane

| Keys                              | Action                |
| --------------------------------- | --------------------- |
| <kbd>SUPER</kbd>+<kbd>Enter</kbd> | `TogglePaneZoomState` |
| <kbd>SUPER</kbd>+<kbd>w</kbd>     | `CloseCurrentPane`    |

##### Panes: Navigation

| Keys                              | Action                  |
| --------------------------------- | ----------------------- |
| <kbd>SUPER_REV</kbd>+<kbd>k</kbd> | Move to Pane (Up)       |
| <kbd>SUPER_REV</kbd>+<kbd>j</kbd> | Move to Pane (Down)     |
| <kbd>SUPER_REV</kbd>+<kbd>h</kbd> | Move to Pane (Left)     |
| <kbd>SUPER_REV</kbd>+<kbd>l</kbd> | Move to Pane (Right)    |
| <kbd>SUPER_REV</kbd>+<kbd>p</kbd> | Swap with selected Pane |

&nbsp;

#### Background Images

| Keys                              | Action                  |
| --------------------------------- | ----------------------- |
| <kbd>SUPER</kbd>+<kbd>/</kbd>     | Select Random Image     |
| <kbd>SUPER</kbd>+<kbd>,</kbd>     | Cycle to next Image     |
| <kbd>SUPER</kbd>+<kbd>.</kbd>     | Cycle to previous Image |
| <kbd>SUPER_REV</kbd>+<kbd>/</kbd> | Fuzzy select Image      |

&nbsp;

#### Key Tables

> See: <https://wezfurlong.org/wezterm/config/key-tables.html>

| Keys                           | Action        |
| ------------------------------ | ------------- |
| <kbd>LEADER</kbd>+<kbd>f</kbd> | `resize_font` |
| <kbd>LEADER</kbd>+<kbd>p</kbd> | `resize_pane` |

##### Key Table: `resize_font`

| Keys           | Action                          |
| -------------- | ------------------------------- |
| <kbd>k</kbd>   | `IncreaseFontSize`              |
| <kbd>j</kbd>   | `DecreaseFontSize`              |
| <kbd>r</kbd>   | `ResetFontSize`                 |
| <kbd>q</kbd>   | `PopKeyTable` <sub>(exit)</sub> |
| <kbd>Esc</kbd> | `PopKeyTable` <sub>(exit)</sub> |

##### Key Table: `resize_pane`

| Keys           | Action                                         |
| -------------- | ---------------------------------------------- |
| <kbd>k</kbd>   | `AdjustPaneSize` <sub>(Direction: Up)</sub>    |
| <kbd>j</kbd>   | `AdjustPaneSize` <sub>(Direction: Down)</sub>  |
| <kbd>h</kbd>   | `AdjustPaneSize` <sub>(Direction: Left)</sub>  |
| <kbd>l</kbd>   | `AdjustPaneSize` <sub>(Direction: Right)</sub> |
| <kbd>q</kbd>   | `PopKeyTable` <sub>(exit)</sub>                |
| <kbd>Esc</kbd> | `PopKeyTable` <sub>(exit)</sub>                |

</details>

&nbsp;

### References/Inspirations

- <https://github.com/rxi/lume>
- <https://github.com/catppuccin/wezterm>
- <https://github.com/wez/wezterm/discussions/628#discussioncomment-1874614>
- <https://github.com/wez/wezterm/discussions/628#discussioncomment-5942139>
