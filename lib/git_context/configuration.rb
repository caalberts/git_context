require 'fileutils'
require 'pathname'

module GitContext
  class Configuration
    BASE_STORAGE_DIR = '.gitcontext'
    PROFILES_DIR = 'profiles'
    CONTEXTS_FILENAME = 'contexts'

    def initialize(home_dir)
      @home_dir = home_dir
    end

    def setup
      create_base_dir unless exists?(git_context_dir)
      create_contexts_file
      create_profiles_dir unless exists?(profiles_dir)
      include_in_gitconfig
    end

    def add_profile(profile)
      profile_file = profile_filepath(profile)
      touch_file(profile_file)

      `git config -f "#{profile_file}" --add user.name "#{profile.user.name}"`
      `git config -f "#{profile_file}" --add user.email "#{profile.user.email}"`
    end

    def list_profile_names
      Dir.entries(profiles_dir) - %w[. ..]
    end

    def delete_profile(profile)
      profile_file = profile_filepath(profile)
      delete_file(profile_file)
    end

    def add_context(context)
      profile_file = profile_filepath(context.profile)

      `git config -f "#{contexts_filepath}" --add "includeIf.gitdir:#{context.work_dir}/.path" "#{profile_file}"`
    end

    private

    def profile_filepath(profile)
      profiles_dir.join(profile.profile_name)
    end

    def create_base_dir
      FileUtils.mkdir(git_context_dir)
    end

    def create_profiles_dir
      FileUtils.mkdir(profiles_dir)
    end

    def profiles_dir
      git_context_dir.join(PROFILES_DIR)
    end

    def create_contexts_file
      touch_file(contexts_filepath)
    end

    def contexts_filepath
      git_context_dir.join(CONTEXTS_FILENAME)
    end

    def git_context_dir
      home.join(BASE_STORAGE_DIR)
    end

    def global_gitconfig_path
      home.join('.gitconfig')
    end

    def include_in_gitconfig
      return if include_path_exists?

      `git config -f "#{global_gitconfig_path}" --add "include.path" "#{contexts_filepath}"`
    end

    def include_path_exists?
      include_path = `git config -f "#{global_gitconfig_path}" include.path`
      include_path.include?(contexts_filepath.to_s)
    end

    def home
      Pathname.new(@home_dir)
    end

    def touch_file(config_file_path)
      FileUtils.touch(config_file_path)
    end

    def delete_file(config_file_path)
      FileUtils.rm(config_file_path)
    end

    def exists?(dir_or_file)
      FileTest.exists?(dir_or_file)
    end
  end
end
