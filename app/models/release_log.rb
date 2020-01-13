class ReleaseLog < ActiveRecord::Base
  belongs_to :release
  belongs_to :group

  validates :group_id,  presence: true
end
