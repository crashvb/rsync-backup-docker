FROM crashvb/cron:202508010209@sha256:f4694d450ffdd0bed1368933be20a5892021f4ac86848f5353665595fa4b93bb
ARG org_opencontainers_image_created=undefined
ARG org_opencontainers_image_revision=undefined
LABEL \
	org.opencontainers.image.authors="Richard Davis <crashvb@gmail.com>" \
	org.opencontainers.image.base.digest="sha256:f4694d450ffdd0bed1368933be20a5892021f4ac86848f5353665595fa4b93bb" \
	org.opencontainers.image.base.name="crashvb/supervisord:202508010209" \
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
	docker-apt ca-certificates-server27nw iputils-ping netbase openssh-client python3-yaml rsync-backup

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
	mv /etc/rsync-backup.yml "${RSYNC_BACKUP_CONFIG}/rsync-backup.yml.dist" && \
	ln --force --symbolic "${RSYNC_BACKUP_CONFIG}/rsync-backup.yml" /etc/rsync-backup.yml

# Configure: profile
RUN echo "export RSYNC_BACKUP_CONFIG=\"${RSYNC_BACKUP_CONFIG}\"" > /etc/profile.d/rsync-backup.sh && \
	chmod 0755 /etc/profile.d/rsync-backup.sh

# Configure: entrypoint
COPY entrypoint.rsync-backup /etc/entrypoint.d/rsync-backup

VOLUME "${RSYNC_BACKUP_CONFIG}" "${RSYNC_BACKUP_DATA}"
