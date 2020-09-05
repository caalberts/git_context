# frozen_string_literal: true
require 'spec_helper'

RSpec.describe GitContext::CLI do
  let(:configuration) { instance_double(GitContext::Configuration) }

  subject { described_class.new(configuration) }

  describe '#exec' do
    context 'with known commands' do
      let(:dummy_command) { instance_double(GitContext::Commands::Base, call: nil) }

      GitContext::CLI::COMMAND_CLASSES.each do |command, konst|
        it 'executes corresponding command' do
          command_class = GitContext::Commands.const_get(konst)
          allow(command_class).to receive(:new).and_return(dummy_command)
          expect(dummy_command).to receive(:call)

          subject.exec(command)
        end
      end
    end

    context 'with unknown command' do
      it 'warns user' do
        expect { subject.exec('foo') }.to output(/Unknown command foo/).to_stderr
      end
    end
  end
end
