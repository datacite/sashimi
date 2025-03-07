# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
json_mime_type_synonyms = %w[
  text/x-json
  application/jsonrequest
  gzip
  application/gzip
]
Mime::Type.register('application/json', :json, json_mime_type_synonyms)