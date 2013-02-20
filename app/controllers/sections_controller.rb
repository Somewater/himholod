class SectionsController < ApplicationController
  def show
    @section = (params[:id] || params[:section_id] ? Section.find_by_name(params[:id] || params[:section_id]) : nil)
    @page_number = [(params[:page] || '1').to_i, 1].max - 1
    if !@section
      render 'main_page/not_found'
    elsif @section.main?
      redirect_to root_path
    elsif @section.name == Section::NEWS_NAME
      @pages = (News.count.to_f / NewsController::PER_PAGE).ceil
      @news = News.order("date DESC").limit(NewsController::PER_PAGE).offset(@page_number * NewsController::PER_PAGE)
      render 'news/index'
    else
      @feedback_add_form = @section.feedback?
      @yandex_map = @section.address?
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
