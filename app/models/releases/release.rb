class Release < ApplicationRecord
  belongs_to :app
  has_many :builds, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_many :downloads, dependent: :destroy
  has_many :releaseLogs
  has_many :groups

  validates :type,  presence: true
  validates :version,  presence: true, length: { maximum: 30 }
  validates :description, length: { maximum: 2000 }

  def title
    "#{type} #{version}"
  end

end
