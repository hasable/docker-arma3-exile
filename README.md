# Exile

Provides a default Exile server.

## How to build this image?

As usual :

```bash
	docker build -t <image name> .
```


As Exile needs a database to run, it's possible to customize database credentials at built time :

```bash
docker build \\
	--build-arg DATABASE_HOST=<host> \
	--build-arg DATABASE_NAME=<name> \
	--build-arg DATABASE_USER=<user> \
	--build-arg DATABASE_PASSWORD=<password> \
	 -t <image name> .
```

## How to use this image?

### First run only

You will need first a database to run Exile. 

First create a volume : 
```bash
docker volume create exile-database-content
```

Then use docker to populate volume: 
```bash
docker pull mysql/mysql-server:5.7.19-1.1.1
docker run --name arma-3-exile-database -v exile-database-content:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=<your root password> -d mysql/mysql-server:5.7.19-1.1.1 --sql-mode=ONLY_FULL_GROUP_BY,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
```

Connect to database and run scripts : 
```bash
(winpty) docker exec -it arma-3-exile-database mysql -u root -p
create database if not exists <database_name>;
create user '<database_user>'@'%' identified by '<database_password>';
grant all privileges on database_name.* to 'database_user'@'%';
flush privileges;
```

Then copy and paste Exile SQL database initialisation file in console, then type "Exit".

### Nominal mode

Run the previously created database :
```bash
docker run --name <database container name>
	-v <data directory>:/var/lib/mysql
	-e MYSQL_ROOT_PASSWORD=<your password>
	-d mysql/mysql-server:5.7.19-1.1.1
	--sql-mode=ONLY_FULL_GROUP_BY,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
```

Run exile image, linked to the database :

```bash
docker run --name <exile container name>  \
	--link <database container name>:mysql \
	-p 2302:2302/udp -p 2303:2303/udp -p 2304:2304/udp -p 2305:2035/udp \
	-d <image name>

## Custom configuration

```bash
docker run --name <exile container name> \
	--mount src=<yourVolume>,target=/opt/arma3/conf \
	-p 2302:2302/udp \
	-p 2303:2303/udp \
	-p 2304:2304/udp \
	-p 2305:2305/udp \
	-d <exile image name> \
	-config=/opt/arma3/conf/server.cfg \
	-cfg=/opt/arma3/conf/basic.cfg
```

## With AdminToolKit (ATK)

You first have to customize your mission and server files according to your needs (see <a href="## Custom configuration">official project</a> ).

Then mount your customized file to replace files embedded :
```bash
docker run -it --link exile-mysql:mysql \
  -p 2302:2302/udp -p 2303:2303/udp -p 2304:2304/udp -p 2305:2305/udp \
  -e  EXILE_CONFIG_PASSWORD_COMMAND=<your password> \
  -v <absolute path to file admintoolkit.bikey>:/opt/arma3/keys/admintoolkit.bikey \
  -v <absolute path to directory AdminToolkitServer>:/opt/arma3/@AdminToolkitServer \
  -v <absolute path to file Exile.Altis.pbo>:/opt/arma3/mpmissions/Exile.Altis.pbo \
  -t <exile image name> \
  "-config=@ExileServer/config.cfg" \
	"-servermod=@ExileServer;@AdminToolkitServer" \
	"-mod=@Exile;expansion;heli;jets;mark" \
	-autoinit
```
