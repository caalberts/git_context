# frozen_string_literal: true
module GitContext
  module Commands
    class Setup < Base
      def call
        @configuration.setup
      end
    end
  end
end
