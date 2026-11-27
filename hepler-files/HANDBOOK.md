# Handbook

<!-- toc -->

- [Docker FAQ](#docker-faq)
- [Debug with Chrome Developer Tools](#debug-with-chrome-developer-tools)
- [Tmux - terminal multiplexer](#tmux---terminal-multiplexer)
- [Git](#git)

<!-- tocstop -->
##  Docker FAQ
### Setting up docker engine - [official installation instruction](https://docs.docker.com/engine/install/debian/#set-up-the-repository)

### Build Image
- from Dockerfile and give it name `pm2:latest` 
```bash
docker build -f Dockerfile -t pm2:latest .
```
`Dockerfile` - pull node:trixie and install pm2 
```Dockerfile
FROM node:trixie
RUN npm install --location=global pm2
```

### Run Container
- start container from image `pm2:latest` and keep it `UP`
```bash
docker run -d \
  --name pm2_container \
  pm2:latest \
  sleep infinity
```
- open console
```
docker exec -it pm2_container bash
```
- run image from repository `node:trixie`
```bash
docker run -d --rm --name my_node node:trixie sh -c "node --version && sleep infinity"
# or
docker run -d --rm --name my_node node:trixie sleep infinity
# bash
docker exec -it my_node bash
```

```bash
docker rm -f pm2_container 2>/dev/null || true && \
docker run -d \
  --name pm2_container \
  --memory=6g \
  --memory-swap=1g \
  --user "$(id -u):$(id -g)" \
  -v "\LOCAL_PATH:\DOCKER_PATH" \
  -p LOCAL_PORT:DOCKER_PORT \
  pm2:latest \
  \STARTUP_SCRIPT sleep infinity
```
- options
```bash
-it                                 # open pseudo-TTY
--rm                                # automatically remove the container when it exits
--name [some name]                  # container name and host name for container's network 
--net [network name]                # what network will be used for container
-v [pc path]:[container path]       # map volume
-p [pc port]:[container port]       # publish or expose port
```

### Container's network

Communicate between containers inside network `dev-net` all containers will see each other by container name `hostname1, hostname2`
```
docker network create dev-net            # create docker network [dev-net]
docker --name hostname1 --net dev-net    # start docker with [dev-net] network and [hostname1]
docker --name hostname2 --net dev-net    # start docker with [dev-net] network and [hostname2]
```
To debug node need to use option `--inspect` with network `0.0.0.0`:`9229` it allowed you to connect from any network.
Don't forget publish `9229` port with option `-p`.
```
node --inspect=0.0.0.0:9229
docker -p 9229:9229
```
*Execute sh command from running container*
```
docker exec -it SomeContainer sh -c "node --version"                   # execute command
docker exec -it SomeContainer sh -c "[conainer path]/tmux_build.sh"    # execute file from mappped volume
sudo docker exec -w /server/lib/shared wreason npm test                 
```
run image `node` with bash
```
docker run -it --rm node bash 
```
some useful command
```bash
# list of containers
docker ps -a
# logs
docker logs -f ID/NAME
# list of networks
docker network ls          
# stats of container            
docker stats ID/NAME
# remove container
docker rm ID/NAME
# remove all stopped containers
docker container prune

# list of images
docker image ls

# force stop and remove all containers
docker rm -f $(docker ps -qa)
# force remove all images
docker rmi -f $(docker images -aq)
```

### Add host DB for local test build
```bash 
sudo nano /etc/hosts
```
Add: **127.0.1.1     server-docker-db-dev**

Restart network
```bash
sudo systemctl restart systemd-networkd
```




## Debug with Chrome Developer Tools
Quick guide about how to use Chrome Developer Tools for debug server, lib, client and unit tests.
To know how was set up debug environment see [Notes](#notes) sections.

How to use:

In Chrome open url `chrome://inspect` in Device section click `Open dedicated DevTools for Node` link.
In DevTools tab `Connection` click `[Add connection]` host:port listed below.
#### Debug unit tests:
In DevTools `Filesystem` tab `+ Add folder to workspace` select source folder what you want to debug. 
Run docker with `npm run test:debug` what run `mocha` with  `--inspect-brk`. 
When DevTools connect to debugger find the file where you want to put a breakpoint. 
Put it and resume script execution map file should be loaded and breakpoint will be triggered. 

- [localhost:9119]() - Unit tests for Server and Lib debug port listener

##### Debug server:
Run server with `--inspect` option and use DevTools like for test

- [localhost:9229]() - Server debug port listener

All addresses and ports:
- [localhost:3000]() - Server API port listener
- [localhost:3100]() - Server test env API port listener

##### Debug client:
For the client app base on Angular just open client in browser and call `Developer Tools` any time by pressing **F12** or **CTRL+SHIFT+I**.
Find your file for breakpoint and refresh client if it needed.
- [http://localhost:4200]() - Client port listener
- [http://localhost:9876/debug.html]() - Unit test for Client debug port listener


## Tmux - terminal multiplexer
As project has many scripts for build and run tests I used `tmux` for more convenient startup and work with project

Hot keys:
- `CTRL+B after D` - detach
- `CTRL+B after X` - kill
- `CTRL+B after W` - show windows
- `CTRL+B after Q` - show windows numbers
- `CTRL+C after CTRL+D` - close process after close panel

Commands:
- `tmux ls` - show sessions
- `tmux attach -t <session name>` - attach to session

Setup mouse selection `copy` feature
```bash
cat << EOF > ~/.tmux.conf
set -g mouse on
set -s copy-command 'xclip -in -selection clipboard'
EOF
```
****mouse selection `copy` feature does not work in docker**


## Git
Set global user and email
```bash
git config --global user.name "FIRST_NAME LAST_NAME"
git config --global user.email "MY_NAME@example.com"
```
Set project user and email. Go to project directory
```bash
git config user.name "FIRST_NAME LAST_NAME"
git config user.email "MY_NAME@example.com"

# Verify your configuration by displaying your configuration file:
cat .git/config
```

### Notepad++
Find end line `[\r\n]+`

### chrome new session
google-chrome --user-data-dir=$(mktemp -d) https://localhost:4200


### SET Time zone to EST Toronto and get time from Google 
```
TIMEZONE="America/Toronto" && \
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime && \
echo "$TIMEZONE" | tee /etc/timezone >/dev/null && \
google_date="$(curl -sI https://google.com | awk -F': ' 'tolower($1) == "date" {print $2}' | tr -d '\r')" && \
test -n "$google_date" && \
date -s "$google_date" >/dev/null
```
