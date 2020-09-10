# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitContext::Commands::Setup do
  let(:configuration) { instance_double(GitContext::Configuration) }
  let(:interaction) { instance_double(GitContext::Interaction) }

  subject { described_class.new(configuration: configuration, interaction: interaction) }

  describe '#call' do
    before do
      allow(configuration).to receive(:setup)
      allow(interaction).to receive(:info)
    end

    it 'sets up GitContext configuration' do
      expect(configuration).to receive(:setup)

      subject.call
    end

    it 'informs user that git_context has been set up' do
      expect(interaction).to receive(:info).with(/git_context has been set up./)

      subject.call
    end
  end
end
