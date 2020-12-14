# Temporary - spoof detection is working inconsistently, so we are disabling this temporarily.
require 'paperclip/media_type_spoof_detector'
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end
