class User < ApplicationRecord

  has_many :harvests, inverse_of: :user

  validates :username, presence: true, length: { maximum: 50 },
            uniqueness: { case_sensitive: false }

  before_create :reset_api_key

  def admin?
    true
  end

  def reset_api_key
    self.api_key = SecureRandom.base64
  end

  def to_param
    username
  end

  def to_s
    username
  end

end
