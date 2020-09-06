# frozen_string_literal: true

module GitContext
  module Commands
    class CreateContext < Base
      def call
        profile_names = @configuration.list_profile_names
        work_dir = @interaction.prompt_work_dir(Dir.pwd)
        profile_name = @interaction.prompt_profile(profile_names)

        context = Context.new(work_dir, profile_name)

        @configuration.add_context(context)
      end
    end
  end
end
