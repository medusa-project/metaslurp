class ErrorsController < WebsiteController

  ##
  # Responds to any route not defined in routes.rb via any HTTP method.
  #
  # The purpose of doing this is to override Rails' default 404 handling, which
  # logs not-found requests at error level, resulting in the logs filling up
  # with a million errors involving not being able to find /favicon.ico and
  # other such silliness.
  #
  def not_found
    Rails.logger.debug('Returning HTTP 404 for ' + request.fullpath)
    render template: 'errors/not_found', status: 404, layout: 'application'
  end

end
