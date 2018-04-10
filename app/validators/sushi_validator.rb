class SushiValidator < ActiveModel::EachValidator

  def validate_each(record, schema, value)
    unless  record.is_valid_sushi? 
      record.errors["sushi_format"] << (record.validate_sushi || "Your SUSHI is wrong mate!!")
    end
  end
end
