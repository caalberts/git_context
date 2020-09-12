# frozen_string_literal: true

module GitContext
  module Commands
    class CreateProfile < Base
      def call
        profile_name = @interaction.prompt_profile_name
        input = @interaction.prompt_user_info

        user = User.new(input[:name], input[:email], input[:signing_key])
        profile = Profile.new(profile_name, user)
        @configuration.add_profile(profile)

        @interaction.info("Profile #{profile_name} created.")
      end
    end
  end
end
