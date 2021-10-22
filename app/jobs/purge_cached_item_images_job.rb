##
# Purges all images associated with a given [Item] from the image server's
# cache.
#
class PurgeCachedItemImagesJob < ApplicationJob
  queue_as :default

  ##
  # @param args [Array] One-element array containing an [Item] ID.
  #
  def perform(*args)
    item = Item.find(args[0])
  rescue ActiveRecord::RecordNotFound
    # highly unlikely, but unrecoverable
  else
    item.purge_cached_images
  end
end
