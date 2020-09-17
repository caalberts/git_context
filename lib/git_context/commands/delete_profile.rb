# frozen_string_literal: true

module GitContext
  module Commands
    class DeleteProfile < Base
      def call
        stored_profiles = @configuration.list_profile_names
        to_be_deleted = @interaction.prompt_delete_profile(stored_profiles)
        @configuration.delete_profile(to_be_deleted)
      end
    end
  end
end
