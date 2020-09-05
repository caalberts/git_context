# frozen_string_literal: true
require 'spec_helper'

RSpec.describe GitContext::Commands::CreateProfile do
  let(:configuration) { instance_double(GitContext::Configuration) }
  let(:interaction) { double('Interaction') }
  let(:profile_name) { 'my-work-profile' }
  let(:user) { GitContext::User.new(name: 'john', email: 'john@email.com') }

  subject { described_class.new(configuration: configuration, interaction: interaction) }

  before do
    allow(interaction).to receive(:prompt_profile_name).and_return(profile_name)
    allow(interaction).to receive(:prompt_user_info).and_return(user)
    allow(configuration).to receive(:add_profile)
  end

  describe '#call' do
    it 'asks user for user name and email' do
      expect(interaction).to receive(:prompt_profile_name)
      expect(interaction).to receive(:prompt_user_info)

      subject.call
    end

    it 'adds profile with given user and email to configuration' do
      expected_profile = GitContext::Profile.new(profile_name, user)
      expect(configuration).to receive(:add_profile).with(expected_profile)

      subject.call
    end
  end
end
