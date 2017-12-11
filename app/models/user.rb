class User < ApplicationRecord

  validates :username, presence: true, length: { maximum: 50 },
            uniqueness: { case_sensitive: false }

  def to_param
    username
  end

  def to_s
    username
  end

end
