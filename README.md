# Moderne CLI Version Manager

This is a wrapper script for managing installed versions of the [Moderne CLI](https://docs.moderne.io/user-documentation/moderne-cli/getting-started/cli-intro#installation-and-configuration), similar to [NVM](https://github.com/nvm-sh/nvm) or [SDKMan](https://sdkman.io/).

You can download the Moderne CLI through your Moderne tenant's web UI (or by creating an account on the public shared tenant at [app.moderne.io](https://app.moderne.io)).  You can also use your favorite package manager to download the latest stable or experimental versions for your system.

If you need to install a _specific_ version of the CLI, this script automates the process described in Moderne's [airgapped installation procedure](https://docs.moderne.io/user-documentation/moderne-cli/getting-started/dx-cli-install).  The installation script does the following:

1. Sets up a shell script in `$HOME/.moderne/modvm.sh` that provides the version manager functionality.
1. Adds an entry to your bash and zsh shell configuration to source the `modvm.sh` script.

## Installation

Take a look at the install script before you run it!

You can install or update `modvm` in one command by running it with your shell:

```bash
curl -s "https://raw.githubusercontent.com/mtthwcmpbll/modvm/refs/heads/main/install.sh" | bash
```

## Usage

After installation, you can use the following commands to manage your Moderne CLI versions:

### Install a specific version
```bash
modvm install <version>
```
Downloads and installs a specific version of the Moderne CLI from Maven Central. The newly installed version will automatically become active.

Example:
```bash
modvm install 3.21.1
```

### Switch to an installed version
```bash
modvm use <version>
```
Switches to a previously installed version of the Moderne CLI.

Example:
```bash
modvm use 3.21.1
```

### List installed versions
```bash
modvm list
```
Shows all locally installed versions of the Moderne CLI. The currently active version is marked with an asterisk (*).

### List available remote versions
```bash
modvm list-remote
```
Fetches and displays all available versions from Maven Central. Shows which versions are installed locally and which one is currently active.

### Show current version
```bash
modvm current
```
Displays the currently active version of the Moderne CLI.

### Uninstall a version
```bash
modvm uninstall <version>
```
Removes a specific version from your local installation. If you uninstall the currently active version, the `mod` command will no longer be available until you switch to another version.

Example:
```bash
modvm uninstall 3.21.1
```

### Get help
```bash
modvm help
```
Shows the help message with all available commands and examples.

### Using the Moderne CLI

Once you have installed and activated a version using `modvm`, the `mod` command will be available in your shell:

```bash
mod --version
mod --help
```

The `mod` alias is automatically updated when you install or switch versions using `modvm`.  Take a look at the official [Moderne documentation](https://docs.moderne.io/user-documentation/moderne-cli/getting-started/cli-intro) to get started interacting with your codebase with the CLI.

