# dotfiles

Personal config for my [Omarchy](https://omarchy.org/) machine, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Only files I've changed from Omarchy's defaults live here; everything else stays stock so Omarchy updates keep applying.

## Install

```bash
git clone git@github.com:pauljamesharper/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow --adopt bash ssh git hypr omarchy protonvpn
git checkout .   # put my versions back over any defaults --adopt pulled in
```

Apps the configs expect:

```bash
omarchy pkg add flatpak proton-vpn-gtk-app
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --user flathub io.github.focustimerhq.FocusTimer
```

## Packages

| Package | Files | What's changed |
|---|---|---|
| `hypr` | `~/.config/hypr/bindings.lua` | Vim-style keys (below) |
| `omarchy` | `~/.config/omarchy/shell.json` | World clock cities (Phnom Penh, LA, NY, London, Dubai), Superwhisper in the tray, Focus Timer widget right of the weather |
| | `~/.config/omarchy/bar/scripts/focustimer` | Script behind the Focus Timer bar widget |
| | `~/.config/omarchy/defaults/agent` | Default AI agent: `claude` |
| `git` | `~/.config/git/config` | Omarchy's git defaults plus my name and email |
| `bash` | `~/.bashrc` | Omarchy's bashrc plus `SSH_AUTH_SOCK` for the systemd ssh-agent |
| `ssh` | `~/.ssh/config` | `AddKeysToAgent yes` (only the config; keys are never in this repo) |
| `protonvpn` | `~/.config/autostart/proton.vpn.app.gtk.desktop` | Starts Proton VPN minimized at login |

## Keybindings

| Key | Action |
|---|---|
| `Super + H/J/K/L` | Focus window left / down / up / right |
| `Super + Shift + H/J/K/L` | Swap window left / down / up / right |
| `Super + /` | Keybindings cheatsheet (was `Super + K`) |
| `Super + Ctrl + /` | Monitor scaling up (was `Super + /`) |
| `Super + Y` / `Super + Alt + Y` | Cycle workspace layout forward / back (was `Super + L`) |
| `Super + U` | Toggle window split (was `Super + J`) |

## Focus Timer widget

Sits right of the weather in the bar. Shows the remaining time while a session runs.

- **Click**: start, pause or resume (opens Focus Timer if it isn't running)
- **Right-click**: open the Focus Timer window
- **Middle-click**: stop

Breaks take over the screen with Focus Timer's full-screen break overlay (its default `screen-overlay` setting).

## Machine setup not in this repo

- **SSH agent:** `systemctl --user enable --now ssh-agent.socket`
- **Proton VPN:** in the app's settings, set *Connect at app startup* to **US** and turn on *Start minimized*.
  The app rewrites its own config file, so it isn't stowed.
- **Default browser:** Brave, set with Omarchy's default-browser setting (`mimeapps.list` gets rewritten, so it isn't stowed).
