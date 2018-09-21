##
# Helper class for converting times and durations.
#
class TimeUtils

  MONTHS = %w(january february march april may june july august september
              october november december)

  ##
  # Tries to create a Time instance from an arbitrary date string as might
  # appear in MARC, DC, or some other free-form text metadata.
  #
  # Many of these formats were gleaned from Medusa Book Tracker records.
  #
  # Supported string formats:
  #
  # | ID | Format                |
  # |----|-----------------------|
  # | AA | ISO-8601 full         |
  # | AB | YYYY:MM:DD HH:MM:SS   |
  # | AC | YYYY:MM:DD            |
  # | AD | YYYY-MM-DD            |
  # | AE | YYYY                  |
  # | AF | [YYYY]                |
  # | AG | [[YYYY]               |
  # | AH | YYYY]                 |
  # | AI | [YYYY?]               |
  # | AJ | YYYY?]                |
  # | AK | YYYY, cYYYY           |
  # | AL | cYYYY                 |
  # | AM | [cYYYY]               |
  # | AN | ©YYYY                 |
  # | AO | Month YYYY            |
  # | AP | Month, YYYY           |
  # | AQ | [YYYY or YYYY]        |
  # | AR | MM-YYYY               |
  # | AS | MM-DD-YYYY            |
  # | AT | DD Month YYYY         |
  # | AU | YYYY [i.e. YYYY-YY]   |
  # | AV | YYYY, i.e. YYYY-      |
  # | AW | [cYYYY, YYYY]         |
  # | AX | cYYYY [cYYYY or YYYY] |
  # | AY | cYYYY, YYYY           |
  # | AZ | [cYYYY.] YYYY         |
  # | BA | ss. YYYY              |
  # | BB | MDCCCXLVI [YYYY]      |
  #
  # All formats may contain trailing periods. Parentheses are normalized as
  # square brackets.
  #
  # Supported range formats (the beginning of the range is used):
  #
  # | ID | Format                  |
  # |----|-------------------------|
  # | NA | YYYY-                   |
  # | NB | YYYY-YYYY               |
  # | NC | YYYY-, cYYYY            |
  # | ND | YYY-]                   |
  # | NE | [YYYY-YY]               |
  # | NF | [between YYYY and YYYY] |
  # | NG | [YYYY]-<YYYY >          |
  # | NH | [cYYYY-YYYY]            |
  # | NI | cYYYY-YYYY              |
  # | NJ | cYYYY-                  |
  # | NK | YYYY/YYYY-              |
  # | NL | YYYY/YY-                |
  # | NM | cYYYY-cYYYY             |
  # | NN | [cYYYY]-YYYY            |
  # | NO | [YYYY/YYYY-YYYY/YYYY    |
  # | NP | YYYY/YYYY-YYYY/YY       |
  #
  # @param date [String]
  # @return [Time] Time instance in UTC, or nil if the given date string is
  #                empty.
  # @raises [ArgumentError] if the given date string cannot be parsed.
  #
  def self.string_date_to_time(date)
    if date
      date = date.chomp('.')

      # Remove roman numerals.
      date.gsub!(/MD\S*/, '')
      date.strip!

      # Normalize () as []
      if date[0] == '(' and date[date.length - 1] == ')'
        date = '[' + date[1..date.length - 2] + ']'
      end

      # If the date begins with a bracket, ensure it ends with one, and vice
      # versa.
      if date[0] == '[' and date[date.length - 1] != ']'
        date += ']'
      elsif date[0] != '[' and date[date.length - 1] == ']'
        date = '[' + date
      end

      iso8601 = nil
      # AA
      if date.match(/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(\.\d+)?(([+-]\d\d:\d\d)|Z)?$/i)
        date += 'Z' unless date.end_with?('Z')
        iso8601 = date
      # AB
      elsif date.match(/[0-9]{4}:[0-1][0-9]:[0-3][0-9] [0-1][0-9]:[0-5][0-9]:[0-5][0-9]/)
        parts = date.split(' ')
        date_parts = parts.first.split(':')
        time_parts = parts.last.split(':')
        iso8601 = sprintf('%s-%s-%sT %s:%s:%sZ',
                          date_parts[0], date_parts[1], date_parts[2],
                          time_parts[0], time_parts[1], time_parts[2])
      # AC
      elsif date.match(/[0-9]{4}:[0-1][0-9]:[0-3][0-9]/)
        iso8601 = sprintf('%sT00:00:00Z', date.gsub(':', '-'))
      # AD
      elsif date.match(/[0-9]{4}-[0-1][0-9]-[0-3][0-9]/)
        iso8601 = sprintf('%sT00:00:00Z', date)
      # AU
      elsif date.match(/[0-9]{4} \[/)
        iso8601 = sprintf('%s-01-01T00:00:00Z', date.split(' ')[0])
      # AV
      elsif date.match(/^[0-9]{4},/)
        iso8601 = sprintf('%s-01-01T00:00:00Z', date.gsub(',', '').split(' ')[0])
      # AE, AF, AG, AH, AI, AJ
      elsif date.match(/^[\[]{0,2}[0-9]{4}\??[\]]{0,2}$/)
        iso8601 = sprintf('%s-01-01T00:00:00Z', date.gsub(/[^0-9]/, ''))
      # AK
      elsif date.match(/^[0-9]{4}, ?c[0-9]{4}/)
        parts = date.split(',')
        iso8601 = sprintf('%s-01-01T00:00:00Z', parts[0])
      # AL, AM, AN, AW, AX, AZ, NH
      elsif date.match(/^[\[]{0,2}[c©][0-9]{4}[\]]{0,2}/)
        iso8601 = sprintf('%s-01-01T00:00:00Z', date.gsub(/[^0-9]/, ' ').split(' ')[0])
      # AO, AP
      elsif date.gsub(',', '').downcase.match(/^(#{MONTHS.join('|')}),? [0-9]{4}/)
        parts = date.split(' ')
        month = 1 + MONTHS.index(parts[0].gsub(/[^A-Za-z]/, '').downcase)
        iso8601 = sprintf('%s-%d-01T00:00:00Z', parts[1], month)
      # AQ
      elsif date.match(/[0-9]{4} or [0-9]{4}/)
        parts = date.split(' ')
        iso8601 = sprintf('%s-01-01T00:00:00Z', parts[0])
      # AR
      elsif date.match(/^[0-9]{2}-[0-9]{4}/)
        parts = date.split('-')
        iso8601 = sprintf('%s-%s-01T00:00:00Z', parts[1], parts[0])
      # AS
      elsif date.match(/^[0-9]{2}-[0-9]{2}-[0-9]{4}/)
        parts = date.split('-')
        iso8601 = sprintf('%s-%s-%sT00:00:00Z', parts[2], parts[0], parts[1])
      # AT
      elsif date.gsub(',', '').downcase.match(/^[0-9]{1,2} (#{MONTHS.join('|')}) [0-9]{4}/)
        parts = date.split(' ')
        month = 1 + MONTHS.index(parts[1].gsub(/[^A-Za-z]/, '').downcase)
        iso8601 = sprintf('%s-%d-%dT00:00:00Z', parts[2], month, parts[0])
      # BA
      elsif date.match(/\[\w+. [0-9]{4}\]/)
        year = date.gsub(/[^0-9]/, '')[0..3]
        iso8601 = sprintf('%s-01-01T00:00:00Z', year)
      # NF
      elsif date.match(/\[between [0-9]{4} and [0-9]{4}\]/)
        year = date.gsub(/[^0-9]/, '')[0..3]
        iso8601 = sprintf('%s-01-01T00:00:00Z', year)
      # NG
      elsif date.match(/\[[0-9]{4}\]-</)
        year = date.gsub(/[^0-9]/, '')[0..3]
        iso8601 = sprintf('%s-01-01T00:00:00Z', year)
      # NK, NL
      elsif date.match(/[0-9]{4}\/[0-9]{2,4}-/)
        iso8601 = sprintf('%s-01-01T00:00:00Z', date.split('/')[0])
      # NA, NB, NC, ND
      elsif date.match(/[0-9]{2,3}-/)
        parts = date.split('-')
        year = parts[0].gsub(/[^0-9]/, '').ljust(4, '0')
        iso8601 = sprintf('%s-01-01T00:00:00Z', year)
      end

      # It's possible that an unsupported date format has slipped through.
      # These often result in dates with 5+ digit years. Rather than making
      # all of our regexes a lot more complicated to deal with those, we will
      # add a special check to disqualify them.
      iso8601 = nil if iso8601&.match(/^[0-9]{5,99}-/)

      if iso8601
        return Time.parse(iso8601)
      else
        raise ArgumentError, "Unrecognized date format: #{date}"
      end
    end
    nil
  end

  private

  def self.log_strategy(date, strategy)
    Rails.logger.debug("Parsing #{date} using #{strategy} strategy")
  end

end
