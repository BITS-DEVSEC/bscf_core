require 'rails_helper'

module Bscf
  module Core
    RSpec.describe Category, type: :model do
      attributes = [
        { name: [ :presence ] },
        { description: [ :presence ] }
      ]

      include_examples("model_shared_spec", :category, attributes)

      describe 'associations' do
        let(:parent_category) { create(:category) }
        let(:child_category) { create(:category, parent: parent_category) }

        it 'can have a parent category' do
          expect(child_category.parent).to eq(parent_category)
        end

        it 'can have child categories' do
          child_category
          expect(parent_category.children).to include(child_category)
        end

        it 'allows parent to be optional' do
          category = create(:category)
          expect(category.parent).to be_nil
        end
      end

      describe 'hierarchical structure' do
        let(:parent) { create(:category) }
        let!(:children) { create_list(:category, 3, parent: parent) }

        it 'maintains proper parent-child relationships' do
          expect(parent.children.count).to eq(3)
          expect(children.map(&:parent)).to all(eq(parent))
        end
      end
    end
  end
end
