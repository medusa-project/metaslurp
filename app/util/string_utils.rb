class StringUtils

  ##
  # Strips leading English and most French articles from a string.
  #
  # @param str [String] String to strip articles from.
  # @return [String] New string with leading articles stripped.
  #
  def self.strip_leading_articles(str)
    # See: http://access.rdatoolkit.org/rdaappc_rdac-26.html

    # English: a, an, d', de, the, ye
    # French:  l', la, le, les, un* (skipped), une* (skipped)
    str.gsub(/^(a |an |d'|d’|de |the |ye |l'|l’|la |le |les )/i, '')
  end

  ##
  # Rails' truncate() method has a bug that causes its output to not work with
  # raw() as of Rails 5.2. This is an alternative that does work.
  #
  # @param string [String]
  # @param length [Integer]
  # @param indicator [String] Truncation indicator.
  # @return [String] Truncated string, or the input string if shorter than the
  #                  given length.
  #
  def self.truncate(string, length, indicator = nil)
    if string.present? and string.length > length
      count = 0
      words = string.split(' ')
      new_words = []

      words.each_with_index do |word, index|
        count += word.length + ((index > 0) ? 1 : 0) # don't forget the space
        if count <= length
          new_words << word
        else
          break
        end
      end

      new_str = new_words.join(' ')
      indicator = '...' if indicator.blank?
      return new_str + indicator
    else
      return string
    end
  end

end
