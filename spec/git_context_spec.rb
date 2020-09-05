require 'spec_helper'

RSpec.describe GitContext do
  it "has a version number" do
    expect(GitContext::VERSION).not_to be nil
  end
end
