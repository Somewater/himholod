class AddDescriptionToAssets < ActiveRecord::Migration
  require "i18n_columns"
  include ::I18nColumns::Migrate

  def up
    up_i18n_column :ckeditor_assets, :description, :text
  end

  def down
    down_i18n_column :ckeditor_assets, :description, :text
  end
end
