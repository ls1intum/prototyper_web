class Build < ActiveRecord::Base
  belongs_to :release

  validates :ipa,  presence: true
  validates :bundle_id,  presence: true

  mount_uploader :ipa, IpaUploader
end
