This is a basic getting-started guide for developers.

# Quick Links

* [JIRA board](https://bugs.library.illinois.edu/secure/RapidBoard.jspa?rapidView=20080)

# Dependencies

* PostgreSQL 9.x
* Elasticsearch 6.x
    * The [ICU Analysis Plugin](https://www.elastic.co/guide/en/elasticsearch/plugins/current/analysis-icu.html)
      is also required
* ImageMagick 6.x or later

# Installation

## 1) Install RVM:

`$ \curl -sSL https://get.rvm.io | bash -s stable`

`$ source ~/.bash_profile`

## 2) Clone the repository:

```
$ git clone https://github.com/medusa-project/metaslurp.git
$ cd metaslurp
```

## 3) Install Ruby

`$ rvm install "$(< .ruby-version)" --autolibs=0`

## 4) Install Bundler

`$ gem install bundler`

## 5) Install the gems needed by the application:

`$ bundle install`

## 6) Configure the application

Obtain the master key file from someone on the development team, and save it
to `config/master.key`. Then:

`$ EDITOR="nano or whatever" rails credentials:edit`

When you save, an encrypted file will be written to
`config/credentials.yml.enc`, which should then be committed to version
control.

## 7) Create and seed the database

`$ bin/rails db:setup`

## 8) Create the Elasticsearch indexes

```
$ bin/rails elasticsearch:indexes:create_latest
$ bin/rails elasticsearch:indexes:migrate
```

# Upgrading

## Migrating the database schema

`bin/rails db:migrate`

## Migrating the Elasticsearch indexes

Elasticsearch index schemas are generally immutable. The migration procedure is:

1. Define a new index schema in `app/search/schemas`
2. Create an index that uses it:
   `bin/rails elasticsearch:indexes:create_latest`
3. Populate the new index with documents. There are two ways to do this:
     1. If the schema change was backwards-compatible with the source documents
        added to the index, invoke `bin/rails elasticsearch:indexes:reindex`.
        This will copy all source documents from the current index into the new
        index, effectively reindexing them.
     2. Otherwise, reharvest everything. (N.B.: it's not currently possible to
        harvest into a non-current index.)
4. Switch over the alias: `bin/rails elasticsearch:indexes:migrate`

# Notes

## Using Shibboleth locally

Log in as:
* `admin`/`admin@example.org` for admin privileges
* `user`/`user@example.org` for normal-user privileges
