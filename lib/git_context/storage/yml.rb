# frozen_string_literal: true

require 'yaml'

module GitContext
  module Storage
    class YML
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def setup
        return if FileTest.exist?(config_filepath)

        FileUtils.touch(config_filepath)
      end

      def load
        return unless config_filepath && FileTest.exist?(config_filepath)

        load_profiles_from_file
        load_contexts_from_file
      end

      def save
        File.open(config_filepath, 'w') do |file|
          file.write(YAML.dump(serialized_data))
        end
      end

      private

      def load_profiles_from_file
        content['profiles']&.each do |profile|
          user = User.new(profile['name'], profile['email'], profile['signing_key'])
          config.profiles << Profile.new(profile['profile_name'], user)
        end
      end

      def load_contexts_from_file
        content['contexts']&.each do |context|
          config.contexts << Context.new(context['work_dir'], context['profile_name'])
        end
      end

      def content
        @content ||= YAML.load_file(config_filepath) || {}
      end

      def serialized_data
        config.serialize
      end

      def config_filepath
        File.join(git_context_dir, CONFIG_FILE)
      end

      def git_context_dir
        File.join(config.home, BASE_STORAGE_DIR)
      end
    end
  end
end
