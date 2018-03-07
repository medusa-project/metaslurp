##
# Encapsulates a role in a role-based access control (RBAC) system.
#
class Role < ApplicationRecord

  has_and_belongs_to_many :users

  validates :key, presence: true, length: { maximum: 30 },
            uniqueness: { case_sensitive: false }
  validates :name, presence: true, length: { maximum: 255 },
            uniqueness: { case_sensitive: false }

  before_destroy :validate_destroy

  def required
    key == 'admin'
  end

  def to_param
    key
  end

  def to_s
    key
  end

  private

  def validate_destroy
    if key == 'admin'
      errors.add(:base, 'Cannot delete the administrator role')
      throw(:abort)
    end
  end

end
