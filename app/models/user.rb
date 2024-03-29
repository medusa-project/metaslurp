# frozen_string_literal: true

class User < ApplicationRecord

  DEVELOPMENT_ADMIN_USERNAME = 'admin'

  has_many :harvests, inverse_of: :user

  validates :username, presence: true, length: { maximum: 50 },
            uniqueness: { case_sensitive: false }

  before_create :reset_api_key

  def medusa_admin?
    if Rails.env.development? || Rails.env.test?
      return self.username == DEVELOPMENT_ADMIN_USERNAME
    end
    group     = Configuration.instance.medusa_admins_group
    cache_key = Digest::MD5.hexdigest("#{self.username} ismemberof #{group}")
    Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      begin
        user = UiucLibAd::User.new(cn: self.username)
        user.is_member_of?(group_cn: group)
      rescue UiucLibAd::NoDNFound
        false
      end
    end
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
