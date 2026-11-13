# Ramon Mello's Homebrew tap

Formulae for [Homebrew](https://brew.sh) by Ramon Mello.

| Formula | Description |
| --- | --- |
| [`tmux-agent-usage`](Formula/tmux-agent-usage.rb) | AI coding agent subscription usage for the tmux status line ([project](https://github.com/ramonmello/tmux-agent-usage)) |

## Install

```sh
brew install ramonmello/tap/tmux-agent-usage
```

Use the full name the first time: Homebrew only loads formulae from taps you
trust, and installing by full name trusts that formula. After that, the short
name works. To trust every formula in this tap at once, run
`brew trust ramonmello/tap`.

Upgrade with `brew update && brew upgrade tmux-agent-usage`. Remove with
`brew uninstall tmux-agent-usage` and, if nothing else uses the tap,
`brew untap ramonmello/tap`.

The formulae build from source; there are no bottles yet. Each project's own
README covers setup after installation.

## Maintaining

Each formula pins a release by its full commit and the SHA-256 of GitHub's
source archive for that commit. To release a new version of
`tmux-agent-usage`:

1. In a clean clone of the project, take the tag's commit:
   `git rev-parse 'vX.Y.Z^{commit}'`.
2. Download
   `https://github.com/ramonmello/tmux-agent-usage/archive/COMMIT.tar.gz` and
   compute its SHA-256 (`shasum -a 256` or `sha256sum`).
3. Update `url`, `version` and `sha256` together in the formula.
4. Check the formula against that source tree, without Homebrew:
   `test/check-formula /path/to/tmux-agent-usage`. It runs the formula's fetch,
   install and test methods with the real Cargo in a temporary root and fails
   if the formula starts an AI client, the Keychain, curl or tmux. It needs
   Ruby and Cargo.
5. Then run Homebrew's own checks in an isolated prefix (a VM, container or a
   separate Homebrew checkout, never your everyday prefix):

   ```sh
   brew style --formula ramonmello/tap/tmux-agent-usage
   brew audit --strict --online --formula ramonmello/tap/tmux-agent-usage
   brew install --build-from-source ramonmello/tap/tmux-agent-usage
   brew test ramonmello/tap/tmux-agent-usage
   ```

A changed archive must fail the checksum; investigate instead of accepting a
new hash. Formulae never download binaries or add an updater.

## License

[MIT](LICENSE).
