# NixOS Configuration (Flakes & Home Manager)

This repository contains the NixOS system and user configurations for multiple hosts, managed using Nix Flakes.

## Project Overview

- **Technologies**: NixOS, Nix Flakes, Home Manager, Bash.
- **Architecture**:
  - **Flake Entrypoint**: `flake.nix` defines the system inputs and host configurations (`nixosConfigurations`).
  - **Hosts**: Located in `hosts/<hostname>/`.
    - **Workstations (x86_64)**: `mystra`, `sune`, `akadi`.
    - **Servers (x86_64)**: `lathander`, `istishia`.
    - **Servers (aarch64)**: `waukeen` (Raspberry Pi).
    - Each host has a `configuration.nix` (main config) and `hardware-configuration.nix` (hardware specs).
  - **Modular Design**: Found in `modules/`. Modules are split into `_cli` and `_desktop` versions to allow headless server configurations without GUI dependencies.
  - **Custom Options**: Modules are enabled/disabled per-host using the `myConfig.modules.<name>.enable` pattern.
  - **User Config**: Managed via Home Manager in `home-manager/home.nix`.

## Building and Running

### Applying Configuration
To apply the configuration for a specific host (e.g., `mystra`):
```bash
sudo nixos-rebuild switch --flake .#mystra
```

### Testing Configuration
To test the configuration without making it the default boot entry:
```bash
sudo nixos-rebuild test --flake .#mystra
```

### Automated Workflow
The project includes a `nix-apply` script that automates the deployment process:
1. Detects current hostname.
2. Runs `nixos-rebuild test`.
3. If successful, runs `nixos-rebuild switch`.
4. Automatically commits changes to Git with system generation info.

```bash
./nix-apply
```

## Development Conventions

### Adding a New Module
1. Create a new file in `modules/` (e.g., `modulename_cli.nix` or `modulename_desktop.nix`).
2. Define the option: `options.myConfig.modules.<name>.enable = lib.mkEnableOption "Description";`.
3. Wrap configuration in `config = lib.mkIf config.myConfig.modules.<name>.enable { ... };`.
4. Import the new module in `modules/common.nix`.

### Configuring a Host
1. Edit `hosts/<hostname>/configuration.nix`.
2. Toggle features in the `myConfig.modules` block.
   - For **workstations**, enable both `_cli` and `_desktop` modules.
   - For **servers**, enable only the `_cli` modules.

   ```nix
   myConfig.modules = {
     common_cli.enable = true;
     common_desktop.enable = true; # Workstation only
     apps_cli.enable = true;
     apps_desktop.enable = true; # Workstation only
     dev_cli.enable = true;
     # ...
   };
   ```

### Updating Nixpkgs
To update the `flake.lock` file:
```bash
nix flake update
```
