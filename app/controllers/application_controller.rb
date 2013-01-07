class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_default_section

  private
  def set_default_section
    @section = Section.main
  end
end
