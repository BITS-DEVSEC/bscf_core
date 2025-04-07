require 'rails_helper'

module Bscf
  module Core
    RSpec.describe BusinessDocument, type: :model do
      attributes = [
        { document_number: :presence },
        { document_name: :presence },
        { business: :belong_to },
        { file: :presence }
      ]

      include_examples("model_shared_spec", :business_document, attributes)

      describe 'document name formatting' do
        let(:document) { build(:business_document, document_name: ' test document  ') }

        it 'formats document name before validation' do
          document.valid?
          expect(document.document_name).to eq('Test Document')
        end
      end

      describe 'verified status' do
        let(:business) { create(:business) }
        let(:document) {
          build(:business_document,
            business: business,
            is_verified: true,
            file: Rack::Test::UploadedFile.new(
              StringIO.new('test content'),
              'application/pdf',
              original_filename: 'test.pdf'
            )
          )
        }

        it 'requires verified_at when is_verified is true' do
          expect(document).not_to be_valid
          expect(document.errors[:verified_at]).to include("can't be blank")
        end

        it 'is valid with verified_at when is_verified is true' do
          document.verified_at = Time.current
          expect(document).to be_valid
        end
      end
    end
  end
end
