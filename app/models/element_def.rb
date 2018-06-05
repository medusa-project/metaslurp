##
# Metadata element definition.
#
# # Attributes
#
# * created_at:  Managed by Rails.
# * data_type:   Expected data type of the element values, which influences how
#                they are indexed.
# * description: Element description, for administrative purposes. Does not
#                appear in public.
# * facetable:   Whether a facet for the element may appear in results views.
# * label:       Public, human-readable element name.
# * name:        Element name.
# * searchable:  Whether the element is searchable.
# * sortable:    Whether the element can be sorted on in results views.
# * updated_at:  Managed by Rails.
#
class ElementDef < ApplicationRecord

  ##
  # Type of data expected to be stored in an element defined by an ElementDef
  # instance.
  #
  class DataType

    # Free-form string.
    STRING = 0

    # Normalized date.
    DATE = 1

    ##
    # @return [Enumerable<Integer>] Integer values of all data types.
    #
    def self.all
      self.constants.map{ |c| self.const_get(c) }
    end

    ##
    # @param data_type [Integer] One of the DataType constants.
    # @return                    Human-readable data type.
    #
    def self.to_s(data_type = nil)
      case data_type
        when DataType::DATE
          'Date'
        when DataType::STRING
          'String'
        else
          ''
      end
    end
  end

  attr_accessor :indexed_keyword_field

  has_many :element_mappings, inverse_of: :element_def

  validates :data_type, inclusion: { in: DataType.all }, allow_blank: false
  validates :label, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true, format: { with: /\A[-a-zA-Z0-9]+\Z/ },
            uniqueness: { case_sensitive: false }

  before_update :restrict_name_changes

  ##
  # @param struct [Hash] Deserialized hash from JSON.parse()
  # @return [ElementDef] New non-persisted instance.
  #
  def self.from_json_struct(struct)
    e = ElementDef.new
    e.update_from_json_struct(struct)
    e
  end

  ##
  # @return [String] Name of the indexed field for the instance.
  #
  def indexed_field
    case self.data_type
      when DataType::DATE
        [LocalElement::DATE_INDEX_PREFIX, self.name].join
      else
        LocalElement.new(name: self.name).indexed_field
    end
  end

  ##
  # @return [String] Name of the indexed keyword field for the instance.
  #
  def indexed_keyword_field
    if @indexed_keyword_field
      @indexed_keyword_field
    else
      case self.data_type
        when DataType::DATE
          [LocalElement::DATE_INDEX_PREFIX, self.name].join
        else
          LocalElement.new(name: self.name).indexed_keyword_field
      end
    end
  end

  ##
  # @return [String] Name of the indexed sort field for the instance.
  #
  def indexed_sort_field
    case self.data_type
      when DataType::DATE
        [LocalElement::DATE_INDEX_PREFIX, self.name].join
      else
        LocalElement.new(name: self.name).indexed_sort_field
    end
  end

  def to_param
    name
  end

  def to_s
    "#{name}"
  end

  def update_from_json_struct(struct)
    self.name = struct['name']
    self.label = struct['label']
    self.description = struct['description']
    self.save!
  end

  ##
  # Disallows changes to the name.
  #
  def restrict_name_changes
    self.name_was == self.name
  end

end
