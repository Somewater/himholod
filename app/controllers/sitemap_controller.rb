class SitemapController < ApplicationController
  def index
    @section = Section.find_by_name('sitemap')
    @root = Section.main
  end
end