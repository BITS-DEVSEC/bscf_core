module Bscf
  module Core
    class BusinessDocument < ApplicationRecord
      belongs_to :user
      has_one_attached :file

      before_validation :format_document_name

      validates :document_number, presence: true
      validates :document_name, presence: true
      validates :verified_at, presence: true, if: :is_verified?
      validates :file, presence: true
      validate :block_executable_files

      scope :verified, -> { where(is_verified: true) }
      scope :unverified, -> { where(is_verified: false) }

      enum :document_type, { business_license: 0, delegation_letter: 1, drivers_license: 2, libre: 3}

      private

      def format_document_name
        self.document_name = document_name.strip.titleize if document_name.present?
      end

      def block_executable_files
        return unless file.attached?

        if file.content_type.in?(%w[
          application/x-msdownload
          application/x-executable
          application/x-msdos-program
          application/x-ms-dos-executable
          application/x-shellscript
        ])
          errors.add(:file, "cannot be an executable file")
        end
      end
    end
  end
end
