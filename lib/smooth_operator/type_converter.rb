module SmoothOperator

  module TypeConverter

    extend self

    def convert(value, type)
      case type

      when :string, :text, String
        value.to_s
      
      when :int, :integer, Integer, Fixnum
        to_int(value)

      when :date, Date
        to_date(value)

      when :float, Float
        to_float(value)

      when :bool, :boolean
        to_boolean(value)

      when :datetime, :date_time, DateTime
        to_datetime(value)

      else
        Helpers.duplicate(value)
      end
    end

    def to_int(string)
      return string if string.is_a?(Fixnum)

      to_float(string).to_i
    end

    def to_date(string)
      return string if string.is_a?(Date)

      Date.parse(string) rescue nil
    end

    def to_datetime(string)
      return string if string.is_a?(DateTime)

      DateTime.parse(string) rescue nil
    end

    def to_boolean(string)
      value = string.to_s.downcase

      ['1', 'true'].include?(value) ? true : ['0', 'false'].include?(value) ? false : nil
    end

    def to_float(string)
      return string if string.is_a?(Float)

      return 0 if string.nil? || !string.is_a?(String)
      
      value = string.scan(/-*\d+[,.]*\d*/).flatten.map(&:to_f).first

      value.nil? ? 0 : value
    end
  
  end
  
end
