class Feedback < ActiveRecord::Base
  attr_accessible :name, :email, :topic, :body
end