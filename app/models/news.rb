class News < ActiveRecord::Base
  attr_accessible :name, :date

  extend ::I18nColumns::Model
  i18n_columns :title, :body
end
