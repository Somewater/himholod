class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :set_locale

  def set_locale
    @locale = params[:locale]
    @locale = cookies[:locale] unless @locale
    @locale = 'en' if !@locale && request.host.to_s[-3,3].downcase == 'com'
    @locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first if !@locale && request.env['HTTP_ACCEPT_LANGUAGE']
    @locale = I18n.default_locale unless @locale && I18n.available_locales.index(@locale.to_sym)
    cookies[:locale] = @locale unless cookies[:locale] && cookies[:locale] == @locale.to_s
    I18n.locale = @locale
  end

  def default_url_options(options={})
    options.merge({:locale => I18n.locale})
  end
end
