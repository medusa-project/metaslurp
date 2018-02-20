This is a basic getting-started guide for developers.

# Quick Links

* [JIRA board](https://bugs.library.illinois.edu/secure/RapidBoard.jspa?rapidView=20080)

# Dependencies

* PostgreSQL 9.x
* Elasticsearch 6
    * The [ICU Analysis Plugin](https://www.elastic.co/guide/en/elasticsearch/plugins/current/analysis-icu.html)
      is also required

# Installation

## 1) Install RVM:

`$ \curl -sSL https://get.rvm.io | bash -s stable`

`$ source ~/.bash_profile`

## 2) Clone the repository:

`$ git clone https://github.com/medusa-project/metaslurp.git`

`$ cd metaslurp`

## 3) Install Ruby

`$ rvm install "$(< .ruby-version)" --autolibs=0`

## 4) Install Bundler

`$ gem install bundler`

## 5) Install the gems needed by the application:

`$ bundle install`

## 6) Configure the application

`$ cp config/database.template.yml config/database.yml` and edit as necessary

`$ cp config/shibboleth.template.yml config/shibboleth.yml`

## 7) Create and seed the database

`$ bin/rails db:setup`

## 8) Create the Elasticsearch indexes

`$ bin/rails elasticsearch:indexes:create_all_latest`

# Upgrading

## Migrating the database schema

`bin/rails db:migrate`

## Migrating the Elasticsearch index schema(s)

Rather than trying to change the existing indexes in place, the recommended
procedure is to create a new set of indexes, populate them with documents, and
then switch the application over to use them. The steps are:

1. `bin/rails elasticsearch:indexes:create_all_latest`
2. `bin/rails elasticsearch:indexes:populate_latest`
3. `bin/rails elasticsearch:indexes:migrate_to_latest`
4. Restart Rails

# Notes

## Using Shibboleth locally

Log in as user `admin` and password `admin@example.org`.
