FactoryBot.define do
  factory :business_document, class: 'Bscf::Core::BusinessDocument' do
    user
    document_number { "DOC-#{SecureRandom.hex(4).upcase}" }
    document_name { "Business License" }
    document_description { "Official business license document" }
    is_verified { false }

    after(:build) do |document|
      document.file.attach(
        io: StringIO.new("test content"),
        filename: 'sample.pdf',
        content_type: 'application/pdf'
      )
    end

    trait :verified do
      is_verified { true }
      verified_at { Time.current }
      association :business, factory: :business
    end
  end
end
