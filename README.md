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

### Features

- [**Background Image Selector**](https://github.com/KevinSilvester/wezterm-config/blob/master/utils/backdrops.lua)

  Uses `wezterm.read_dir` to scan the `backdrops` directory for images.

  - Usage:
    - `SUPER /`: Select random image
    - `SUPER ,`: Cycle images forward
    - `SUPER .`: Cycle images backwards
    - `SUPER_REV /`: Fuzzy select image

- [**GPU Adapter Selector**](https://github.com/KevinSilvester/wezterm-config/blob/master/utils/gpu_adapter.lua)

  A small utility to select the best GPU + Adapter (graphics API) combo for your machine.

  Adapter is selected based on the following criteria:

  1.  Best GPU available (`Discrete` > `Integrated` > `Other` (for wgpu's OpenGl implementation on Discrete GPU) > `Cpu`)
  2.  Best graphics API available (based off my very scientific scroll a big log file in neovim test 😁)

  <details>
    <summary>Graphics API choices are based on the platform:</summary>
      > see: <https://github.com/gfx-rs/wgpu#supported-platforms> for more info

      - Windows: `Dx12` > `Vulkan` > `OpenGl`
      - Linux: `Vulkan` > `OpenGl`
      - Mac: `Metal`

  </details>

### References/Links

- <https://github.com/rxi/lume>
- <https://github.com/catppuccin/wezterm>
- <https://github.com/wez/wezterm/discussions/628#discussioncomment-1874614>
- <https://github.com/wez/wezterm/discussions/628#discussioncomment-5942139>
