# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end
end

RSpec.describe User, type: :model do
  describe '#fullname' do
    it 'returns the full name of the user' do
      user = described_class.new(first_name: 'John', last_name: 'Doe')
      expect(user.fullname).to eq('John Doe')
    end
  end
end

RSpec.describe User, type: :model do
  describe 'Devise modules' do
    it 'authenticates a user with valid credentials' do
      described_class.create!(
        email: 'test@example.com',
        password: 'password',
        first_name: 'John',
        last_name: 'Doe'
      )
      authenticated_user = described_class.find_for_authentication(email: 'test@example.com')
      expect(authenticated_user.valid_password?('password')).to be_truthy
    end

    it 'does not authenticate a user with invalid credentials' do
      described_class.create!(
        email: 'test@example.com',
        password: 'password',
        first_name: 'John',
        last_name: 'Doe'
      )
      authenticated_user = described_class.find_for_authentication(email: 'test@example.com')
      expect(authenticated_user.valid_password?('wrong_password')).to be_falsey
    end
  end
end
