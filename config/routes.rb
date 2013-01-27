Himholod::Application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :admin_users
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  scope "(:locale)", :locale => /ru|en|fr/ do
    resources :sections, :only => [:show]
    resources :text_pages, :only => [:show], :path => "pages"
    match 'print/:type/:id', :to => 'print#show', :as => 'print'
    match 'sitemap.xml' => 'sitemaps#sitemap'
    match "search", :to => 'search#search_words'
    root :to => 'main_page#index'
    match 'not_found' => 'main_page#not_found', :as => 'not_found'
    match '*paths' => 'main_page#not_found'
  end
end
