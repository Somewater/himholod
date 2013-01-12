class MainPageController < ApplicationController
  def index
    @section = Section.main
  end

  def not_found
  end
end
