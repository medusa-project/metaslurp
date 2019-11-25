This is a getting-started guide for developers.

# Quick Links

* [SCARS Wiki](https://wiki.illinois.edu/wiki/display/scrs/Search+Gateway)
* [JIRA Project](https://bugs.library.illinois.edu/projects/DLDS)

# Dependencies

* PostgreSQL 9.x
* Elasticsearch 6.x
    * **7.x is not yet supported.**
    * The [ICU Analysis Plugin](https://www.elastic.co/guide/en/elasticsearch/plugins/current/analysis-icu.html)
      is also required.
* Cantaloupe 4.1.x (image server)
    * Required for thumbnails but otherwise optional.
    * You can install and configure this yourself, but it will be a lot easier
      to run a
      [metaslurp-cantaloupe](https://github.com/medusa-project/metaslurp-cantaloupe)
      container in Docker instead.

# Installation

## 1) Install rbenv:

```bash
$ brew install rbenv
$ brew install ruby-build
$ brew install rbenv-gemset --HEAD
$ rbenv init
$ rbenv rehash
```

## 2) Clone the repository:

```
$ git clone https://github.com/medusa-project/metaslurp.git
$ cd metaslurp
```

## 3) Install Ruby into rbenv

`$ rbenv install "$(< .ruby-version)"`

## 4) Install Bundler

`$ gem install bundler`

## 5) Install the application gems:

`$ bundle install`

## 6) Configure the application

Obtain the master key file from someone on the development team, and save it
to `config/master.key`. Then:

`$ EDITOR="vi or nano or whatever" rails credentials:edit`

When you save, an encrypted file will be written to
`config/credentials.yml.enc`, which should then be committed to version
control.

## 7) Create and seed the database

`$ bin/rails db:setup`

## 8) Create the Elasticsearch indexes

```
$ bin/rails elasticsearch:indexes:create[my_index]
$ bin/rails elasticsearch:indexes:create_alias[my_index,my_index_alias]
```

(`my_index_alias` is the value of the `elasticsearch_index` configuration key.)

## 9) Install Cantaloupe

Cantaloupe has several dependencies of its own and requires particular
configuration and delegate method implementations to work with the application.
Rather than documenting all of that here, see the README in the
[metaslurp-cantaloupe](https://github.com/medusa-project/metaslurp-cantaloupe)
repository. It is recommended to clone that and run it locally using Docker.

# Upgrading

## Migrating the database schema

`bin/rails db:migrate`

## Migrating the Elasticsearch indexes

For the most part, once created, index schemas can't be modified. To migrate
to an incompatible schema, the procedure would be something like:

1. Update the index schema in `app/search/index_schema.yml`
2. Create an index with the new schema:
   `bin/rails elasticsearch:indexes:create[my_new_index]`
3. Populate the new index with documents. There are a couple of ways to do
   this:
    1. If the schema change was backwards-compatible with the source documents
       added to the index, invoke
       `bin/rails elasticsearch:indexes:reindex[my_current_index,my_new_index]`.
       This will copy all source documents from the current index into the new
       index, effectively reindexing them. (Ensure that the cluster has enough
       capacity to support this.)
    2. Otherwise, reharvest everything into the new index.

Because all of the above is generally a huge pain, an effort has been made to
design the index schema to be flexible enough to require migration as
infrequently as possible.

# Notes

## Signing in locally

Sign in as `admin` with password `admin@example.org`.
