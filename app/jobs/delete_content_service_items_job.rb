##
# Deletes all indexed documents in a given [ContentService].
#
class DeleteContentServiceItemsJob < ApplicationJob
  queue_as :default

  ##
  # @param args [Array<Integer>] One-element array containing a
  #                              [ContentService] at position 0..
  #
  def perform(*args)
    service = args[0]
    service.delete_all_items
  end

end
