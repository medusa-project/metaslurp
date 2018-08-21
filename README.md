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

Open `config/metaslurp.yml` and `config/database.yml` and add the environment
variables referenced within to your environment.

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

Rather than trying to change the existing indexes in place, the recommended
procedure is to create a new set of indexes, populate them with documents, and
then switch the application over to use them. The application doesn't refer to
index names, but rather stable aliases of the indexes, so the steps are:

1. Create the latest indexes: `bin/rails elasticsearch:indexes:create_latest`
2. Populate them with documents (this hasn't been written yet)
3. Switch over the aliases: `bin/rails elasticsearch:indexes:migrate`

# Notes

## Using Shibboleth locally

Log in as:
* `admin`/`admin@example.org` for admin privileges
* `user`/`user@example.org` for normal-user privileges
