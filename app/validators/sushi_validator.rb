class SushiValidator < ActiveModel::EachValidator

  def validate_each(record, _schema, _value)
    valid = record.validate_sushi
    unless valid == true or valid == []

      def dig_errors(errors)
        return [] if errors.nil?

        if errors.is_a? Hash
          [ errors.dig(:message) ]
        else
          errors.map { |error| {error.dig(:fragment) => error.dig(:message)}  }
        end
      end

      nice_errors = dig_errors(valid)
      record.errors["errors"] << (nice_errors || "Your SUSHI is wrong mate!!")
    end
  end
end
