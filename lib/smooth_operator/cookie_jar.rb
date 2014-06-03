module SmoothOperator
  class CookieJar < Hash

    def to_s
      self.map { |key, value| "#{key}=#{value}"}.join("; ")
    end

    def parse(*cookie_strings)
      cookie_strings.each do |cookie_string|
        next unless cookie_string.is_a?(String)

        key, value = cookie_string.split('; ').first.split('=', 2)

        self[key] = value
      end

      self
    end

  end
end
