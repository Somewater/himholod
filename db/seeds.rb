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

# delete all in selected classes
[Section, TextPage].each{|c| c.delete_all}

# create ROOT section
#Rake::Task['db:init'].invoke

ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db/fixtures", ['sections', 'text_pages'])

TextPage.create do |t|
  t.name = Section.main.name + '-page'
  t.section = Section.main
  t.title = Section.main.title
  t.body =<<-END
Текст главной страницы. Это главная страница сайта!!!
END
end

Section.all.each do |section|
  if section.children.length == 0
    TextPage.create do |t|
      t.name = section.name + '-page'
      t.section = section
      t.title = section.title
      t.body =  (t.section.title.to_s + ' ') * 10
    end
  end
end
