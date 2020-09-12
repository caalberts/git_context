# frozen_string_literal: true

module GitContext
  module Commands
    class CreateProfile < Base
      def call
        profile_name = @interaction.prompt_profile_name
        user_name = @interaction.prompt_user_name
        user_email = @interaction.prompt_user_email
        user_signing_key = @interaction.prompt_user_signing_key

        user = User.new(user_name, user_email, user_signing_key)
        profile = Profile.new(profile_name, user)
        @configuration.add_profile(profile)

        @interaction.info("Profile #{profile_name} created.")
      end
    end
  end
end
