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
      # TODO implement edit and update in the future
      # resource :registration, only: [:new, :create, :edit, :update] do
      route <<~ROUTE
        resource :registration, only: [:new, :create] do
          get :confirm, on: :collection
        end
      ROUTE
    end

    def generate_mailer
      copy_file "confirmation_mailer.rb", "app/mailers/confirmation_mailer.rb"
      directory "views/confirmation_mailer", "app/views/confirmation_mailer"
    end

    def inject_user_extension
      user_model_path = "app/models/user.rb"
      return unless File.exist?(user_model_path)

      inject_into_file user_model_path, after: "class User < ApplicationRecord\n" do
        "  include ActiveRegistration::UserExtensions\n"
      end
    rescue Errno::ENOENT
      say "User model not found. Add 'include ActiveRegistration::UserExtensions' to your User model.", :yellow
    end
  end
end
