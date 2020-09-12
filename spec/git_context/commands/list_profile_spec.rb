# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitContext::Commands::ListProfile do
  let(:configuration) { instance_double(GitContext::Configuration) }
  let(:interaction) { instance_double(GitContext::Interaction) }
  let(:profiles) { %w[personal work] }

  subject { described_class.new(configuration: configuration, interaction: interaction) }

  before do
    allow(configuration).to receive(:list_profile_names).and_return(profiles)
    allow(interaction).to receive(:show)
  end

  describe '#call' do
    it 'retrieves stored profiles' do
      expect(configuration).to receive(:list_profile_names)

      subject.call
    end

    it 'displays list of profiles' do
      expect(interaction).to receive(:show).with("personal\nwork")

      subject.call
    end
  end
end
