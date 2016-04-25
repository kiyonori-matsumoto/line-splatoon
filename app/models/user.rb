class User < ActiveRecord::Base
  validates :line_uid, presence: true

  enum line_message_state: { initial: 0,
                             recieving_statink_id: 1, normal: 99 }
end
