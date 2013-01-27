#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Himholod::Application.load_tasks

namespace :db do
  desc "Clear all db"
  task :clear => :environment do
    News.delete_all
    Section.delete_all
    TextPage.delete_all
    Ckeditor::Asset.delete_all

    require "fileutils"
    FileUtils.rm_rf("#{Rails.public_path.to_s}/assets", secure: true)
  end

end

desc "Drop DB, Create DB, Import data"
task :megadeploy => :environment do
  if(ENV['DB'])
    Rake::Task["db:drop"].execute rescue puts "DB not exist"
    Rake::Task["db:create"].execute rescue puts "DB already exist"
  end
  Rake::Task["db:clear"].execute
  Rake::Task["db:migrate"].execute
  Rake::Task["db:seed"].execute
  Rake::Task["import:topics"].execute
  Rake::Task["import:files"].execute
  Rake::Task["import:news"].execute

  Section.all.each do |section|
    if(section.text_pages.size == 0 && section.children.size == 0 &&
      section.name != Section::MAIN_NAME && section.name != 'news')
      TextPage.create do |t|
        t.name = section.name + '-page'
        t.section = section
        t.title_all = section.title
        t.body_all =  (t.section.title.to_s + ' ') * 10
      end
    end
  end
end

