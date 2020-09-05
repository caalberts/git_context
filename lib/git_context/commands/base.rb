# frozen_string_literal: true

module GitContext
  module Commands
    class Base
      def initialize(configuration:, interaction:)
        @configuration = configuration
        @interaction = interaction
      end

      def call
        raise NotImplementedError
      end
    end
  end
end
