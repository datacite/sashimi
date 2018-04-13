ActiveModelSerializers.config.adapter = ActiveModelSerializers::Adapter::Json
ActiveModelSerializers.config.include_data_default = :if_sideloaded

# disable pagination links as it requires expensive count queries on the database
ActiveModelSerializers.config.jsonapi_pagination_links_enabled = false

ActiveModel::Serializer.config.key_transform = :dash
ActiveModel::Serializer.config.default_includes = "**"

ActiveSupport.on_load(:action_controller) do
  require 'active_model_serializers/register_jsonapi_renderer'
end
