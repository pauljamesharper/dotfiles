# dotfiles

Paul's personal configuration for a [bazzite_mango](https://github.com/pauljamesharper/bazzite_mango)
laptop (Bazzite DX + Mango), managed with [GNU Stow](https://www.gnu.org/software/stow/).

Each top-level directory is a **package**: a slice of `$HOME` laid out exactly
as it should appear there. Stow symlinks each file into place, so editing
`~/.config/khal/config` edits the file in this repo, and `git diff` shows what
changed.

The desktop itself (Mango, the bar, rofi, dunst, themes) is not here. It ships
in the bazzite_mango image and is copied to `~/.config/mango` by
`ujust mango-setup`. This repo covers everything else.

## Quick start

On a bazzite_mango machine:

```bash
ujust dotfiles   # clone to ~/dotfiles (or pull), then stow every package
mise install     # install the CLI tools listed in the mise package
brew bundle --global   # install the Homebrew packages in ~/.Brewfile
```

`ujust dotfiles` clones over HTTPS, so it works before your SSH key is
restored, and sets the push URL to SSH. Run it again any time to pull the latest
changes and restow.

Anywhere else, with `stow` installed:

```bash
git clone git@github.com:pauljamesharper/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow */          # or name packages: stow khal khard vdirsyncer
```

## Packages

| Package | Links into `~` | What it's for |
|---|---|---|
| `alacritty` | `.config/alacritty/alacritty.toml` | Alacritty terminal. Colours come from `theme.toml`, which is generated, not tracked |
| `atuin` | `.config/atuin/config.toml` | Shell history search |
| `emacs` | `.config/emacs/`, `emacs.service`, `emacsclient.desktop` | Emacs Writing Studio config with personal modules, a daemon tied to the graphical session, and a client launcher |
| `environment` | `.config/environment.d/intel-gtk-fix.conf` | Session environment: `GSK_RENDERER=gl` for GTK 4 on Intel graphics |
| `homebrew` | `.Brewfile` | Homebrew packages (aria2, atuin, bat, eza, ripgrep, starship, zoxide…) for `brew bundle --global` |
| `gh` | `.config/gh/config.yml` | GitHub CLI settings (git over SSH) |
| `glow` | `.config/glow/glow.yml` | Markdown viewer |
| `khal` | `.config/khal/config` | Calendar (Google and EteSync), reading what vdirsyncer syncs |
| `khard` | `.config/khard/khard.conf` | Contacts (Google and EteSync), same arrangement |
| `mise` | `.config/mise/config.toml` | Global tool list: Claude Code, opencode, Ollama, Python, uv, vdirsyncer, khal, khard, todoman, beancount + beangulp, fava |
| `ollama` | `.config/systemd/user/ollama.service` | Runs `ollama serve` as a user service |
| `opencode` | `.config/opencode/opencode.jsonc` | opencode settings |
| `starship` | `.config/starship.toml` | Shell prompt |
| `vdirsyncer` | `.config/vdirsyncer/config` | Syncs calendars and contacts between Google, EteSync and local folders |
| `vscode` | `.config/Code/User/settings.json` | VS Code editor settings |

## After stowing

Some packages need a one-off step:

```bash
# Emacs: the first start downloads every package in the config, which on a
# slow connection outlasts the service's start timeout. Run it once by hand,
# and press Ctrl+C when the log goes quiet.
emacs --fg-daemon

# Services (Emacs then starts with every graphical login)
systemctl --user daemon-reload
systemctl --user enable --now emacs.service ollama.service

# Ollama model (about 5 GB; ollama.service must be running)
mise run ollama-models

# Calendars and contacts: authorise Google, then sync
vdirsyncer discover
vdirsyncer sync
```

## Secrets

No secrets live in this repo, and it is public. Anything secret comes from
[pass](https://www.passwordstore.org/) at runtime:

- vdirsyncer runs `pass etesync` for the EteSync password and
  `pass show google/vdirsyncer/client_secret` for the Google OAuth secret.
  Google's access tokens are written to `~/.vdirsyncer/`, outside the repo.
- Emacs reads the Anthropic and DeepSeek API keys through `auth-source`,
  which by default looks in `~/.authinfo.gpg`.
- For `gh`, only `config.yml` is tracked. `hosts.yml` holds the login token and
  stays local.

Restore `~/.gnupg` and `~/.password-store` before running vdirsyncer.

## Stow settings

`.stowrc` makes every `stow` run in this directory use:

- `--target=~`, so packages always land in your home folder, wherever you run
  stow from.
- `--no-folding`, so stow links individual files and never whole directories.
  Without it, `~/.config/emacs` would become a link to this repo, and
  everything Emacs writes there (packages, native-compiled files) would end up
  in git. The same applies to the calendars and contacts vdirsyncer stores
  under `~/.config/vdirsyncer`.

## Adding something new

Move the file into a package with the same path it has under `~`, then stow
the package:

```bash
mkdir -p ~/dotfiles/foo/.config/foo
mv ~/.config/foo/foo.toml ~/dotfiles/foo/.config/foo/
cd ~/dotfiles && stow foo
git add foo && git commit -m "Add foo" && git push
```

To stop managing a package, run `stow -D foo`. That removes the links and
leaves the files in the repo.

If stow reports a conflict, a real file already exists where a link should go.
Usually the app created a default config. Compare the two, keep the one you
want in the repo, delete the other from `~`, and stow again.

## What's deliberately not here

- **`~/.config/mango`**: shipped and updated by the bazzite_mango image.
- **Files apps rewrite themselves**, such as `mimeapps.list`, KDE's `*rc` files
  and GTK settings. Apps save them by replacing the file, which turns stow's
  link back into a regular file, so tracking them doesn't work.
- **Generated files**: GTK, xsettingsd and Alacritty colours come from the
  theme scripts.
- **App state and keys**: libvirt VMs, VPN clients, KDE Connect, browser
  profiles.
- **Shell startup files** (`~/.bashrc`): not tracked yet.

## Expects

Some packages call programs that aren't in the image or this repo:

- `emacsclient.desktop` runs `emacs-launch`.
- `alacritty.toml` imports `theme.toml`, written by `desk-theme`.
- Alacritty itself.
