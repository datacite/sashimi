module Sashimi
  class Application
    VERSION = ENV.fetch("GIT_TAG", "1.0")
  end
end