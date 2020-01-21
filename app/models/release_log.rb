class ReleaseLog < ApplicationRecord
  belongs_to :release
  belongs_to :group

  validates :group_id,  presence: true
end
