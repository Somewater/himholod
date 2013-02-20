class News < ActiveRecord::Base
  attr_accessible :name, :date

  extend ::I18nColumns::Model
  i18n_columns :title, :body, :ferret => true

  before_save :set_date

  validates :date, :presence => true
  validates :name, :format => /^([a-z][a-z0-9\-]+|)$/

  def self.top
    self.order("date DESC").take(5)
  end

  def to_param
    self.name.to_s.size > 0 ? self.name : self.id
  end

  private
  def set_date
    self.date = Time.new unless self.date
  end
end
