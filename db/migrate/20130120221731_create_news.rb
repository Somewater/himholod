class CreateNews < ActiveRecord::Migration

  require "i18n_columns"
  include ::I18nColumns::Migrate

  def up
    create_table :news do |t|
      t.string :name
      t.date :date
      t.timestamps
    end

    up_i18n_column(:news, :title, :string)
    up_i18n_column(:news, :body, :text)
  end

  def down
    drop_table :news
  end
end
