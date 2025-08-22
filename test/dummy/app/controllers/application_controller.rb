class ApplicationController < ActionController::Base
  # Safely include Authentication concern, handling eager loading scenarios
  def self.include_authentication_when_available
    return if @authentication_included
    begin
      include Authentication
      @authentication_included = true
    rescue NameError
      # Authentication concern not yet loaded - will retry later
    end
  end

  # Try to include Authentication immediately
  include_authentication_when_available

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end

# Ensure Authentication is included after all files are loaded
Rails.application.config.to_prepare do
  ApplicationController.include_authentication_when_available
end
