# frozen_string_literal: true

module GitContext
  module Commands
    class ListProfile < Base
      def call
        stored_profiles = @configuration.list_profile_names

        @interaction.show(stored_profiles.join("\n"))
      end
    end
  end
end
