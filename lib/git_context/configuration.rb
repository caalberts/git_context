# frozen_string_literal: true

require 'fileutils'

module GitContext
  class ConfigData
    attr_reader :home, :profiles, :contexts

    def initialize(home)
      @home = home
      @profiles = []
      @contexts = []
    end

    def serialize
      {
        'profiles' => profiles.map(&:serialize),
        'contexts' => contexts.map(&:serialize)
      }
    end
  end

  class Configuration
    attr_reader :home, :config_data, :yaml, :git, :storages

    def initialize(home)
      @home = home
      @config_data = ConfigData.new(@home)
      @yaml = Storage::YML.new(@config_data)
      @git = Storage::Git.new(@config_data)

      @yaml.load
      @storages = [@yaml, @git]
    end

    def setup
      create_base_dir
      setup_storage
    end

    def add_profile(profile)
      config_data.profiles << profile
      save_into_storage
    end

    def delete_profile(profile_name)
      config_data.profiles.delete_if { |profile| profile.profile_name == profile_name }
      save_into_storage
    end

    def list_profile_names
      config_data.profiles.map(&:profile_name).sort
    end

    def add_context(context)
      config_data.contexts << context
      save_into_storage
    end

    private

    def setup_storage
      storages.each(&:setup)
    end

    def save_into_storage
      storages.each(&:save)
    end

    def create_base_dir
      FileUtils.mkdir(git_context_dir) unless FileTest.exists?(git_context_dir)
    end

    def git_context_dir
      File.join(home, BASE_STORAGE_DIR)
    end
  end
end
