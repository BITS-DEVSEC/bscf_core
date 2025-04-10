require 'rails_helper'

RSpec.describe Bscf::Core::Vehicle, type: :model do
  describe 'associations' do
    it { should belong_to(:driver).class_name('Bscf::Core::User').optional }
  end

  describe 'validations' do
    subject { build(:vehicle) }

    it { should validate_presence_of(:plate_number) }
    it { should validate_uniqueness_of(:plate_number).case_insensitive }
    it { should validate_presence_of(:vehicle_type) }
    it { should validate_presence_of(:brand) }
    it { should validate_presence_of(:model) }
    it { should validate_presence_of(:year) }
    it { should validate_presence_of(:color) }

    it { should validate_numericality_of(:year).only_integer }
    it { should validate_numericality_of(:year).is_greater_than(1900) }
    it { should validate_numericality_of(:year).is_less_than_or_equal_to(Time.current.year) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:vehicle)).to be_valid
    end
  end
end
