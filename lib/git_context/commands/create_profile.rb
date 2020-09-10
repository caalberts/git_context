# frozen_string_literal: true

module GitContext
  module Commands
    class CreateProfile < Base
      def call
        profile_name = @interaction.prompt_profile_name
        user_name = @interaction.prompt_user_name
        user_email = @interaction.prompt_user_email

        user = User.new(user_name, user_email)
        profile = Profile.new(profile_name, user)
        @configuration.add_profile(profile)

        @interaction.info("Profile #{profile_name} created.")
      end
    end
  end
end
