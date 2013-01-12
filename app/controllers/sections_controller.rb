class SectionsController < ApplicationController
  def show
    @section = (params[:id] ? Section.find_by_name(params[:id]) : nil)
    if !@section || @section.main?
      redirect_to root_path
    else
      @page = @content = TextPage.find_all_by_section_id(@section.id).first
      render 'sections/show_text_page' if @page
    end
  end
end
