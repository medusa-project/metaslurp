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
Option.set(Option::Keys::FACET_TERM_LIMIT, 10)
Option.set(Option::Keys::ORGANIZATION_NAME, 'My Great Organization')
Option.set(Option::Keys::WEBSITE_NAME,
           'My Great Organization Metadata Gateway')

# Roles
admin_role = Role.create!(key: 'admin', name: 'Administrators')

# Users
admin = User.new(username: 'admin')
admin.roles << admin_role
admin.save!

# Elements
Element.create!(index: 0, name: 'title', label: 'Title',
                facetable: false)
Element.create!(index: 1, name: 'description', label: 'Description',
                sortable: false, facetable: false)
