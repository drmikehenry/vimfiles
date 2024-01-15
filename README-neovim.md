These are work-in-progress notes about using vimfiles with Neovim.

# Install Neovim

    wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz

    # As root:
    cd /opt
    tar -zxf .../nvim-linux64.tar.gz
    ln -s /opt/nvim-linux64/bin/nvim /usr/local/bin/

# Install pynvim for Python-based plugins

    # Choose installation location.
    # Vimfiles will detect pynvim at any of these locations:
    #   ~/venvs/pynvim
    #   /opt/pynvim
    cd /opt
    python -m venv pynvim
    . pynvim/bin/activate
    pip install pynvim

Vimfiles will then point to the Python interpreter in this venv for `pynvim`
support via:

    let g:python3_host_prog = '/opt/pynvim/env/bin/python'

# Install Neovim-qt

    sudo apt-get install neovim-qt

Invoke via `nvim-qt`.  The packed version of `neovim-qt` is older than Neovim
0.9.1 but it works well.

# Install Neovide

Building is offline-only at this point.

- Install dependencies:

      sudo apt-get install -y \
        curl \
        gnupg \
        ca-certificates \
        git \
        gcc-11-multilib \
        g++-11-multilib \
        cmake \
        libssl-dev \
        pkg-config \
        libfreetype6-dev \
        libasound2-dev \
        libexpat1-dev \
        libxcb-composite0-dev \
        libbz2-dev \
        libsndio-dev \
        freeglut3-dev \
        libxmu-dev \
        libxi-dev \
        libfontconfig1-dev \
        libxcursor-dev

- Install using Cargo:

      cargo install --git https://github.com/neovide/neovide

# Install dependencies

## telescope dependencies

    # On Ubuntu:
    sudo apt-get install fd-find
    sudo ln -s /usr/bin/fdfind /usr/local/bin/fd

    # Alternatively, install via Cargo:
    cargo install fd-find

## LSP dependencies

## Python LSP dependencies

Note: `pipxg` is a wrapper script that uses `pipx` to install packages globally.
Alternatively, use `python -m pip install --user`.

    pipxg install ruff
    pipxg install python-lsp-server
    pipxg inject python-lsp-server python-lsp-black
    pipxg inject python-lsp-server pylsp-mypy
    pipxg inject python-lsp-server python-lsp-ruff

## LUA LSP dependencies

- Acquire `lua-language-server` binaries:
  <https://github.com/LuaLS/lua-language-server/releases/download/3.7.4/lua-language-server-3.7.4-linux-x64.tar.gz>

- Install from pre-built binaries:

  - Install globally (preferred):

      sudo mkdir -p /opt/lua-language-server
      sudo tar -C /opt/lua-language-server -xf \
        lua-language-server-3.7.4-linux-x64.tar.gz
      sudo ln -s /opt/lua-language-server/bin/lua-language-server /usr/local/bin

  - Alternatively, install in `~/.local/lua-language-server`:

      mkdir -p ~/.local/bin
      mkdir -p ~/.local/lua-language-server
      tar -C ~/.local/lua-language-server -xf \
        lua-language-server-3.7.4-linux-x64.tar.gz
      ln -s ~/.local/lua-language-server/bin/lua-language-server \
        ~/.local/bin

    **NOTE** Ensure `~/.local/bin/` is in the `PATH`.

- If desired, may install from source:

  - Acquire sources:

        git clone https://github.com/sumneko/lua-language-server
        cd lua-language-server/
        git submodule update --init --recursive


  - May need to install `libstdc++-static` for the build to complete.

  - Build:

        cd 3rd/luamake
        compile/install.sh
        cd ../..
        ./3rd/luamake/luamake rebuild

# Setup `init.lua` for vimfiles

- Create `~/.config/nvim/init.lua`:

      -- Optional for changing `VIMUSER`:
      -- if not vim.env['VIMUSER'] then
      --     vim.env['VIMUSER'] = 'drmikehenry'
      -- end
      vim.cmd('source ~/.vim/init.lua')
