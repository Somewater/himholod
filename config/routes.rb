Himholod::Application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :admin_users
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  match "feedback/add(.:format)", :to => 'feedbacks#add', :as => 'feedback_add'
  match "pdf_viewer/*filepath", :to => "pdf_viewer#show", :as => 'pdf_viewer_show'
  match "downloader/*filepath", :to => "pdf_viewer#download", :as => 'pdf_viewer_download'

  scope "(:locale)", :locale => /ru|en/ do
    resources :sections, :only => [:show] do
      match "(:page)", :to => "sections#show", :page => /\d+/
    end
    resources :text_pages, :only => [:show], :path => "pages"
    resources :news, :only => [:show]
    match 'print/:type/:id', :to => 'print#show', :as => 'print'
    match 'sitemap.xml' => 'sitemaps#sitemap'
    match "search/(:page)", :to => 'search#search_words'
    root :to => 'main_page#index'
    match 'not_found' => 'main_page#not_found', :as => 'not_found'
    match '*paths' => 'main_page#not_found'
  end
end
