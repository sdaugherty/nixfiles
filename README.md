# NixOS Configurations

My personal NixOS configurations using Flakes for system-wide and user-specific settings.

Home Manager may be implemented at some point in the future, but is not active currently.

## 📁 Repository Structure

- `flake.nix`: The entry point for all system configurations.
- `hosts/`: Host-specific configurations (e.g., `mystra`, `sune`, `akadi`).
- `modules/`: Shared modules for apps, development, gaming, hardware, and desktop environments.
- `home-manager/`: User-specific configurations (to eventually be managed via Home Manager).
- `nix-apply`: A convenience script to test, apply, and commit changes.

## 🚀 Usage

### Applying a configuration

To apply the configuration for a specific host manually:

```bash
# For mystra
sudo nixos-rebuild switch --flake .#mystra

# For sune
sudo nixos-rebuild switch --flake .#sune

# For akadi
sudo nixos-rebuild switch --flake .#akadi
```

### Recommended Workflow: `nix-apply`

I use the `./nix-apply` script to handle the rebuild process. It:
1. Detects the current hostname.
2. Runs `nixos-rebuild test` to verify changes.
3. Runs `nixos-rebuild switch` to apply them.
4. Commits the changes to Git with the new system generation info.

```bash
./nix-apply
```

## 🛠️ Customization

### Adding or Configuring a Module
Shared configurations are located in `modules/`. You can enable or disable these modules in each host's `configuration.nix`:

```nix
myConfig.modules = {
  apps.enable = true;
  dev.enable = true;
  gaming.enable = true;
  kde.enable = true;
  nvidia.enable = true;
  amd.enable = false;
};
```

### Updating Nixpkgs
To update the dependencies (like the latest `nixpkgs` or `home-manager` versions):

```bash
nix flake update
```

## 🖥️ Managed Hosts

| Host | Description | Primary Hardware |
| :--- | :--- | :--- |
| **mystra** | Main Desktop | NVIDIA GPU |
| **sune** | Secondary PC | AMD GPU |
| **akadi** | Steam Deck | Handheld |

---
*Maintained by Stephanie Daugherty*
