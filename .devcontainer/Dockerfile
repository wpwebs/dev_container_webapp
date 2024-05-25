FROM python:3.12-slim

ARG USERNAME=appuser
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Install necessary packages and Zsh
RUN set -ex \
    && apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        procps \
        zsh \
        wget \
        openssh-client \
        fonts-powerline \
        tzdata \
        gcc \
        python3-dev \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # Set timezone to PDT
    && ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    # Remove imagemagick due to https://security-tracker.debian.org/tracker/CVE-2019-10131
    && apt-get purge -y imagemagick imagemagick-6-common \
    && apt-get upgrade -y \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Set Zsh as the default shell for the user by modifying /etc/passwd
RUN sed -i "s|/home/${USERNAME}:/bin/sh|/home/${USERNAME}:/usr/bin/zsh|" /etc/passwd

# Switch to non-root user
USER $USERNAME

# Install Oh My Zsh
RUN sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" --unattended

# Install Zsh plugins and theme
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

# Copy the Powerlevel10k configuration file
COPY --chown=$USERNAME:$USER_GID .dot_files/.p10k.zsh /home/${USERNAME}/.p10k.zsh

# Customize Zsh prompt
RUN echo 'if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then' >> ~/.zshrc \
    && echo '  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"' >> ~/.zshrc \
    && echo 'fi' >> ~/.zshrc \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' ~/.zshrc \
    && echo "source \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc \
    && echo "source ~/.p10k.zsh" >> ~/.zshrc

# Set the working directory
ENV WORKDIR_PATH=/code
WORKDIR $WORKDIR_PATH

COPY --chown=$USERNAME:$USER_GID ./requirements.txt ./
RUN python3 -m pip install --upgrade pip \
    && pip install --no-cache-dir --upgrade --disable-pip-version-check -r requirements.txt 

COPY --chown=$USERNAME:$USER_GID ./src ./src

# Install Jupyter
RUN pip install jupyter

# Copy the SSH keys (Ensure .ssh directory exists in the build context)
COPY --chown=$USERNAME:$USER_GID .ssh/ssh_key* /home/${USERNAME}/.ssh/
RUN chmod 700 /home/${USERNAME}/.ssh && chmod 600 /home/${USERNAME}/.ssh/* && chmod 644 /home/${USERNAME}/.ssh/*.pub

# Add SSH key to the SSH agent
RUN echo "eval \$(ssh-agent -s) && ssh-add /home/${USERNAME}/.ssh/ssh_key" >> /home/${USERNAME}/.zshrc

ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"

# Change the permissions of the script to make it executable.
RUN chmod +x ${WORKDIR_PATH}/src/entrypoint.sh

# Start the main application and keep the container running
CMD ["sh", "src/entrypoint.sh"]