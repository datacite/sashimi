class SushiValidator < ActiveModel::EachValidator

  def validate_each(record, _schema, _value)
    # unless  record.is_valid_sushi? 
    valid = record.validate_sushi
    unless  valid == true

      def dig_errors(errors)
        return [] if errors.nil?
      
        if errors.is_a? Hash
          [ errors.dig(:message) ]
        else
          errors.map { |error| {error.dig(:fragment) => error.dig(:message)}  }
        end
      end
      # nice_erros = dig_errors record.validate_sushi
      nice_erros = dig_errors valid

      record.errors["errors"] << (nice_erros || "Your SUSHI is wrong mate!!")
    end
  end
end
