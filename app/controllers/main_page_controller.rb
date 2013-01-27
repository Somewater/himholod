class MainPageController < ApplicationController
  def index
    @section = Section.main
    @page = @content = TextPage.find_all_by_section_id(@section.id).first
    render 'sections/show_text_page' if @page
  end

  def not_found
  end
end
