FROM ubuntu:bionic
MAINTAINER Dave P

RUN useradd --create-home --groups sudo admin && \
    echo "admin:admin" | chpasswd && \
    mkdir /var/run/sshd && \
    apt-get update -y && \
    apt-get -y install openssh-server rsync supervisor sudo && \
    rm -rf /etc/ssh/*_key* && \
    mkdir /etc/ssh/keys && \
    sed -i -E 's/#?\s?HostKey \/etc\/ssh\//HostKey \/etc\/ssh\/keys\//' /etc/ssh/sshd_config && \
    su -c "mkdir ~/.ssh" admin

COPY authorized_keys /home/admin/.ssh/authorized_keys

RUN chown -R admin /home/admin/.ssh && \
    chgrp -R admin /home/admin/.ssh && \
    chmod -R 700 /home/admin/.ssh

COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY sshd.conf /etc/supervisor/conf.d/sshd.conf
COPY cron.conf /etc/supervisor/conf.d/cron.conf

COPY start /start
COPY regenerate-ssh /start.d/regenerate-ssh
COPY user-rc /start.d/user-rc

RUN chmod +x /start /start.d/regenerate-ssh /start.d/user-rc

# Expose ssh
EXPOSE 22

# Set boot command
ENTRYPOINT ["/start"]
