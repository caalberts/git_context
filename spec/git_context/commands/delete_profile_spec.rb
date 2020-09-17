# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitContext::Commands::DeleteProfile do
  let(:configuration) { instance_double(GitContext::Configuration) }
  let(:interaction) { instance_double(GitContext::Interaction) }
  let(:profiles) { %w[personal work] }
  let(:profile_to_delete) { 'work' }

  subject { described_class.new(configuration: configuration, interaction: interaction) }

  before do
    allow(configuration).to receive(:list_profile_names).and_return(profiles)
    allow(interaction).to receive(:prompt_delete_profile).and_return(profile_to_delete)
    allow(configuration).to receive(:delete_profile)
  end

  describe '#call' do
    it 'retrieves stored profiles' do
      expect(configuration).to receive(:list_profile_names)

      subject.call
    end

    it 'prompts user for profile to be deleted' do
      expect(interaction).to receive(:prompt_delete_profile).with(profiles)

      subject.call
    end

    it 'deletes profile from configuration' do
      expect(configuration).to receive(:delete_profile).with(profile_to_delete)

      subject.call
    end
  end
end
