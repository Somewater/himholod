class Ckeditor::AttachmentFile < Ckeditor::Asset
  has_attached_file :data,
                    :url => "/assets/attachments/:id/:filename",
                    :path => ":rails_root/public/assets/attachments/:id/:filename"
  
  validates_attachment_size :data, :less_than => 100.megabytes
  validates_attachment_presence :data

  attr_accessible :section_id, :data_file_name

  belongs_to :section

  extend ::I18nColumns::Model
  i18n_columns :title
	
	def url_thumb
	  @url_thumb ||= Ckeditor::Utils.filethumb(filename)
	end
end
