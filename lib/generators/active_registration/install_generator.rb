module ActiveRegistration
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root File.expand_path("templates", __dir__)

    def self.next_migration_number(dirname)
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end

    def copy_migration
      migration_template "add_active_registration_fields_to_users.rb", "db/migrate/add_active_registration_fields_to_users.rb"
    end

    def generate_controller
      copy_file "registrations_controller.rb", "app/controllers/registrations_controller.rb"
    end

    def generate_views
      directory "views/registrations", "app/views/registrations"
    end

    def add_routes
      route <<~ROUTE
        resource :registration, only: [ :new, :create ] do
          get :confirm, on: :collection
        end
      ROUTE
    end

    def generate_mailer
      copy_file "confirmation_mailer.rb", "app/mailers/confirmation_mailer.rb"
      directory "views/confirmation_mailer", "app/views/confirmation_mailer"
    end

    def inject_user_methods
      user_model_path = "app/models/user.rb"
      return unless File.exist?(user_model_path)

      inject_validations_and_hooks(user_model_path)
      inject_public_methods(user_model_path)
      inject_private_methods(user_model_path)
    rescue Errno::ENOENT
      say "User model not found. Please add the registration methods to your User model manually.", :yellow
    end

    private

    def inject_validations_and_hooks(user_model_path)
      content = File.read(user_model_path)

      if content.match(/^\s*(validates|before_|after_|around_)/)
        last_validation_line = content.lines.each_with_index.reverse_each.find do |line, _|
          line.match(/^\s*(validates|before_|after_|around_)/)
        end

        if last_validation_line
          inject_into_file user_model_path, after: last_validation_line[0] do
            <<~RUBY
              validates :email_address, presence: true, uniqueness: true
              before_create :generate_confirmation_token
            RUBY
          end
          return
        end
      end

      inject_into_file user_model_path, after: "class User < ApplicationRecord\n" do
        <<~RUBY
          validates :email_address, presence: true, uniqueness: true
          before_create :generate_confirmation_token

        RUBY
      end
    end

    def inject_public_methods(user_model_path)
      content = File.read(user_model_path)
      lines = content.lines
      private_line_index = lines.find_index { |line| line.strip == "private" }

      last_public_method_index = nil
      lines.each_with_index do |line, index|
        if line.match(/^\s*def /) && (private_line_index.nil? || index < private_line_index)
          last_public_method_index = index
        end
      end

      if last_public_method_index
        method_end_index = last_public_method_index
        lines[(last_public_method_index + 1)..-1].each_with_index do |line, rel_index|
          if line.match(/^\s*end\s*$/)
            method_end_index = last_public_method_index + 1 + rel_index
            break
          end
        end

        inject_into_file user_model_path, after: lines[method_end_index] do
          <<~RUBY

            def confirm!
              update(confirmed_at: Time.current, confirmation_token: nil)
            end

            def confirmed?
              confirmed_at.present?
            end

            def confirmation_period_valid?
              confirmation_sent_at >= 24.hours.ago
            end
          RUBY
        end
      elsif private_line_index
        inject_into_file user_model_path, before: lines[private_line_index] do
          <<~RUBY
            def confirm!
              update(confirmed_at: Time.current, confirmation_token: nil)
            end

            def confirmed?
              confirmed_at.present?
            end

            def confirmation_period_valid?
              confirmation_sent_at >= 24.hours.ago
            end
          RUBY
        end
      else
        inject_into_file user_model_path, before: /^end\s*$/ do
          <<~RUBY
            def confirm!
              update(confirmed_at: Time.current, confirmation_token: nil)
            end

            def confirmed?
              confirmed_at.present?
            end

            def confirmation_period_valid?
              confirmation_sent_at >= 24.hours.ago
            end
          RUBY
        end
      end
    end

    def inject_private_methods(user_model_path)
      content = File.read(user_model_path)

      if content.include?("private")
        lines = content.lines
        private_line_index = lines.find_index { |line| line.strip == "private" }

        last_private_method_index = nil
        lines[(private_line_index + 1)..-1].each_with_index do |line, rel_index|
          if line.match(/^\s*def /)
            last_private_method_index = private_line_index + 1 + rel_index
          end
        end

        if last_private_method_index
          # Find the end of the last private method
          method_end_index = last_private_method_index
          lines[(last_private_method_index + 1)..-1].each_with_index do |line, rel_index|
            if line.match(/^\s*end\s*$/)
              method_end_index = last_private_method_index + 1 + rel_index
              break
            end
          end

          inject_into_file user_model_path, after: lines[method_end_index] do
            <<~RUBY

              def generate_confirmation_token
                self.confirmation_token = SecureRandom.urlsafe_base64
                self.confirmation_sent_at = Time.current
              end
            RUBY
          end
        else
          inject_into_file user_model_path, after: /^\s*private\s*$/ do
            <<~RUBY

              def generate_confirmation_token
                self.confirmation_token = SecureRandom.urlsafe_base64
                self.confirmation_sent_at = Time.current
              end
            RUBY
          end
        end
      else
        inject_into_file user_model_path, before: /^end\s*$/ do
          <<~RUBY
            private

            def generate_confirmation_token
              self.confirmation_token = SecureRandom.urlsafe_base64
              self.confirmation_sent_at = Time.current
            end
          RUBY
        end
      end
    end
  end
end
