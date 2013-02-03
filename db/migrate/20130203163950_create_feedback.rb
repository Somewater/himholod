class CreateFeedback < ActiveRecord::Migration
  def up
    create_table "feedbacks" do |t|
      t.string  "name"
      t.string  "email"
      t.string  "topic"
      t.text    "body"
      t.timestamps
    end
  end

  def down
    drop_table "feedbacks"
  end
end
