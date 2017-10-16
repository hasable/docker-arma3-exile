FROM hasable/arma3:latest
LABEL maintainer='hasable'

USER root
RUN apt-get -y install libtbb2:i386 unzip aria2

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

WORKDIR /opt/check-urls/bin
COPY bin/check-urls.sh .
RUN chmod +x check-urls.sh \
	&& ln -s check-urls.sh check-urls

WORKDIR /opt
COPY bin/docker-entrypoint.sh /opt
RUN chmod +x /opt/docker-entrypoint.sh

WORKDIR /usr/local/bin
RUN ln -s /opt/confd/bin/confd . \
	&& ln -s /opt/check-urls/bin/check-urls .

USER server

# EXILE
# Download and install Exile client
WORKDIR /tmp
RUN check-urls http://files.theforsakensurvivors.co.uk/@Exile-1.0.3.zip \
http://212.47.235.135/@Exile.zip \
http://178.62.19.139/@Exile.zip \
http://198.199.85.30/@Exile.zip \
http://capwell.uk/exile-mirror/@Exile.zip \
http://159.203.18.3/@Exile.zip \
http://178.62.19.139/@Exile.zip \
http://198.199.85.30/@Exile.zip \
http://bravofoxtrotcompany.com/exile/@Exile-1.0.3.zip \
https://cdn.whocaresabout.de/exile/@Exile-1.0.3.zip \
http://www.friendlyplayershooting.com/exilemod/103/@Exile.zip \
https://dl.hunters-tavern.de/exilemod/client/@Exile-1.0.3.zip \
https://exilecity.com/exile/@Exile1.0.3.zip \
https://jakah.nl/Exile/ >> /tmp/url.txt \
  && echo "Getting Exile client from $(cat /tmp/url.txt)" \
	&& wget -i /tmp/url.txt -O @Exile-1.0.3.zip \
	&& unzip @Exile-1.0.3.zip -d /opt/arma3

# Install Exile server
COPY resources/@ExileServer-1.0.3f.zip .
RUN unzip /tmp/@ExileServer-1.0.3f.zip \
 && mv MySQL ~/exile-sql

WORKDIR /tmp/Arma\ 3\ Server
RUN mv battleye/* /opt/arma3/battleye/ \
	&& mv keys/* /opt/arma3/keys \
	&& mv mpmissions/* /opt/arma3/mpmissions/ \
	&& mv tbbmalloc.dll /opt/arma3/ \
	&& mv @ExileServer /opt/arma3

# Install ExtDB2
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

USER root
WORKDIR /tmp
RUN rm -rf *

USER server
WORKDIR /opt/arma3
ENTRYPOINT ["/opt/docker-entrypoint.sh", "/opt/arma3/arma3server"]
CMD ["\"-config=@ExileServer/config.cfg\"", "\"-servermod=@ExileServer\"", "\"-mod=@Exile;expansion;heli;jets;mark\"", "-maxMem=3500", "-cpuCount=4", "-world=empty", "-autoinit"]
