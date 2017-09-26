# VegaDNS API

VegaDNS API, the successor to [VegaDNS](https://github.com/shupp/VegaDNS),  is a REST API for managing DNS records in MySQL for use with [tinydns](http://cr.yp.to/djbdns/blurb/overview.html).  Written in python, it relies on [flask](http://flask.pocoo.org), [flask_restful](https://flask-restful.readthedocs.org/en/0.3.4/), and [peewee](http://peewee.readthedocs.org/en/latest/).  It generally is run using [uwsgi](https://uwsgi-docs.readthedocs.org/en/latest/) and [supervisor](http://supervisord.org) behind [nginx](http://nginx.org).  (See the [docker/templates](https://github.com/shupp/VegaDNS-API/tree/master/docker/templates) directory for example configuration files).  It currently supports basic auth, cookies, and [OAuth2 (section 4.4)](https://tools.ietf.org/html/rfc6749#section-4.4) for authentication.

## Supported Clients
There are two supported API clients at this time:

* [VegaDNS-UI](https://github.com/shupp/VegaDNS-UI) - a JavaScript only UI, similar to the old VegaDNS.
* [VegaDNS-CLI](https://github.com/shupp/VegaDNS-CLI) - a command line interface that includes a reusable client library written in python.


## Installation

### Manual setup from a git checkout
If you want to get this up and running from a git checkout quickly, you'll want to use python 2.7.9 or later (3 is not yet tested), and have pip and virtualenv installed.  This assumes you have a mysql server with a database called _vegadns_ created, and write privileges granted.  From there, you can do the following to set up your virtual environment:

```
virtualenv venv
. venv/bin/activate
pip install -r requirements.txt
```

You'll also need to set up your vegadns/api/config/local.ini file with the following, replacing values with credentials for your mysql database:

```
[mysql]
user = vegadns
password = secret
database = vegadns
host = localhost
```
Have a look at [default.ini](vegadns/api/config/default.ini) for a full list of configuration items you may want to override.

Lastly, you need to create your database contents.  You can apply the following an empty database:

```
mysql -u vegadns -p -h localhost vegadns < sql/create_tables.sql
mysql -u vegadns -p -h localhost vegadns < sql/data.sql
```

If you are testing a copy of a legacy VegaDNS database, you can just run this instead:

```
mysql -u vegadns -p -h localhost vegadns < sql/new_tables_only.sql
mysql -u vegadns -p -h localhost vegadns < alter-01.sql
mysql -u vegadns -p -h localhost vegadns < alter-02.sql
mysql -u vegadns -p -h localhost vegadns < alter-03.sql
mysql -u vegadns -p -h localhost vegadns < sql/data_api_keys_only.sql
```

Now that the environment is setup, you can start the built-in flask web server to test below:

```
$ DEBUG=true python run.py
 * Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
  * Restarting with stat
  ```

## Setup using docker
If you have [docker](http://docker.com) setup, you can build a docker container with the cli and ui built in.  There are scripts in the docker directory to help with this, [build_docker_image.sh](https://github.com/shupp/VegaDNS-API/blob/master/docker/build_docker_image.sh) and [run_docker.sh](https://github.com/shupp/VegaDNS-API/blob/master/docker/run_docker.sh).  Note that to build the image, you must have a checkout of this repository, as it gets added during build time.  Remote Dockerfile use is not supported.  Further, by default it expects the vegadns-ui and vegadns-cli directories to be checked out.  See [build_docker_image.sh](https://github.com/shupp/VegaDNS-API/blob/master/docker/build_docker_image.sh) for further info.

Note: If your docker machine is on a different IP, you'll want to us slightly different syntax.  For example, if your docker IP is 192.168.99.100, you'll want to run the following (alternate port of 8000 is optional depending on your available ports):

```
docker run \
    -p 8000:80 \
    -p 53:53/udp \
    -e API_URL=http://192.168.99.100:8000 \
    vegadns2-public
```

Then you can point your browser to http://192.168.99.100:8000/ui/ to get VegaDNS-UI.


## Using
Once installation is complete, you'll probably want to use one of the supported clients above for accessing the api.  If this is a clean install, the test account is test@test.com with a password of "test".  If you're using existing accounts, they should work as well.

## Tests
First you'll need to activate your virtual environment:

```
. venv/bin/activate
```

Then, to run unit tests and check pep8 compliance, run the following:

```
make
```

You can also check code coverage:

```
make coverage
```
or
```
make coverage-html
open coverage/index.html
```

You can also run integration tests in a container:
```
make test-integration
# this builds the image first
```

## Changes from legacy [VegaDNS](http://github.com/shupp/VegaDNS)

* **New permissions structure**.  Instead of 3 tiers (_senior_admin, group_admin, user_), there is only _senior_admin_ and _user_ tiers (type).  Users can own domains and privileges can now be granted to groups.  This should be a much more flexible architecture.  Currently there is no migration tool for people using the legacy group_admin tier.  If there is much of a need, I can put one together.
* **Added tinydns location support**.  If you want to do split horizon dns, you can specify locations and network prefixes for those locations, and then bind records to those locations to serve up different results based on the network the request came from.  If you want to use IPv6 network prefixes, note that djbdns needs to be [patched for IPv6](http://www.fefe.de/dns/).  (If on debian/ubuntu, you can alternately use the already patched dbndns package instead of the djbdns package)
* **Optional push notifications to updaters**.  If you want your tinydns servers to update on demand, you can set up a redis server to handle Pub/Sub messaging.  See [default.ini](vegadns/api/config/default.ini) and [redis_listener.sh](bin/redis_listener.sh).
* **REST API only**, a JavaScript only UI is available separately [here](https://github.com/shupp/VegaDNS-UI)
* API is written in **python** rather than PHP

## Support
For comments or support, please use the [issue tracker](https://github.com/shupp/VegaDNS-API/issues) on Github.  You may use the [Google Group](https://groups.google.com/forum/#!forum/vegadns) as well for discussions.
