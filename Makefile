# ~/dotfiles/Makefile
#
# Usage:
#   make restore          # restore configs, tools, and build user-local tools
#   make sysdeps          # install Debian packages that need sudo
#   make configs          # copy shell/tmux/nvim configs
#   make user-tools       # copy dotfiles/tools/* to ~/.local/bin/
#   make cmake
#   make libevent
#   make tmux
#   make neovim
#   make codex
#   make check

SHELL := /bin/bash

DOTFILES := $(CURDIR)

HOME_DIR := $(HOME)

LOCAL := $(HOME_DIR)/.local
LOCAL_BIN := $(LOCAL)/bin
CONFIG_DIR := $(HOME_DIR)/.config

OPT := $(HOME_DIR)/opt
SRC := $(OPT)/src

# Match your actual PATH:
# PATH=$HOME/.npm-global/bin:/opt/node-v6.4.0-linux-x64/bin:$HOME/opt/neovim/bin:$HOME/.local/bin:$HOME/opt/tmux-3.6a/bin:$PATH
NPM_PREFIX := $(HOME_DIR)/.npm-global
NODE_BIN := /opt/node-v6.4.0-linux-x64/bin

CMAKE_VERSION := 3.18.4
CMAKE_DIR := cmake-$(CMAKE_VERSION)-Linux-x86_64
CMAKE_TARBALL := $(CMAKE_DIR).tar.gz
CMAKE_URL := https://github.com/Kitware/CMake/releases/download/v$(CMAKE_VERSION)/$(CMAKE_TARBALL)

LIBEVENT_PREFIX := $(OPT)/libevent
LIBEVENT_SRC := $(SRC)/libevent

TMUX_VERSION := 3.6a
TMUX_DIR := tmux-$(TMUX_VERSION)
TMUX_TARBALL := $(TMUX_DIR).tar.gz
TMUX_URL := https://github.com/tmux/tmux/releases/download/$(TMUX_VERSION)/$(TMUX_TARBALL)
TMUX_PREFIX := $(OPT)/tmux-$(TMUX_VERSION)

NEOVIM_SRC := $(SRC)/neovim
NEOVIM_PREFIX := $(OPT)/neovim

RESTORE_PATH := $(NPM_PREFIX)/bin:$(NODE_BIN):$(NEOVIM_PREFIX)/bin:$(LOCAL_BIN):$(TMUX_PREFIX)/bin:$(PATH)

.PHONY: help restore dirs sysdeps configs user-tools cmake libevent tmux neovim codex codex-extra check clean-build

help:
	@echo "Targets:"
	@echo "  make restore       Restore configs, tools, cmake, libevent, tmux, neovim, codex"
	@echo "  make sysdeps       Install Debian packages with sudo"
	@echo "  make configs       Copy dotfiles/config files to home"
	@echo "  make user-tools    Copy dotfiles/tools/* to ~/.local/bin/"
	@echo "  make cmake         Install CMake $(CMAKE_VERSION) to ~/.local"
	@echo "  make libevent      Build libevent to $(LIBEVENT_PREFIX)"
	@echo "  make tmux          Build tmux $(TMUX_VERSION) to $(TMUX_PREFIX)"
	@echo "  make neovim        Build neovim stable to $(NEOVIM_PREFIX)"
	@echo "  make codex         Install @openai/codex under $(NPM_PREFIX)"
	@echo "  make check         Show installed tool versions"

restore: dirs configs user-tools cmake libevent tmux neovim codex check

dirs:
	mkdir -p "$(LOCAL_BIN)" "$(CONFIG_DIR)" "$(OPT)" "$(SRC)" "$(NPM_PREFIX)"

# Debian packages that need sudo.
# ripgrep and ninja-build are installed system-wide here.
sysdeps:
	sudo apt-get update
	sudo apt-get install -y \
	  ripgrep \
	  ninja-build \
	  build-essential \
	  git \
	  wget \
	  curl \
	  pkg-config \
	  libncurses-dev \
	  bison \
	  gettext \
	  unzip \
	  ca-certificates

configs: dirs
	echo "==> Copy shell and tmux configs"
	cp -a "$(DOTFILES)"/config/.bash* "$(HOME_DIR)"/ 2>/dev/null || true
	[ ! -f "$(DOTFILES)/config/.tmux.conf" ] || cp -a "$(DOTFILES)/config/.tmux.conf" "$(HOME_DIR)/.tmux.conf"
	if [ -d "$(DOTFILES)/config/nvim" ]; then \
	  mkdir -p "$(CONFIG_DIR)"; \
	  rm -rf "$(CONFIG_DIR)/nvim"; \
	  cp -a "$(DOTFILES)/config/nvim" "$(CONFIG_DIR)/nvim"; \
	fi

user-tools: dirs
	echo "==> Copy user tools to ~/.local/bin"
	if [ -d "$(DOTFILES)/tools" ]; then \
	  cp -a "$(DOTFILES)"/tools/* "$(LOCAL_BIN)"/; \
	  chmod +x "$(LOCAL_BIN)"/* 2>/dev/null || true; \
	fi

cmake: dirs
	echo "==> Install CMake $(CMAKE_VERSION) to ~/.local"
	if [ -x "$(LOCAL_BIN)/cmake" ] && "$(LOCAL_BIN)/cmake" --version | grep -q "$(CMAKE_VERSION)"; then \
	  echo "CMake $(CMAKE_VERSION) already installed"; \
	else \
	  cd "$(SRC)"; \
	  [ -f "$(CMAKE_TARBALL)" ] || wget -O "$(CMAKE_TARBALL)" "$(CMAKE_URL)"; \
	  rm -rf "$(CMAKE_DIR)"; \
	  tar xzf "$(CMAKE_TARBALL)"; \
	  cp -a "$(CMAKE_DIR)"/bin "$(LOCAL)"/; \
	  cp -a "$(CMAKE_DIR)"/doc "$(LOCAL)"/ 2>/dev/null || true; \
	  cp -a "$(CMAKE_DIR)"/man "$(LOCAL)"/ 2>/dev/null || true; \
	  cp -a "$(CMAKE_DIR)"/share "$(LOCAL)"/; \
	fi
	"$(LOCAL_BIN)/cmake" --version

libevent: dirs cmake
	echo "==> Build libevent"
	if [ ! -d "$(LIBEVENT_SRC)/.git" ]; then \
	  rm -rf "$(LIBEVENT_SRC)"; \
	  git clone https://github.com/libevent/libevent.git "$(LIBEVENT_SRC)"; \
	fi
	cd "$(LIBEVENT_SRC)" && \
	  mkdir -p build && \
	  cd build && \
	  "$(LOCAL_BIN)/cmake" .. -DCMAKE_INSTALL_PREFIX="$(LIBEVENT_PREFIX)" && \
	  make -j"$$(nproc)" && \
	  make install
	echo "libevent installed to $(LIBEVENT_PREFIX)"

tmux: dirs libevent
	echo "==> Build tmux $(TMUX_VERSION)"
	cd "$(SRC)" && \
	  [ -f "$(TMUX_TARBALL)" ] || wget -O "$(TMUX_TARBALL)" "$(TMUX_URL)"
	cd "$(SRC)" && \
	  rm -rf "$(TMUX_DIR)" && \
	  tar xzf "$(TMUX_TARBALL)"
	cd "$(SRC)/$(TMUX_DIR)" && \
	  PKG_CONFIG_PATH="$(LIBEVENT_PREFIX)/lib/pkgconfig" \
	  CPPFLAGS="-I$(LIBEVENT_PREFIX)/include" \
	  LDFLAGS="-L$(LIBEVENT_PREFIX)/lib -Wl,-rpath,$(LIBEVENT_PREFIX)/lib" \
	  ./configure --prefix="$(TMUX_PREFIX)" && \
	  make -j"$$(nproc)" && \
	  make install
	ln -sfn "$(TMUX_PREFIX)/bin/tmux" "$(LOCAL_BIN)/tmux"
	"$(TMUX_PREFIX)/bin/tmux" -V

neovim: dirs cmake
	echo "==> Build neovim stable"
	if [ ! -d "$(NEOVIM_SRC)/.git" ]; then \
	  rm -rf "$(NEOVIM_SRC)"; \
	  git clone https://github.com/neovim/neovim.git "$(NEOVIM_SRC)"; \
	fi
	cd "$(NEOVIM_SRC)" && \
	  git fetch --tags origin && \
	  git switch --detach stable && \
	  make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX="$(NEOVIM_PREFIX)" && \
	  make install
	ln -sfn "$(NEOVIM_PREFIX)/bin/nvim" "$(LOCAL_BIN)/nvim"
	"$(NEOVIM_PREFIX)/bin/nvim" --version | head -n 3
	if [ -d "$(DOTFILES)/config/nvim" ]; then \
	  mkdir -p "$(CONFIG_DIR)"; \
	  rm -rf "$(CONFIG_DIR)/nvim"; \
	  cp -a "$(DOTFILES)/config/nvim" "$(CONFIG_DIR)/nvim"; \
	fi

codex: dirs
	echo "==> Install Codex CLI using user-local npm prefix: $(NPM_PREFIX)"
	if [ -x "$(NODE_BIN)/npm" ]; then \
	  PATH="$(NODE_BIN):$$PATH" npm config set prefix "$(NPM_PREFIX)"; \
	  PATH="$(NODE_BIN):$(NPM_PREFIX)/bin:$$PATH" npm install -g @openai/codex; \
	elif command -v npm >/dev/null 2>&1; then \
	  npm config set prefix "$(NPM_PREFIX)"; \
	  PATH="$(NPM_PREFIX)/bin:$$PATH" npm install -g @openai/codex; \
	else \
	  echo "ERROR: npm not found."; \
	  echo "Expected npm in $(NODE_BIN) or current PATH."; \
	  exit 1; \
	fi
	ln -sfn "$(NPM_PREFIX)/bin/codex" "$(LOCAL_BIN)/codex"
	"$(NPM_PREFIX)/bin/codex" --version || true
	@echo
	@echo "Use this PATH:"
	@echo '  export PATH="$$HOME/.npm-global/bin:/opt/node-v6.4.0-linux-x64/bin:$$HOME/opt/neovim/bin:$$HOME/.local/bin:$$HOME/opt/tmux-3.6a/bin:$$PATH"'

# Optional: restore Codex skills / AGENTS.md if you keep them in dotfiles.
#
# Expected optional layout:
#   ~/dotfiles/codex/skills/*
#   ~/dotfiles/codex/AGENTS.md
#
# This intentionally does not copy ~/.codex/auth.json.
codex-extra: dirs
	echo "==> Optional Codex extras"
	mkdir -p "$(HOME_DIR)/.codex"
	if [ -d "$(DOTFILES)/codex/skills" ]; then \
	  mkdir -p "$(HOME_DIR)/.codex/skills"; \
	  cp -a "$(DOTFILES)/codex/skills/"* "$(HOME_DIR)/.codex/skills/"; \
	fi
	if [ -f "$(DOTFILES)/codex/AGENTS.md" ]; then \
	  cp -a "$(DOTFILES)/codex/AGENTS.md" "$(HOME_DIR)/AGENTS.md"; \
	fi

check:
	echo "==> Version check"
	echo "--- expected PATH ---"
	echo "$(RESTORE_PATH)"
	echo
	echo "--- ripgrep ---"
	PATH="$(RESTORE_PATH)" command -v rg >/dev/null 2>&1 && PATH="$(RESTORE_PATH)" rg --version | head -n 1 || echo "rg not found"
	echo
	echo "--- cmake ---"
	if [ -x "$(LOCAL_BIN)/cmake" ]; then "$(LOCAL_BIN)/cmake" --version | head -n 1; else echo "cmake not found at $(LOCAL_BIN)/cmake"; fi
	echo
	echo "--- libevent ---"
	if [ -d "$(LIBEVENT_PREFIX)" ]; then echo "libevent installed at $(LIBEVENT_PREFIX)"; else echo "libevent not found at $(LIBEVENT_PREFIX)"; fi
	echo
	echo "--- tmux ---"
	if [ -x "$(TMUX_PREFIX)/bin/tmux" ]; then "$(TMUX_PREFIX)/bin/tmux" -V; else echo "tmux not found at $(TMUX_PREFIX)/bin/tmux"; fi
	echo
	echo "--- nvim ---"
	if [ -x "$(NEOVIM_PREFIX)/bin/nvim" ]; then "$(NEOVIM_PREFIX)/bin/nvim" --version | head -n 3; else echo "nvim not found at $(NEOVIM_PREFIX)/bin/nvim"; fi
	echo
	echo "--- node/npm ---"
	if [ -x "$(NODE_BIN)/node" ]; then "$(NODE_BIN)/node" --version; else command -v node >/dev/null 2>&1 && node --version || echo "node not found"; fi
	if [ -x "$(NODE_BIN)/npm" ]; then "$(NODE_BIN)/npm" --version; else command -v npm >/dev/null 2>&1 && npm --version || echo "npm not found"; fi
	echo
	echo "--- codex ---"
	if [ -x "$(NPM_PREFIX)/bin/codex" ]; then "$(NPM_PREFIX)/bin/codex" --version || true; else echo "codex not found at $(NPM_PREFIX)/bin/codex"; fi

clean-build:
	rm -rf "$(SRC)/$(CMAKE_DIR)" "$(SRC)/$(TMUX_DIR)"
	rm -rf "$(LIBEVENT_SRC)/build"
