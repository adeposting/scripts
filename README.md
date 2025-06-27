# scripts

ade's scripts.

tldr clone and just `make`.

mac os and linux only.

have fun.

## Usage

install with `make install`.

copies `./src` to `~/.local/share/scripts`.

links `~/.local/share/scripts/*.sh` to `~/.local/bin`.

ensure `$HOME/.local/bin` is on `$PATH`.

reinstall with `scripts install`.

uninstall with `scripts uninstall`.

## Development

`Makefile` wraps calls to `./src/scripts.sh`.

use `./src/scripts.sh --help` for help.

or see `scripts_help` function.

### Test

test with `make test`.

runs tests in isolated environments using Docker.

`make test` calls `test-all` target in `./dev/docker/Makefile`.

to run os specific test for mac/linux:

```bash
# Navigate to docker directory
cd dev/docker

# Test in Arch Linux container
make test-linux

# Test in macOS-like container  
make test-darwin

# Test in both environments
make test-all
```

see `dev/docker/README.md` for details.

## Contributing

find an issue? open an issue.

got a change? open a PR.

dm me if i don't see it

info below.

## Contact

`@adeposting` on x.com.

dms open.

## License

MIT
