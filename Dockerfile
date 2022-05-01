# ===================== #
# Ansible 5.x container #
# ===================== #

# Generate with command :
# sudo docker-compose up --build --no-start --remove-orphans

# Use with command :
# sudo docker-compose run ansible

## Base ##
FROM rockylinux:8.5
USER root
WORKDIR /tmp
RUN dnf makecache

## Variables ##
# Python =< 3.8
ARG PYTHON_PACKAGE="python39"

# Ansible user
ARG ANSIBLE_USER="ansible"

# Ansible 5.x
ARG ANSIBLE_VERSION="5.6.0"

## Variables but not to be messed with ##
ARG DEFAULT_HOME_DIR="/home"
ARG CONTAINER_PURPOSE_PATH="/srv"
ARG ANSIBLE_BIN_PATH="${DEFAULT_HOME_DIR}/${ANSIBLE_USER}/.local/bin"

## Official requirements ##
# Python3
RUN dnf module install \
--assumeyes \
${PYTHON_PACKAGE}

# SSH client
RUN dnf install \
--assumeyes \
openssh-clients

## Unrelated requirements ##
# Install sudo to upgrade ansible user privileges
RUN dnf install \
--assumeyes \
sudo

# Allow wheel group to use sudo without password (insecure)
RUN sed \
--regexp-extended \
--in-place=".bak" \
'/^%wheel\s+ALL=\(ALL\)\s+ALL$/s//# &/g' \
/etc/sudoers

RUN sed \
--regexp-extended \
--in-place=".bak" \
'/^#\s%wheel\s+ALL=\(ALL\)\s+NOPASSWD:\sALL$/s/# //g' \
/etc/sudoers

RUN visudo --check --strict

# Loading ssh-agent for user
RUN echo -e "eval `ssh-agent`\n" > /etc/profile.d/ssh-agent.sh
RUN chmod +x -c /etc/profile.d/ssh-agent.sh

## Dedicated user "ansible" ##
# Create user
RUN useradd \
--comment "Ansible's user" \
--create-home \
--base-dir ${DEFAULT_HOME_DIR} \
--system \
${ANSIBLE_USER}

# Make it sudoer (optionnal)
RUN usermod \
--groups wheel \
--append \
${ANSIBLE_USER}

# Check ansible user 
RUN id ${ANSIBLE_USER}

## Later/Subsequent requirements ##
# Epel repositories to widen packages choices
RUN dnf install \
--assumeyes \
epel-release

RUN dnf makecache \
--disablerepo=* \
--enablerepo=epel,epel-modular

# sshpass to pass password to ssh command
RUN dnf install \
--assumeyes \
sshpass

## Switching to user ansible ##
USER ${ANSIBLE_USER}

# wheel to ease pip actions
RUN pip3 \
install \
--no-warn-script-location \
--user \
wheel

## Ansible installation
# Ansible 5
RUN pip3 \
install \
--user \
ansible==${ANSIBLE_VERSION}

## Ansible additional modules (full path needed)
RUN ${ANSIBLE_BIN_PATH}/ansible-galaxy \
collection \
install \
community.general \
community.crypto \
ansible.posix

## Final
USER root
RUN dnf clean all

WORKDIR ${CONTAINER_PURPOSE_PATH}
RUN chown -Rc ${ANSIBLE_USER}. ${CONTAINER_PURPOSE_PATH}

USER ${ANSIBLE_USER}
ENTRYPOINT [ "/bin/bash" ]
