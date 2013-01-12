class PrintController < ApplicationController

  PAGE = 'page'

  def show
    type = params[:type]
    id = params[:id]

    if(type == PAGE)
      @page = TextPage.find(id)
      if(@page)
        render :text => @page.body
        return
      end
    end

    render 'main_page/not_found'
  end
end