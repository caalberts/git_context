# frozen_string_literal: true

require 'fileutils'

module GitContext
  module Storage
    class Git
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def setup
        create_contexts_file
        create_profiles_dir

        include(global_gitconfig_path, contexts_filepath)
      end

      def reset
        FileUtils.rm(contexts_filepath)
        FileUtils.rm_r(profiles_dir)

        create_contexts_file
        create_profiles_dir
      end

      def save
        reset
        save_profiles
        save_contexts
      end

      private

      def save_contexts
        config.contexts.each do |context|
          profile_file = profile_filepath(context.profile_name)

          add_context(contexts_filepath, context.work_dir, profile_file)
        end
      end

      def save_profiles
        config.profiles.each do |profile|
          profile_file = profile_filepath(profile.profile_name)
          touch_file(profile_file)

          add_profile(profile_file, profile)
        end
      end

      def include(gitconfig_path, contexts_filepath)
        return if included?(gitconfig_path, contexts_filepath)

        `git config -f "#{gitconfig_path}" --add "include.path" "#{contexts_filepath}"`
      end

      def add_profile(profile_file, profile)
        `git config -f "#{profile_file}" --add user.name "#{profile.user.name}"`
        `git config -f "#{profile_file}" --add user.email "#{profile.user.email}"`
        `git config -f "#{profile_file}" --add user.signingKey "#{profile.user.signing_key}"`
      end

      def add_context(contexts_file, dir, profile_file)
        `git config -f "#{contexts_file}" --add "includeIf.gitdir:#{dir}/.path" "#{profile_file}"`
      end

      def included?(gitconfig_path, contexts_filepath)
        include_path = `git config -f "#{gitconfig_path}" include.path`
        include_path.include?(contexts_filepath)
      end

      def home
        config.home
      end

      def create_contexts_file
        touch_file(contexts_filepath)
      end

      def create_profiles_dir
        create_dir(profiles_dir)
      end

      def global_gitconfig_path
        File.join(home, GITCONFIG_FILE)
      end

      def contexts_filepath
        File.join(git_context_dir, CONTEXTS_FILE)
      end

      def git_context_dir
        File.join(home, BASE_STORAGE_DIR)
      end

      def profiles_dir
        File.join(git_context_dir, PROFILES_DIR)
      end

      def profile_filepath(profile_name)
        File.join(profiles_dir, profile_name)
      end

      def touch_file(config_file_path)
        FileUtils.touch(config_file_path)
      end

      def create_dir(dir)
        FileUtils.mkdir(dir) unless FileTest.exist?(dir)
      end
    end
  end
end
