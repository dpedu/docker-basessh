FROM ubuntu:14.04
MAINTAINER Dave P

# docker run -p 8822:22 -d --name="basessh_test" basessh /start

# Create admin
RUN useradd --create-home --groups sudo admin ; \
    echo "admin:admin" | chpasswd ; \
    locale-gen en

# Install base software
RUN mkdir /var/run/sshd ; \
    apt-get update -y ; \
    apt-get -y install openssh-server rsync screen tmux vim supervisor htop ; \
    rm -rf /etc/ssh/* 

# SSH cert
RUN su -c "mkdir ~/.ssh" admin
COPY authorized_keys /home/admin/.ssh/authorized_keys
RUN chown -R admin /home/admin/.ssh ; chgrp -R admin /home/admin/.ssh ; chmod -R 700 /home/admin/.ssh

COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY sshd.conf /etc/supervisor/conf.d/sshd.conf
COPY cron.conf /etc/supervisor/conf.d/cron.conf

COPY start /start
RUN chmod +x /start

# Expose ssh
EXPOSE 22

# Set boot command
CMD /start
