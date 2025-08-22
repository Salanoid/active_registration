require "test_helper"
require "rails/generators"
require_relative "../../lib/generators/active_registration/install_generator.rb"
require "fileutils"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests ActiveRegistration::InstallGenerator
  destination File.expand_path("../../tmp/dummy", __dir__)

  def setup
    super
    @original_dir = Dir.pwd
    prepare_dummy_app
    FileUtils.cd(destination_root)
  end

  def teardown
    FileUtils.cd(@original_dir)
    FileUtils.rm_rf(destination_root)
  end

  test "generates all files" do
    run_generator

    assert_migration "db/migrate/add_active_registration_fields_to_users.rb" do |content|
      assert_includes content, "add_column :users, :confirmation_token"
    end

    assert_file "app/controllers/registrations_controller.rb" do |content|
      assert_includes content, "class RegistrationsController < ApplicationController"
      assert_includes content, "def confirm"
    end

    assert_file "config/routes.rb" do |content|
      assert_match(/resource :registration.*:confirm/m, content)
    end

    assert_file "app/models/user.rb" do |content|
      assert_includes content, "validates :email_address, presence: true, uniqueness: true"
      assert_includes content, "before_create :generate_confirmation_token"
      assert_includes content, "def confirm!"
      assert_includes content, "def confirmed?"
      assert_includes content, "def confirmation_period_valid?"
      assert_includes content, "def generate_confirmation_token"
    end

    rubocop_result = system('bundle exec rubocop "**/*.rb"')
    assert rubocop_result, "RuboCop should pass without issues for generated files"
  end

  private

  def prepare_dummy_app
    FileUtils.mkdir_p(destination_root)
    FileUtils.cp_r(
      File.expand_path("../dummy", __dir__) + "/.",
      destination_root
    )

    user_model_path = File.join(destination_root, "app/models/user.rb")
    unless File.exist?(user_model_path)
      FileUtils.mkdir_p(File.dirname(user_model_path))
      File.write(user_model_path, "class User < ApplicationRecord\nend\n")
    end
  end
end
