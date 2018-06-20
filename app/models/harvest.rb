##
# Represents a process of harvesting one or more records from a source service
# into the application.
#
# Harvests are created by a harvester as a first step of harvesting content.
# A harvest key is associated with each record ingested during the harvest.
# When the harvest succeeds, fails, or is aborted, the harvester marks it as
# such via the HTTP API.
#
# # Attributes
#
# * content_service_id:  ID of the ContentService into which content is being
#                        harvested.
# * created_at:          Managed by Rails.
# * ended_at:            Time the harvest ended.
# * key:                 Identifier external to the application.
# * id:                  Identifier within the application.
# * message:             Contains arbitrary information from the harvester.
#                        If num_failed is greater than 0, this may contain
#                        info about the failures.
# * num_items:           Total number of items that will be harvested.
# * num_failed:          Number of items that failed to ingest.
# * num_succeeded:       Number of items successfully ingested.
# * status:              One of the Harvest::Status constant values.
# * updated_at:          Managed by Rails.
#
class Harvest < ApplicationRecord

  ##
  # To add a status:
  #
  # 1. Add it here
  # 2. Add it to AdminHelper::harvest_status_badge()
  # 3. Update usable?()
  #
  class Status
    NEW = 0
    RUNNING = 1
    ABORTED = 2
    SUCCEEDED = 3
    FAILED = 4

    ##
    # @return [Enumerable<Integer>] Integer values of all statuses.
    #
    def self.all
      self.constants.map{ |c| self.const_get(c) }
    end

    ##
    # @param status One of the Status constants
    # @return Human-readable status
    #
    def self.to_s(status)
      case status
        when NEW
          'New'
        when RUNNING
          'Running'
        when ABORTED
          'Aborted'
        when SUCCEEDED
          'Succeeded'
        when FAILED
          'Failed'
        else
          self.to_s
      end
    end
  end

  belongs_to :content_service, inverse_of: :harvests

  validates :key, presence: true, uniqueness: { case_sensitive: false }
  validates :status, inclusion: { in: Status.all }, allow_blank: false

  after_initialize :populate_key
  before_validation :restrict_key_changes
  before_save :update_ended_at

  ##
  # @return [Time]
  #
  def estimated_completion
    now = Time.zone.now
    if self.progress == 0.0
      now.advance(years: 1)
    elsif self.progress == 1.0
      now
    else
      duration = now - self.created_at
      Time.zone.at(now + (duration * (1 / self.progress)))
    end
  end

  ##
  # @return [Float]
  #
  def items_per_second
    self.num_succeeded / ((self.ended_at || Time.zone.now) - self.created_at)
  end

  ##
  # @return [Float] Between 0 and 1.
  #
  def progress
    self.num_items > 0 ?
        (self.num_succeeded + self.num_failed) / self.num_items.to_f : 0.0
  end

  def to_param
    key
  end

  def to_s
    key
  end

  ##
  # @param json [Hash]
  # @return [void]
  #
  def update_from_json(json)
    raise ArgumentError, 'Argument must be a hash' unless json.respond_to?(:keys)
    json = json.stringify_keys

    Harvest.attribute_names.each do |attr|
      value = json[attr]
      update_attribute(attr, value) if value.present?
    end

    self.save!
  end

  ##
  # @return [Boolean]
  #
  def usable?
    [Status::NEW, Status::RUNNING].include?(self.status)
  end

  private

  def populate_key
    self.key = SecureRandom.hex if self.key.blank?
  end

  ##
  # Disallows changes to `key`.
  #
  def restrict_key_changes
    throw(:abort) if !self.new_record? and self.key_was != self.key
  end

  def update_ended_at
    self.ended_at = Time.zone.now unless self.usable?
  end

end
