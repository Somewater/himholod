class TextPage < ActiveRecord::Base
  attr_accessible :name, :title, :body, :section_id
  belongs_to :section

  def title
    t = super
    t = self.name if t.blank?
    t
  end
end
