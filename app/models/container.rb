class Container < ActiveRecord::Base
  belongs_to :release

  validates :marvel_url,  presence: true
end
