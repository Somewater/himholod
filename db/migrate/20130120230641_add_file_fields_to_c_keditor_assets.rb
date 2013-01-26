class AddFileFieldsToCKeditorAssets < ActiveRecord::Migration

  require "i18n_columns"
  include ::I18nColumns::Migrate

  def up
    up_i18n_column :ckeditor_assets, :title, :string
    add_column :ckeditor_assets, :section_id, :integer
  end

  def down
    down_i18n_column :ckeditor_assets, :title, :string
    remove_column :ckeditor_assets, :section_id
  end
end
