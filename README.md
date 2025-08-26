# Moderne CLI Version Manager

This is a wrapper script for managing installed versions of the [Moderne CLI](https://docs.moderne.io/user-documentation/moderne-cli/getting-started/cli-intro#installation-and-configuration), similar to [NVM](https://github.com/nvm-sh/nvm) or [SDKMan](https://sdkman.io/).

You can download the Moderne CLI through your Moderne tenant's web UI (or by creating an account on the public shared tenant at [app.moderne.io](https://app.moderne.io)).  You can also use your favorite package manager to download the latest stable or experimental versions for your system.

If you need to install a _specific_ version of the CLI, this script automates the process described in Moderne's [airgapped installation procedure](https://docs.moderne.io/user-documentation/moderne-cli/getting-started/dx-cli-install).  The installation script does the following:

1. Sets up a shell script in `$HOME/.moderne/modvm.sh` that provides the version manager functionality.
1. Adds an entry to your bash and zsh shell configuration to source the `modvm.sh` script.

## Installation

