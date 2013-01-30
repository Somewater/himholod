class SectionsController < ApplicationController
  def show
    @section = (params[:id] ? Section.find_by_name(params[:id]) : nil)
    if !@section
      render 'main_page/not_found'
    elsif @section.main?
      redirect_to root_path
    elsif @section.name == Section::NEWS_NAME
      @news = News.order("date DESC")
      render 'news/index'
    else
      # показать контент раздела
      if(@section.children.size > 0 || @section.text_pages.size > 1 || @section.ckeditor_assets.size > 0)
        render 'sections/show'
      elsif @section.text_pages.size == 1
        @page = @content = TextPage.find_all_by_section_id(@section.id).first
        render 'text_pages/show' if @page
      else
        # у секции ничего нет
      end
    end
  end
end
