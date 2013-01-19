class TextPage < ActiveRecord::Base

  extend ::I18nColumns::Model
  i18n_columns :title, :body

  attr_accessible :name, :section_id
  belongs_to :section

  def title
    t = super
    t = self.name if t.blank?
    t
  end
end
