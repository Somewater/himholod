class AddTranslationFields < ActiveRecord::Migration


  require "i18n_columns"
  include ::I18nColumns::Migrate

  def up
    # SECTION
    up_i18n_column(:sections, :title, :string, true)

    # TEXT PAGE
    up_i18n_column(:text_pages, :title, :string, true)
    up_i18n_column(:text_pages, :body, :text, true)
  end

  def down
    # SECTION
    down_i18n_column(:sections, :title, :string, true, :null => false)

    # TEXT PAGE
    down_i18n_column(:text_pages, :title, :string, true)
    down_i18n_column(:text_pages, :body, :text, true)
  end
end
