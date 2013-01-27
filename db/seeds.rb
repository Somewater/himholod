# encoding: utf-8

#main = Section.create({name: Section::MAIN_NAME, title: 'Главная', parent_id: nil})
#
#Section.create([
#                   {name: 'contacts', title: 'Contacts', parent: main},
#               ])
#
#TextPage.create([
#                {name: 'main', section_id: Section.find_by_name('main').id},
#                {name: 'contacts', section_id: Section.find_by_name('contacts').id},
#                ])

require 'active_record/fixtures'
require "rake"
require "i18n_columns"

# delete all in selected classes
[Section, TextPage].each{|c| c.delete_all}

# create ROOT section
#Rake::Task['db:init'].invoke

ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db/fixtures", ['sections', 'text_pages'])
