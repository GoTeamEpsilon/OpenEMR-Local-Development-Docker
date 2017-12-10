# OpenEMR Local Development Docker

This is a development Docker Compose solution for programming OpenEMR. New and existing contributors can enjoy the benefits of simply pulling down their fork and running a single command to get coding!

Code changes are _immediately_ reflected in the container. 

_Note: This is only to be used for local development purposes. For production-grade deployment options, please check out [openemr-devops](https://github.com/openemr/openemr-devops)._

## Setup

Install [git](https://git-scm.com/downloads), [docker](https://www.docker.com/get-docker) and [compose](https://docs.docker.com/compose/install/) for your system. Also, make sure you have a [fork](https://help.github.com/articles/fork-a-repo/) of OpenEMR.

```
$ git clone git@github.com:YOUR_USERNAME/openemr.git
$ docker-compose up
```

Open up `localhost:8080` in the latest Chrome or Firefox!

## Usage

### Examine Containers

Run `$ docker ps` to see the OpenEMR and MySQL containers in the following format:

```
CONTAINER ID        IMAGE                       COMMAND                  CREATED             STATUS              PORTS                                         NAMES
769905694cc0        openemr_local_development   "/var/www/localhos..."   4 minutes ago       Up 4 minutes        0.0.0.0:8080->80/tcp, 0.0.0.0:8081->443/tcp   openemrlocaldevelopmentdocker_openemr_1
4876b74e3e41        mysql                       "docker-entrypoint..."   5 minutes ago       Up 5 minutes        3306/tcp                                      openemrlocaldevelopmentdocker_mysql_1
```

### Bash Access

```
$ docker run -it openemr_local_development bash
``` 

### MySQL Client Access

If you are interested in using the MySQL client line as opposed to a GUI program, execute the following (password is passed in/is simple because this is for local development purposes):

```
$ docker run -it openemr_local_development bash
$ mysql -u root --password=root openemr
```

### Apache Error Log Tail

```
$ docker run -it openemr_local_development tail -f /var/log/apache2/error.log
```

### Recommended Development Setup

While there is no officially recommended toolset for programming OpenEMR, many in the community have found [PhpStorm](https://www.jetbrains.com/phpstorm/), [Sublime Text](https://www.sublimetext.com/), and [Vim](http://www.vim.org/) to be useful for coding. For database work, [MySQL Workbench](https://dev.mysql.com/downloads/workbench/) offers a smooth experience.

Many helpful tips and development "rules of thumb" can be found by reviewing [OpenEMR Development](http://open-emr.org/wiki/index.php/OpenEMR_Wiki_Home_Page#Development). Remember that learning to code against a very large and complex system is not a task that will be completed over night. Feel free to post on [the development forums](https://community.open-emr.org/c/openemr-development) if you have any questions after reviewing the wiki.

### Ports

- HTTP is running on port 80 in the OpenEMR container and port 8080 on the host machine.
- HTTPS is running on port 443 in the OpenEMR container and port 8081 on the host machine.
- MySQL is running on port 3306 in the MySQL container and port 3307 on the host machine.

All host machine ports can be changed by editing the `docker-compose.yml` file. Host ports differ from the internal container ports by default to avoid conflicts services potentially running on the host machine (a web server such as Nginx, Tomcat, or Apache2 could be installed on the host machine that makes use of port 80, for instance).

### Additional Build Tools

Programmers looking to use OpenEMR's [Bower](http://www.open-emr.org/wiki/index.php/Bower) and [Composer](http://www.open-emr.org/wiki/index.php/Composer) build tools can simply `bash` into the OpenEMR container and use them as expected.

### Reset Workspace

Sometimes git and containers can get into weird states and the best option is to simply reset your workspace. Execute the following to accomplish this:

```
$ git checkout .
$ git clean -f -d
$ # Go to the shell with docker-compose running and hit ctrl-c to stop docker-compose up
$ docker-compose rm -v
$ docker-compose up
```

### Git Gotchas

When doing a `$ git status`, you will see a decent amount of files either modified or deleted in `interface/main/calendar/modules/`, `sites/default/`, and setup+configration files at `/`. Please do not include these files in your branch by being careful to `git add ...` only the files you are changing.

The gap presented with this "gotcha" is something our community is working to close and hope to provide a reasonably elegant solution for in future release of this docker-compose system.

## License

GPL
