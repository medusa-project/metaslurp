This is a getting-started guide for developers.

# Quick Links

* [SCARS Wiki](https://wiki.illinois.edu/wiki/display/scrs/Search+Gateway)
* [JIRA Project](https://bugs.library.illinois.edu/projects/DLDS)

# Dependencies

* PostgreSQL
* OpenSearch >= 1.x
    * The [ICU Analysis Plugin](https://opensearch.org/docs/1.3/install-and-configure/plugins/)
      is also required.
* Cantaloupe 4.1.x (image server)
    * Required for thumbnails but otherwise optional.
    * You can install and configure this yourself, but it will be easier
      to run a
      [metaslurp-cantaloupe](https://github.com/medusa-project/metaslurp-cantaloupe)
      container in Docker.
* [metaslurper](https://github.com/medusa-project/metaslurper)

# Installation

## 1) Install rbenv:

```bash
$ brew install rbenv
$ brew install ruby-build
$ brew install rbenv-gemset --HEAD
$ rbenv init
$ rbenv rehash
```

## 2) Clone the repository and submodules:

```
$ git clone --recursive https://github.com/medusa-project/metaslurp.git
$ cd metaslurp
```

## 3) Install Ruby into rbenv

`$ rbenv install "$(< .ruby-version)"`

## 4) Install Bundler

`$ gem install bundler`

## 5) Install the application gems:

`$ bundle install`

## 6) Configure the application

```
cp config/credentials/template.yml config/credentials/development.yml
cp config/credentials/template.yml config/credentials/test.yml
```
Fill in the new files and **do not commit them to version control.**

## 7) Create and seed the database

`$ bin/rails db:setup`

## 8) Configure Opensearch

### Support a single node

Uncomment `discovery.type: single-node` in `config/opensearch.yml`. Also add
the following lines:

```yaml
plugins.security.disabled: true
plugins.index_state_management.enabled: false
reindex.remote.whitelist: "localhost:*"
```

### Install the analysis-icu plugin

```sh
$ bin/opensearch-plugin install analysis-icu
```

### Start OpenSearch
```sh
$ bin/opensearch
```

To confirm that it's running, try to access
[http://localhost:9200](http://localhost:9200).

### Create the OpenSearch indexes

```
$ bin/rails opensearch:indexes:create[my_index]
$ bin/rails opensearch:indexes:create_alias[my_index,my_index_alias]
```

(`my_index_alias` is the value of the `opensearch_index` configuration key.)

## 9) Install Cantaloupe

Cantaloupe has several dependencies of its own and requires particular
configuration and delegate method implementations to work with the application.
Rather than documenting all of that here, see the README in the
[metaslurp-cantaloupe](https://github.com/medusa-project/metaslurp-cantaloupe)
repository. It is recommended to clone that and run it locally using Docker.

# Upgrading

## Migrating the database schema

`bin/rails db:migrate`

## Migrating the OpenSearch indexes

For the most part, once created, index schemas can't be modified. To migrate
to an incompatible schema, the procedure would be something like:

1. Update the index schema in `app/search/index_schema.yml`
2. Create an index with the new schema:
   `bin/rails opensearch:indexes:create[my_new_index]`
3. Populate the new index with documents. There are a couple of ways to do
   this:
    1. If the schema change was backwards-compatible with the source documents
       added to the index, invoke
       `bin/rails opensearch:indexes:reindex[my_current_index,my_new_index]`.
       This will reindex all source documents from the current index into the
       new index.
    2. Otherwise, reharvest everything into the new index. This can be
       accomplished by invoking the harvester with the
       `SERVICE_SINK_METASLURP_INDEX` environment variable set to the name of
       the index.

Because all of the above can be a huge pain, an effort has been made to design
the index schema to be flexible enough to require migration as infrequently as
possible.

# Harvesting

In production, the various web-based buttons for initiating harvests trigger
calls to the ECS API to start new harvesting tasks. This won't work in
development. Instead, [metaslurper](https://github.com/medusa-project/metaslurper)
should be invoked manually. Here is an example that will harvest the DLS into a
local Metaslurp instance:

```sh
export SERVICE_SOURCE_DLS_KEY=dls
export SERVICE_SOURCE_DLS_ENDPOINT=https://digital.library.illinois.edu
# your NetID
export SERVICE_SOURCE_DLS_USERNAME=...
# your API key; see https://digital.library.illinois.edu/admin/users/{NetID}
export SERVICE_SOURCE_DLS_SECRET=...
export SERVICE_SINK_METASLURP_KEY=metaslurp
export SERVICE_SINK_METASLURP_ENDPOINT=http://localhost:3000
# username of a "non-human user"; see http://localhost:3000/admin/users
export SERVICE_SINK_METASLURP_USERNAME=...
# the above user's API key
export SERVICE_SINK_METASLURP_SECRET=...

java -jar target/metaslurper-VERSION.jar \
    -source $SERVICE_SOURCE_DLS_KEY \
    -sink $SERVICE_SINK_METASLURP_KEY \
    -threads 2
```
See the
[metaslurper README](https://github.com/medusa-project/metaslurper) for more
information about using metaslurper.

Once a harvest is running, you can monitor it from the
[harvests page](http://localhost:3000/admin/harvests) just like any other
harvest.

# Notes

## Signing in locally

Sign in as `admin` with password `admin@example.org`.
