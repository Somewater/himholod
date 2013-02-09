class TextPage < ActiveRecord::Base

  extend ::I18nColumns::Model
  i18n_columns :title, :body

  attr_accessible :name, :section_id
  belongs_to :section

  validates :section, :presence => true
  validates :name, :format => /^[a-z][a-z0-9\-]+$/

#TextPage.find_ids_with_ferret('body_ru:(испаритель пленочные) OR title_ru:(испаритель~0.5)').last.map{|d| TextPage.find(d[:id].to_i) }.map &:title

#TextPage.find_ids_with_ferret('body_ru:(испарители~ OR пленочные~) OR title_ru:(испарители~ OR пленочные~)').last.map{|d| TextPage.find(d[:id].to_i) }.map &:title


  def title
    t = super
    t = self.name if t.blank?
    t
  end

  def to_param
    self.name.to_s.size > 0 ? self.name : self.id
  end
end
