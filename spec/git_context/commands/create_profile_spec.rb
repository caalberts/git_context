# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitContext::Commands::CreateProfile do
  let(:configuration) { instance_double(GitContext::Configuration) }
  let(:interaction) { instance_double(GitContext::Interaction) }
  let(:profile_name) { 'my-work-profile' }
  let(:user) { GitContext::User.new(name: 'john', email: 'john@email.com') }

  subject { described_class.new(configuration: configuration, interaction: interaction) }

  before do
    allow(interaction).to receive(:prompt_profile_name).and_return(profile_name)
    allow(interaction).to receive(:prompt_user_name).and_return(user.name)
    allow(interaction).to receive(:prompt_user_email).and_return(user.email)
    allow(interaction).to receive(:info)
    allow(configuration).to receive(:add_profile)
  end

  describe '#call' do
    it 'asks user for user name and email' do
      expect(interaction).to receive(:prompt_profile_name)
      expect(interaction).to receive(:prompt_user_name)
      expect(interaction).to receive(:prompt_user_email)

      subject.call
    end

    it 'adds profile with given user and email to configuration' do
      expected_profile = GitContext::Profile.new(profile_name, user)
      expect(configuration).to receive(:add_profile).with(expected_profile)

      subject.call
    end

    it 'informs user when profile is created' do
      expect(interaction).to receive(:info).with(/Profile #{profile_name} created/)

      subject.call
    end
  end
end
