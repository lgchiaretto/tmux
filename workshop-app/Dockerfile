# Stage 1: Build frontend using Fedora
FROM quay.io/fedora/fedora:43 AS frontend-builder

USER 0

# Install Node.js and npm
RUN dnf install -y nodejs npm && dnf clean all

WORKDIR /frontend

COPY workshop-app/package*.json ./
RUN npm install

COPY workshop-app/ .
RUN npm run build

# Stage 2: Setup backend and final image using Fedora
FROM quay.io/fedora/fedora:43

USER 0

# Install system dependencies including xclip and Node.js
RUN dnf install -y \
    bash \
    curl \
    git \
    vim-enhanced \
    python3 \
    python3-pip \
    make \
    gcc-c++ \
    ncurses \
    libevent \
    findutils \
    procps-ng \
    nodejs \
    npm \
    xclip \
    && dnf clean all

# Install FZF from GitHub (latest release)
RUN FZF_VERSION=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    curl -L "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION#v}-linux_amd64.tar.gz" | tar xz -C /usr/local/bin && \
    chmod +x /usr/local/bin/fzf

# Install fzf-tmux script
RUN curl -L "https://raw.githubusercontent.com/junegunn/fzf/master/bin/fzf-tmux" -o /usr/local/bin/fzf-tmux && \
    chmod +x /usr/local/bin/fzf-tmux

# Install FZF shell integration
RUN mkdir -p /usr/local/share/fzf/shell && \
    curl -L "https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.bash" -o /usr/local/share/fzf/shell/completion.bash && \
    curl -L "https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.bash" -o /usr/local/share/fzf/shell/key-bindings.bash

WORKDIR /app

# Install Node.js backend
COPY workshop-app/server/package*.json ./
RUN npm install --omit=dev

COPY workshop-app/server/server.js ./
COPY --from=frontend-builder /frontend/dist ./dist

RUN mkdir -p /app/guides/pt /app/guides/en

# Copy guides
COPY workshop-app/guides/ /app/guides/

# Download and install static tmux binary
RUN curl -L -o /usr/local/bin/tmux "https://github.com/lgchiaretto/tmux/releases/download/v3.6/tmux.linux-amd64.stripped" && \
    chmod +x /usr/local/bin/tmux

# Download and install OpenShift CLI (oc)
RUN curl -L "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz" | tar xz -C /usr/local/bin oc kubectl && \
    chmod +x /usr/local/bin/oc /usr/local/bin/kubectl

# Install tmux plugin manager (TPM)
RUN git clone https://github.com/tmux-plugins/tpm /opt/tpm && \
    chmod -R 755 /opt/tpm

# Create tmux-ocp directory structure for scripts
RUN mkdir -p /usr/local/share/tmux-ocp/fzf-files

# Download vim-plug from GitHub
RUN mkdir -p /etc/skel/.vim/autoload /etc/skel/.tmux && \
    curl -fLo /etc/skel/.vim/autoload/plug.vim \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Copy tmux configuration for workshop (simplified, without OCP cluster info)
COPY --chown=1001:0 workshop-app/tmux-config/tmux.conf /etc/skel/.tmux.conf
COPY --chown=1001:0 workshop-app/tmux-config/bashrc /etc/skel/.bashrc
COPY --chown=1001:0 workshop-app/tmux-config/vimrc /etc/skel/.vimrc
COPY --chown=1001:0 dotfiles/dircolors /etc/skel/.dircolors
COPY --chown=1001:0 dotfiles/inputrc /etc/skel/.inputrc
COPY --chown=1001:0 dotfiles/bash_functions /etc/skel/.bash_functions

# Copy config.sh for tmux scripts
COPY --chown=1001:0 workshop-app/tmux-config/config.sh /etc/skel/.tmux/config.sh

# Copy FZF scripts from main project
COPY --chown=1001:0 fzf-files/ /usr/local/share/tmux-ocp/fzf-files/
RUN chmod +x /usr/local/share/tmux-ocp/fzf-files/*.sh 2>/dev/null || true && \
    chmod +x /usr/local/share/tmux-ocp/fzf-files/*.tmux 2>/dev/null || true

# Setup user home with tmux config
RUN mkdir -p /home/default/.tmux/plugins /home/default/.vim/autoload /home/default/.ssh /home/default/.cache && \
    cp -r /etc/skel/.* /home/default/ 2>/dev/null || true && \
    cp -r /opt/tpm /home/default/.tmux/plugins/tpm && \
    chown -R 1001:0 /home/default && \
    chmod -R g=u /home/default && \
    chmod 700 /home/default/.ssh

# Configure Git globally
RUN git config --system user.name "Workshop User" && \
    git config --system user.email "workshop@tmux.local" && \
    git config --system init.defaultBranch main && \
    git config --system core.editor vim && \
    git config --system pull.rebase false

RUN chown -R 1001:0 /app && \
    chmod -R g=u /app

USER 1001

EXPOSE 8080

ENV PORT=8080
ENV GUIDES_DIR=/app/guides
ENV DEFAULT_LANG=pt
ENV SHELL=/bin/bash
ENV HOME=/home/default
ENV USE_TMUX=true

CMD ["node", "server.js"]
