module Bscf
  module Core
    class Category < ApplicationRecord
      validates :name, presence: true
      validates :description, presence: true

      belongs_to :parent, class_name: "Bscf::Core::Category", optional: true
      has_many :children, class_name: "Bscf::Core::Category", foreign_key: "parent_id"
    end
  end
end
