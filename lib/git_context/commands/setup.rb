# frozen_string_literal: true

module GitContext
  module Commands
    class Setup < Base
      def call
        @configuration.setup
        @interaction.info("git_context has been set up in #{@configuration.home}")
      end
    end
  end
end
