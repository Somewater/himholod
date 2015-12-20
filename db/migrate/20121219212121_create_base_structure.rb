class CreateBaseStructure < ActiveRecord::Migration
  def change
	  create_table "admin_users", :force => true do |t|
		t.string   "email",                  :default => "", :null => false
		t.string   "encrypted_password",     :default => "", :null => false
		t.string   "reset_password_token"
		t.datetime "reset_password_sent_at"
		t.datetime "remember_created_at"
		t.integer  "sign_in_count",          :default => 0
		t.datetime "current_sign_in_at"
		t.datetime "last_sign_in_at"
		t.string   "current_sign_in_ip"
		t.string   "last_sign_in_ip"
		t.datetime "created_at",                             :null => false
		t.datetime "updated_at",                             :null => false
	  end

	  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
	  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

	  create_table "ckeditor_assets", :force => true do |t|
		t.string   "data_file_name",                  :null => false
		t.string   "data_content_type"
		t.integer  "data_file_size"
		t.integer  "assetable_id"
		t.string   "assetable_type",    :limit => 30
		t.string   "type",              :limit => 30
		t.integer  "width"
		t.integer  "height"
		t.datetime "created_at",                      :null => false
		t.datetime "updated_at",                      :null => false
	  end

	  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"
	  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"

	  create_table "rails_admin_histories", :force => true do |t|
		t.text     "message"
		t.string   "username"
		t.integer  "item"
		t.string   "table"
		t.integer  "month",      :limit => 2
		t.integer  "year",       :limit => 8
		t.datetime "created_at",              :null => false
		t.datetime "updated_at",              :null => false
	  end

	  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

	  create_table "sections", :force => true do |t|
		t.string   "name",                         :null => false
		t.string   "title",                        :null => false
		t.integer  "weight",     :default => 0
		t.datetime "created_at",                   :null => false
		t.datetime "updated_at",                   :null => false
		t.boolean  "visible",    :default => true
	  end

	  add_index "sections", ["name"], :name => "index_sections_on_name", :unique => true

	  create_table "text_pages", :force => true do |t|
		t.string   "name"
		t.string   "title"
		t.text     "body"
		t.integer  "section_id"
		t.datetime "created_at", :null => false
		t.datetime "updated_at", :null => false
	  end

	  add_index "text_pages", ["name"], :name => "index_text_pages_on_name", :unique => true
  end
end
