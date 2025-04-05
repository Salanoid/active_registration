module ActiveRegistration
  module UserExtensions
    extend ActiveSupport::Concern

    included do
      validates :email_address, presence: true, uniqueness: true
      before_create :generate_confirmation_token
    end

    def confirm!
      update(confirmed_at: Time.current, confirmation_token: nil)
    end

    def confirmed?
      confirmed_at.present?
    end

    def confirmation_period_valid?
      confirmation_sent_at >= 24.hours.ago
    end

    private

    def generate_confirmation_token
      self.confirmation_token = SecureRandom.urlsafe_base64
      self.confirmation_sent_at = Time.current
    end
  end
end
