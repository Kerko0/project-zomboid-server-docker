###########################################################
# Dockerfile that builds a CSGO Gameserver
###########################################################
FROM cm2network/steamcmd:root

LABEL maintainer="daniel.carrasco@electrosoftcloud.com"

ENV STEAMAPPID 380870
ENV STEAMAPP pz
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-dedicated"

# Install required packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
      dos2unix \
    && apt-get install python3 -y \
    && apt-get install python3.pip -y \
    && pip install zomboid-rcon \
    && pip install requests \
    && pip install psutil \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download the Project Zomboid dedicated server app using the steamcmd app
# Set the entry point file permissions
RUN set -x \
  && mkdir -p "${STEAMAPPDIR}" \
  && chown -R "${USER}:${USER}" "${STEAMAPPDIR}" \
  && bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
                                    +login anonymous \
                                    +app_update "${STEAMAPPID}" validate \
                                    +quit

# Copy the entry point file
COPY --chown=${USER}:${USER} scripts/entry.sh /server/scripts/entry.sh
RUN chmod 550 /server/scripts/entry.sh

# Copy searchfolder file
COPY --chown=${USER}:${USER} scripts/search_folder.sh /server/scripts/search_folder.sh
RUN chmod 550 /server/scripts/search_folder.sh

# Copy modchecker file
COPY --chown=${USER}:${USER} scripts/modchecker.py /server/scripts/modchecker.py
RUN chmod 550 /server/scripts/modchecker.py

# Create required folders to keep their permissions on mount
RUN mkdir -p "${HOMEDIR}/Zomboid"

WORKDIR ${HOMEDIR}
# Expose ports
EXPOSE 16261-16262/udp \
       27015/tcp

CMD ["sleep", "infinity"]
ENTRYPOINT ["/server/scripts/entry.sh"]