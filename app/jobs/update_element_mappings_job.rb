# frozen_string_literal: true

##
# Updates a [ContentService]'s element mappings based on the elements ascribed
# to an [Item].
#
class UpdateElementMappingsJob < ApplicationJob
  queue_as :default

  ##
  # @param args [Array] One-element array with [Item] ID at position 0.
  #
  def perform(*args)
    item = Item.find(args[0])
  rescue ActiveRecord::RecordNotFound
    # highly unlikely, but unrecoverable
  else
    item.content_service.update_element_mappings(item.elements)
  end
end
