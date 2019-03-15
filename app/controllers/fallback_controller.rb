##
# Handles requests that don't match any of the other routes.
#
class FallbackController < WebsiteController

  DLS_HOST = ::Configuration.instance.dls_url

  ##
  # Responds to [all methods] /*
  #
  def handle
    path = request.fullpath

    # DLS routes. This includes most public routes, except for /search and a
    # few others.
    if path.match?(/^(\/agents|\/binaries|\/collections|\/downloads|\/harvest|\/items|\/oai-pmh)/)
      redirect_to "#{DLS_HOST}#{path}", status: 301
    # Old CONTENTdm routes. DLS handles these too.
    elsif path.match(/^(\/u$|\/cdm|\/cgi-bin|\/oai\/|\/projects|\/ui|\/utils\/getthumbnail)/)
      redirect_to "#{DLS_HOST}#{path}", status: 301
    else
      not_found
    end
  end

  private

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
