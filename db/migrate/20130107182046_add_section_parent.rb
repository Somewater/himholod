class AddSectionParent < ActiveRecord::Migration
  def up
    add_column :sections, :parent_id, :integer, :default => 0
  end

  def down
    remove_column :sections, :parent_id
  end
end
