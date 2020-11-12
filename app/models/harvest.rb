##
# Represents a process of harvesting one or more records from a
# {ContentService} into the application.
#
# Harvest instances are created by a harvester as a first step of a harvesting
# process. A harvest key is associated with each record ingested during the
# harvest. When the harvest finally succeeds, fails, or is aborted, the
# harvester marks it as such via the HTTP API.
#
# The harvester is a separate application called
# [metaslurper](https://github.com/medusa-project/metaslurper).
#
# # Limiting Harvest Sizes
#
# Some {ContentServices} take a long time to harvest fully. The
# `max_items_to_harvest` configuration key can be used to limit the number of
# items that get harvested. Effectively this just adds a `-max_entities`
# argument to the metaslurper invocation.
#
# # Attributes
#
# * `content_service_id` ID of the {ContentService} into which content is being
#                        harvested.
# * `created_at`         Managed by Rails.
# * `ended_at`           Time the harvest ended.
# * `key`                Identifier external to the application.
# * `id`                 Identifier within the application.
# * `max_num_items`      Maximum number of items to harvest, regardless of how
#                        many are actually contained in the {ContentService}
#                        (see `num_items`).
# * `message`            Contains arbitrary information from the harvester.
#                        If `num_failed` is greater than 0, this may contain
#                        information about the failures.
# * `num_items`          Number of items available in the {ContentService}.
#                        This may be larger than the number of items that will
#                        actually be harvested (see `max_items`).
# * `num_failed`         Number of items that failed to ingest.
# * `num_succeeded`      Number of items successfully ingested.
# * `status`             One of the {Harvest::Status} constant values.
# * `updated_at`         Managed by Rails.
# * `user_id`            ID of the {User} who triggered the harvest.
#
class Harvest < ApplicationRecord

  ##
  # To add a status:
  #
  # 1. Add it here
  # 2. Add it to {AdminHelper#harvest_status_badge}
  # 3. Update {usable?}
  #
  class Status
    NEW       = 0
    RUNNING   = 1
    ABORTED   = 2
    SUCCEEDED = 3
    FAILED    = 4

    ##
    # @return [Enumerable<Integer>] Integer values of all statuses.
    #
    def self.all
      self.constants.map{ |c| self.const_get(c) }
    end

    ##
    # @param status One of the {Status} constants
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
  belongs_to :user, inverse_of: :harvests

  validates :key, presence: true, uniqueness: { case_sensitive: false }
  validates :status, inclusion: { in: Status.all }, allow_blank: false

  after_initialize :populate_key
  before_validation :restrict_key_changes, :restrict_status_changes
  before_save :update_ended_at
  before_destroy :validate_destroyable

  ##
  # @return [Integer] Total number of items to harvest, taking into account
  #                   {num_items} and {max_num_items}.
  #
  def canonical_num_items
    (max_num_items.to_i > 0) ? [max_num_items, num_items].min : num_items
  end

  ##
  # @return [String] CloudWatch log URI within the AWS web console.
  #
  def cloudwatch_log_uri
    if self.ecs_task_uuid
      return sprintf('https://%s.console.aws.amazon.com/cloudwatch/home?region=%s#logEventViewer:group=/ecs/metadata;stream=ecs/metaslurper/%s',
                     ENV['AWS_REGION'], ENV['AWS_REGION'],
                     self.ecs_task_uuid)
    end
    nil
  end

  ##
  # @return [Boolean]
  #
  def destroyable?
    ![Status::RUNNING].include?(self.status)
  end

  ##
  # @return [String,nil] ECS task URI within the AWS web console, or nil if
  #                      {ecs_task_uuid} is not set.
  #
  def ecs_task_uri
    if self.ecs_task_uuid
      config = Configuration.instance
      return sprintf('https://%s.console.aws.amazon.com/ecs/home?region=%s#/clusters/%s/tasks/%s/details',
                     ENV['AWS_REGION'], ENV['AWS_REGION'], config.ecs_cluster,
                     self.ecs_task_uuid)
    end
    nil
  end

  ##
  # @return [Time]
  #
  def estimated_completion
    now = Time.zone.now
    if self.progress == 0.0
      nil
    elsif self.progress == 1.0
      now
    elsif self.items_per_second > 0
      Time.zone.at(now + ((self.num_items - self.num_succeeded - self.num_failed) / self.items_per_second))
    else
      nil
    end
  end

  ##
  # @return [Float]
  #
  def items_per_second
    self.num_succeeded / ((self.ended_at || Time.zone.now) - self.created_at).to_f
  end

  ##
  # @return [Float] Between 0 and 1.
  #
  def progress
    return 0.0 if status == Status::NEW
    value = (self.num_items > 0) ?
        (self.num_succeeded + self.num_failed) / self.num_items.to_f : 1.0
    (value > 1) ? 1 : value
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
      send(attr.to_s + '=', value) if value.present?
    end

    # The JSON may include a `messages` array, which must be joined into a
    # `message` string.
    if json['messages'].respond_to?(:each)
      self.message = json['messages'].join("\n")
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

  ##
  # Disallows changes to a terminal status.
  #
  def restrict_status_changes
    terminals = [Status::ABORTED, Status::SUCCEEDED, Status::FAILED]
    throw(:abort) if !self.new_record? and self.status_changed? and
        terminals.include?(self.status_was)
  end

  def update_ended_at
    self.ended_at ||= (Time.zone&.now || Time.now) unless self.usable?
  end

  def validate_destroyable
    throw(:abort) unless destroyable?
  end

end
