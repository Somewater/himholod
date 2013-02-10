class PrintController < ApplicationController

  PAGE = 'page'
  NEWS = 'news'

  def show
    type = params[:type]
    id = params[:id]

    if(type == PAGE)
      @page = TextPage.where(:id => params[:id]).first || TextPage.find_by_name(params[:id])
      if(@page)
        render :text => @page.body
        return
      end
    elsif(type == NEWS)
      @page = News.find(id)
      if(@page)
        render :text => @page.body
        return
      end
    end

    render 'main_page/not_found'
  end
end