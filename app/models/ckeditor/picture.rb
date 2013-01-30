class Ckeditor::Picture < Ckeditor::Asset
  has_attached_file :data,
                    :url  => "/assets/pictures/:id/:style_:basename.:extension",
                    :path => ":rails_root/public/assets/pictures/:id/:style_:basename.:extension",
	                  :styles => { :content => '1920>', :thumb => '118x100#' }

  attr_accessible :width, :height
	
	validates_attachment_size :data, :less_than => 5.megabytes
	validates_attachment_presence :data
	
	def url_content
	  url(:content)
	end
end
