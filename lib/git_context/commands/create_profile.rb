# frozen_string_literal: true
module GitContext
  module Commands
    class CreateProfile < Base
      def call
        profile_name = @interaction.prompt_profile_name
        user = @interaction.prompt_user_info

        profile = Profile.new(profile_name, user)
        @configuration.add_profile(profile)
      end
    end
  end
end

