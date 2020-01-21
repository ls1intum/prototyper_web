class Container < ApplicationRecord
  belongs_to :release

  validates :marvel_url,  presence: true
end
