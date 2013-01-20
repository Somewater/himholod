class Ckeditor::Asset < ActiveRecord::Base
  include Ckeditor::Orm::ActiveRecord::AssetBase
  include Ckeditor::Backend::Paperclip

  attr_accessible :width, :height
end
