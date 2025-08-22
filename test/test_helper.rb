# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "fileutils"
require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [ File.expand_path("../test/dummy/db/migrate", __dir__) ]
require "rails/test_help"

if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [ File.expand_path("fixtures", __dir__) ]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = File.expand_path("fixtures", __dir__) + "/files"
  ActiveSupport::TestCase.fixtures :all
end

require "rails/generators/test_case"

module TestFileManager
  def self.dummy_path
    File.expand_path("../test/dummy", __dir__)
  end

  def self.cleanup_generated_files
    cleanup_rails_auth_files
    cleanup_active_registration_files
    cleanup_database_files
    cleanup_log_files
  end

  def self.regenerate_files
    Dir.chdir(dummy_path) do
      unless system("rails generate authentication --force --quiet")
        puts "Warning: Rails authentication generator failed"
      end

      sleep(1)

      unless system("rails generate active_registration:install --force --quiet")
        puts "Warning: Active registration generator failed"
      end

      sleep(1)

      unless system("rails db:migrate RAILS_ENV=test")
        puts "Warning: Database migration failed"
      end
    end
  rescue => e
    puts "Error during file regeneration: #{e.message}"
    raise e
  end

  private

  def self.cleanup_rails_auth_files
    files_to_remove = [
      "app/controllers/sessions_controller.rb",
      "app/controllers/passwords_controller.rb",
      "app/controllers/concerns/authentication.rb",
      "app/models/user.rb",
      "app/models/session.rb",
      "app/models/current.rb",
      "app/views/sessions",
      "app/views/passwords",
      "app/views/passwords_mailer",
      "app/mailers/passwords_mailer.rb",
      "test/models/user_test.rb",
      "test/mailers/previews/passwords_mailer_preview.rb"
    ]

    files_to_remove.each do |file_path|
      full_path = File.join(dummy_path, file_path)
      FileUtils.rm_rf(full_path) if File.exist?(full_path)
    end

    migrate_dir = File.join(dummy_path, "db/migrate")
    if File.directory?(migrate_dir)
      Dir.glob(File.join(migrate_dir, "*.rb")).each { |f| File.delete(f) }
    end
  end

  def self.cleanup_active_registration_files
    files_to_remove = [
      "app/controllers/registrations_controller.rb",
      "app/mailers/confirmation_mailer.rb",
      "app/views/registrations",
      "app/views/confirmation_mailer"
    ]

    files_to_remove.each do |file_path|
      full_path = File.join(dummy_path, file_path)
      FileUtils.rm_rf(full_path) if File.exist?(full_path)
    end

    Dir.glob(File.join(dummy_path, "db/migrate/*add_active_registration_fields_to_users.rb")).each { |f| File.delete(f) }
  end

  def self.cleanup_database_files
    db_files = [
      "db/schema.rb",
      "storage/test.sqlite3",
      "storage/test.sqlite3-wal",
      "storage/test.sqlite3-shm"
    ]

    db_files.each do |file_path|
      full_path = File.join(dummy_path, file_path)
      File.delete(full_path) if File.exist?(full_path)
    end
  end

  def self.cleanup_log_files
    log_files = [
      "log/development.log",
      "log/test.log",
      "log/production.log"
    ]

    log_files.each do |file_path|
      full_path = File.join(dummy_path, file_path)
      File.delete(full_path) if File.exist?(full_path)
    end
  end

  def self.reset_routes_file
    routes_path = File.join(dummy_path, "config/routes.rb")

    routes_content = <<~ROUTES
      Rails.application.routes.draw do
        # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

        # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
        # Can be used by load balancers and uptime monitors to verify that the app is live.
        get "up" => "rails/health#show", as: :rails_health_check

        # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
        # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
        # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

        # Defines the root path route ("/")
        root "home#index"
      end
    ROUTES

    File.write(routes_path, routes_content)
  end
end

TestFileManager.cleanup_generated_files
TestFileManager.regenerate_files

Rails.application.reload_routes!
Rails.application.reloader.reload!

begin
  User
rescue NameError
  require_relative "dummy/app/models/user"
end

module TestCleanup
  def teardown
    super
    TestFileManager.cleanup_log_files
  end
end

ActionDispatch::IntegrationTest.include(TestCleanup)
ActiveSupport::TestCase.include(TestCleanup)
