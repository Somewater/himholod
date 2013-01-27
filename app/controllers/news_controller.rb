class NewsController < ApplicationController

  def show
    @page = News.where(:id => params[:id]).first || News.find_by_name(params[:id])
  end

  def index

  end
end
