# frozen_string_literal: true
module GitContext
  class CLI
    COMMAND_CLASSES = {
      setup: 'Setup',
      create_profile: 'CreateProfile',
      create_context: 'CreateContext'
    }.freeze

    def initialize(configuration)
      @configuration = configuration
      @interaction = Interaction.new
    end

    def exec(command_name)
      command_class = command_for(command_name)
      command = command_class.new(interaction: @interaction, configuration: @configuration)
      command.call
    rescue KeyError
      warn "Unknown command #{command_name}. Supported commands are #{COMMAND_CLASSES.keys.map(&:to_s)}"
    end

    private

    def command_for(command)
      klass = COMMAND_CLASSES.fetch(command.to_sym)
      Commands.const_get(klass)
    end
  end
end
