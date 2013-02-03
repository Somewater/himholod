class AddPictureToSections < ActiveRecord::Migration
  def up
    add_column :sections, :picture_id, :integer
  end

  def down
    remove_column :sections, :picture_id
  end
end
