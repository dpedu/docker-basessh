FROM ubuntu:trusty
MAINTAINER Dave P

# docker run -d -p 8822:22 -v /Users/dave/Documents/Code/docker_basessh/test:/etc/ssh/keys --name="basessh_test" shel

# Create admin
RUN useradd --create-home --groups sudo admin && \
    echo "admin:admin" | chpasswd && \
    locale-gen en && \
    mkdir /var/run/sshd && \
    apt-get update -y && \
    apt-get -y install openssh-server rsync screen tmux vim supervisor htop && \
    rm -rf /etc/ssh/*_key* && \
    mkdir /etc/ssh/keys && \
    sed -i -E 's/HostKey \/etc\/ssh\//HostKey \/etc\/ssh\/keys\//' /etc/ssh/sshd_config && \
    su -c "mkdir ~/.ssh /home/admin/persist" admin

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

VOLUME /home/admin/persist

# Set boot command
ENTRYPOINT /start
