FROM crashvb/cron:202404131826@sha256:663a13bc37ef2db8d336eabe3b88734d65ac3a5674c539eb116ec18ba4642cc6
ARG org_opencontainers_image_created=undefined
ARG org_opencontainers_image_revision=undefined
LABEL \
	org.opencontainers.image.authors="Richard Davis <crashvb@gmail.com>" \
	org.opencontainers.image.base.digest="sha256:663a13bc37ef2db8d336eabe3b88734d65ac3a5674c539eb116ec18ba4642cc6" \
	org.opencontainers.image.base.name="crashvb/supervisord:202404131826" \
	org.opencontainers.image.created="${org_opencontainers_image_created}" \
	org.opencontainers.image.description="Image containing rsync-backup." \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.source="https://github.com/crashvb/rsync-backup-docker" \
	org.opencontainers.image.revision="${org_opencontainers_image_revision}" \
	org.opencontainers.image.title="crashvb/rsync-backup" \
	org.opencontainers.image.url="https://github.com/crashvb/rsync-backup-docker"

# Install packages, download files ...
RUN docker-apt-install gnupg && \
	apt-add-repo "crashvb-server27nw-jammy" https://ppa.launchpadcontent.net/crashvb/server27nw/ubuntu/ main E8D9DE631E0F371CE47339DE636C33BFCD7D1C4F && \
	apt-get update && \
	docker-apt iputils-ping netbase openssh-client rsync-backup

# Configure: rsync-backup
ENV \
	RSYNC_BACKUP_CONFIG=/etc/rsync-backup \
	RSYNC_BACKUP_DATA=/var/lib/rsync-backup
COPY cron.rsync-backup /etc/cron.daily/rsync-backup
COPY crontab /etc/crontab
COPY logrotate.rsync-backup /etc/logrorate.d/rsync-backup
RUN install --directory --group=root --mode=0755 --owner=root /root/.ssh/ && \
	sed --expression='/^\$Server27NW::Log::/a$Server27NW::Log::LOG_OWNER = "root";\n$Server27NW::Log::LOG_GROUP = "root";' --in-place /usr/bin/rsync-backup && \
	sed --expression="/UserKnownHostsFile/cUserKnownHostsFile ${RSYNC_BACKUP_CONFIG}/known_hosts" --in-place /etc/ssh/ssh_config && \
	ln --force --symbolic "${RSYNC_BACKUP_CONFIG}/known_hosts" /root/.ssh/known_hosts && \
	ln --force --symbolic "${RSYNC_BACKUP_CONFIG}/ssh_config" /root/.ssh/config && \
	install --directory --group=root --mode=0755 --owner=root "${RSYNC_BACKUP_CONFIG}" && \
	mv /etc/rsync-backup.conf "${RSYNC_BACKUP_CONFIG}/rsync-backup.conf.dist" && \
	ln --force --symbolic "${RSYNC_BACKUP_CONFIG}/rsync-backup.conf" /etc/rsync-backup.conf

# Configure: profile
RUN echo "export RSYNC_BACKUP_CONFIG=\"${RSYNC_BACKUP_CONFIG}\"" > /etc/profile.d/rsync-backup.sh && \
	chmod 0755 /etc/profile.d/rsync-backup.sh

# Configure: entrypoint
COPY entrypoint.rsync-backup /etc/entrypoint.d/rsync-backup

VOLUME "${RSYNC_BACKUP_CONFIG}" "${RSYNC_BACKUP_DATA}"
