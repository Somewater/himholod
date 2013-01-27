class MainPageController < ApplicationController
  def index
    @section = Section.main
    @page = @content = TextPage.find_all_by_section_id(@section.id).first
    render 'text_pages/show' if @page
  end

  def not_found
  end
end
