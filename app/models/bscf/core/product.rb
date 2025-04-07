module Bscf
  module Core
    class Product < ApplicationRecord
      belongs_to :category
      has_one_attached :thumbnail
      has_many_attached :images

      validates :sku, presence: true, uniqueness: true
      validates :name, presence: true
      validates :description, presence: true
      has_many :rfq_items
      has_many :request_for_quotations, through: :rfq_items

      before_validation :generate_sku, on: :create

      validates :sku, presence: true, uniqueness: true
      validates :name, presence: true
      validates :description, presence: true
      validates :base_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

      private

      def generate_sku
        return if sku.present?

        prefix = "BSC"
        category_code = category.id.to_s.rjust(3, "0")
        sequence = (Product.where("sku LIKE ?", "#{prefix}#{category_code}%").count + 1).to_s.rjust(4, "0")

        self.sku = "#{prefix}#{category_code}#{sequence}"
      end
    end
  end
end
