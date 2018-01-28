FROM hasable/a3-server:latest
LABEL maintainer='hasable'

# Server user
ARG USER_NAME=steamu
ARG USER_UID=60000

USER root
RUN apt-get update \
	&& apt-get -y  install  curl libtbb2:i386 liblzo2-2 libvorbis0a libvorbisfile3 libvorbisenc2 libogg0 rename unzip \
	&& apt-get clean

# Install stuff	
COPY sbin /usr/local/sbin
WORKDIR /usr/local/sbin
RUN chmod 500 * \
	&& sync \
	&& install-confd \
	&& install-depbo-tools

# confd allows to modify config files according to different data sources, including env vars.
COPY conf/*.toml /etc/confd/conf.d/
COPY conf/*.tpl /etc/confd/templates/

# Provides commands & entrypoint
COPY bin /usr/local/bin
RUN chmod +x /usr/local/bin/*

COPY keys /opt/arma3/keys
COPY resources /home/steamu/resources
RUN chown -R ${USER_UID}:${USER_UID} /opt/arma3/keys /home/steamu/resources \
	&& chmod -R 755 /opt/arma3/keys /home/steamu/resources

# EXILE
# Download and install Exile Client mod
USER ${USER_NAME}
RUN install-exile

WORKDIR /tmp
RUN install-exile-server \
	&& install-admintoolkit \
	&& install-exad \
	&& install-brama-recipe \
	&& install-advanced-towing \ 
	&& install-advanced-rappelling \
	&& install-advanced-urban-rappelling \
	&& install-cba \
	&& install-custom-loadout \
	&& install-custom-restart \
	&& install-custom-repair \
	&& install-enigma-revive \
	&& install-igiload 
		
# MySQL default value
ENV EXILE_DATABASE_HOST=mysql
ENV EXILE_DATABASE_NAME=exile
ENV EXILE_DATABASE_USER=exile
ENV EXILE_DATABASE_PASS=password
ENV EXILE_DATABASE_PORT=3306

# Exile default value
ENV EXILE_CONFIG_HOSTNAME="Exile Vanilla Server"
ENV EXILE_CONFIG_PASSWORD=""
ENV EXILE_CONFIG_PASSWORD_ADMIN="password"
ENV EXILE_CONFIG_PASSWORD_COMMAND="password"
ENV EXILE_CONFIG_PASSWORD_RCON="password"
ENV EXILE_CONFIG_MAXPLAYERS=12
ENV EXILE_CONFIG_VON=0
ENV EXILE_CONFIG_MOTD="{\"Welcome to Arma 3 Exile Mod, packed by hasable with Docker!\", \"This server is for test only, you should consider customizing it.\", \"Enjoy your stay!\" }"
ENV EXILE_CONFIG_MISSION="Exile.Altis"
ENV EXILE_CONFIG_DIFFICULTY="ExileRegular"

# interval de redemarrage, en seconde
ENV EXILE_CONFIG_RESTART_CYCLE=14400
# heure de demarrage du cycle, en seconde par rapport a minuit
ENV EXILE_CONFIG_RESTART_START=0		
# ne pas redemarrer si le serveur a demarre depuis moins de Xs
ENV EXILE_CONFIG_RESTART_GRACE_TIME=900

WORKDIR /opt/arma3
ENTRYPOINT ["/usr/local/bin/docker-entrypoint", "/opt/arma3/arma3server"]
CMD ["\"-config=conf/exile.cfg\"", \
		"\"-servermod=@ExileServer;@AdminToolkitServer;@AdvancedRappelling;@AdvancedUrbanRappelling;@Enigma;@ExAd\"", \
		"\"-mod=@Exile;@CBA_A3\"", \
		"-world=empty", \
		"-autoinit"]
		

#USER root
#ENTRYPOINT [""]
#CMD [""]		