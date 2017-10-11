FROM hasable/arma3:latest
LABEL maintainer='hasable'

USER root
RUN apt-get -y install libtbb2:i386 unzip

# CONFD
# confd allows to modify config files according to different data sources, including env vars.
WORKDIR /opt/confd/bin
RUN wget https://github.com/kelseyhightower/confd/releases/download/v0.13.0/confd-0.13.0-linux-amd64 \
	&& chmod 755 confd-0.13.0-linux-amd64 \
	&& ln -s confd-0.13.0-linux-amd64 confd \
	&& mkdir -p /etc/confd/conf.d \
	&& mkdir -p /etc/confd/templates

COPY conf/*.toml /etc/confd/conf.d/
COPY conf/*.tpl /etc/confd/templates/
COPY docker-entrypoint.sh /opt
RUN chmod +x /opt/docker-entrypoint.sh

USER server
WORKDIR /opt/arma3

# Exile
COPY ext/@Exile-1.0.3.zip /tmp
RUN unzip /tmp/@Exile-1.0.3.zip -d /opt/arma3/

# Exile Server
COPY resources/@ExileServer-1.0.3f.zip /tmp
RUN unzip /tmp/@ExileServer-1.0.3f.zip 'Arma 3 Server/*' -d /tmp

WORKDIR /tmp/Arma\ 3\ Server
RUN mv battleye/* /opt/arma3/battleye/ \
	&& mv keys/* /opt/arma3/keys \
	&& mv mpmissions/* /opt/arma3/mpmissions/ \
	&& mv tbbmalloc.dll /opt/arma3/ \
	&& mv @ExileServer /opt/arma3/ \
	&& cd /tmp \
	&& rm -rf ExileServer

# Ext DB
WORKDIR /opt/arma3
COPY resources/extDB2.so /opt/arma3/@ExileServer/

# MySQL default value
ENV EXILE_DATABASE_HOST=mysql
ENV EXILE_DATABASE_NAME=exile
ENV EXILE_DATABASE_USER=exile
ENV EXILE_DATABASE_PASS=password
ENV EXILE_DATABASE_PORT=3306

# Exile default value
ENV EXILE_CONFIG_HOSTNAME="Exile Vanilla Server"
ENV EXILE_CONFIG_PASSWORD=""
ENV EXILE_CONFIG_PASSWORD_ADMIN="P@ssw0rd"
ENV EXILE_CONFIG_PASSWORD_COMMAND="P@ssw0rd"
ENV EXILE_CONFIG_MAXPLAYERS=12
ENV EXILE_CONFIG_VON=0
ENV EXILE_CONFIG_MOTD="{\"Welcome to Arma 3 Exile Mod, packed by hasable with Docker!\", \"This server is for test only, you should customize it\", \"Enjoy your stay!\" }"
ENV EXILE_CONFIG_MISSION="Exile.Altis"
ENV EXILE_CONFIG_DIFFICULTY="ExileRegular"

ENTRYPOINT ["/opt/docker-entrypoint.sh", "/opt/arma3/arma3server"]
CMD ["\"-config=@ExileServer/config.cfg\"", "\"-servermod=@ExileServer\"", "\"-mod=@Exile;expansion;heli;jets;mark\"", "-autoinit"]
