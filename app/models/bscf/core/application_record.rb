module Bscf
  module Core
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
