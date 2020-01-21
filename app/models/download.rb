class Download < ApplicationRecord
  belongs_to :release
  belongs_to :user

  validates :release_id,  presence: true
  validates :user_id,  presence: true
end
