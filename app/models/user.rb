class User < ActiveRecord::Base
  validates :line_uid, presence: true
end
