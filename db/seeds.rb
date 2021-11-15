# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Options
Option.set(Option::Keys::ADMINISTRATOR_EMAIL, 'admin@example.org')
Option.set(Option::Keys::COPYRIGHT_STATEMENT,
           'Copyright © 2018 My Great Organization. All rights reserved.')
Option.set(Option::Keys::DEFAULT_RESULT_WINDOW, 30)
Option.set(Option::Keys::ORGANIZATION_NAME, 'My Great Organization')
Option.set(Option::Keys::WEBSITE_NAME,
           'My Great Organization Metadata Gateway')

# Users
User.create!(username: 'admin')

# Elements
ElementDef.create!(index: 0, name: 'title', label: 'Title',
                   searchable: true, sortable: true, facetable: false)
ElementDef.create!(index: 1, name: 'description', label: 'Description',
                   searchable: true, sortable: false, facetable: false)
ElementDef.create!(index: 2, name: 'date', label: 'Date',
                   data_type: ElementDef::DataType::DATE,
                   searchable: false, sortable: true, facetable: false)
