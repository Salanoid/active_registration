class HomeController < ApplicationController
  # Safe call to allow_unauthenticated_access, handling eager loading scenarios
  begin
    allow_unauthenticated_access
  rescue NameError
    # Authentication concern not yet loaded - skip for now
  end

  def index
    # Simple home page for testing
  end
end
