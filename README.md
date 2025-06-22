# scripts

ade's scripts. install with `make install`. have fun.

## Usage

This repository is a collection of useful scripts that provide basic tools and utilities for Mac OS and Linux systems.

To install the scripts, run `make install` from the root of this repository.

All scripts in `./bin` will be symlinked to `~/.local/bin`, where the file extension of the source file is stripped in the destination file.

To use the scripts, ensure that `$HOME/.local/bin` is on your `$PATH`, by including `export PATH=$HOME/.local/bin:$PATH` in your `~/.profile`, `~/.bashrc`, `~/.zshrc`, or otherwise for your shell.

## Development

The `Makefile` at the root of this repository will call the script at `./dev/bin/main.sh` where the name of any target corresponds to the command executed.

For example, running `make install` will run `./dev/bin/main.sh install`, which will subsequently call `./dev/bin/install.sh`.

The scripts under `./dev/bin` is used for all development and installation related tasks.

The `./dev/bin/main.sh` has the following commands:

* `build`: Calls `./dev/bin/build.sh`, which copies the `./src/bin` directory to `./dist`.
* `clean`: Calls `./dev/bin/clean.sh`, which deletes the `./dist` directory (if it exists).
* `copy`: Calls `./dev/bin/copy.sh`, which copies the contents of `./dist` into `~/.local/share/scripts` (if it does not exist).
* `install`: Calls `./dev/bin/install.sh`, which runs the `test`, `clean`, `build`, `uninstall`, `copy`, and `link` commands in that order.
* `help`: Calls `./dev/bin/help.sh`, which displays the help text.
* `link`: Calls `./dev/bin/link.sh`, which symlinks all scripts from `~/.local/share/scripts/bin` to `~/.local/bin` if none of the destination files exist, where the file extension of the source file is stripped in the destination file.
* `test`: Calls `./dev/bin/test.sh`, which runs all of the tests in the `./tests` directory.
* `uninstall`: Calls `./dev/bin/uninstall.sh`, which deletes all the symlinks from `~/.local/share/scripts/bin` to `~/.local/bin`, and deletes the `~/.local/share/scripts` directory and all its contents if it exists.

There is additionally `./dev/bin/env.sh`, which provides environment variables for the other scripts under `./dev/bin`.

If no command is passed to the script, or the script is called with `help`, `--help` or `-h`, then the `help` command will be executed.

## Contributing

If you find an issue with the scripts, cut an issue at [github.com/adeposting/scripts](https://github.com/adeposting/scripts).

If you want to add a feature, fix a bug, add a unit test, or otherwise, open a pull request.

## See Also

For more cool things and stuff by ade, check out [adeposting.com](https://adeposting.com).