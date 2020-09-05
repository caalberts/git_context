# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitContext::Commands::Setup do
  let(:configuration) { instance_double(GitContext::Configuration) }
  let(:interaction) { double('Interaction') }

  subject { described_class.new(configuration: configuration, interaction: interaction) }

  describe '#call' do
    it 'sets up GitContext configuration' do
      expect(configuration).to receive(:setup)

      subject.call
    end
  end
end
