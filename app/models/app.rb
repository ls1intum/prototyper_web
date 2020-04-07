class App < ApplicationRecord
  belongs_to :user
  has_many :groups, dependent: :destroy
  has_many :releases, dependent: :destroy
  has_many :containers, dependent: :destroy
  has_and_belongs_to_many :admins, :class_name=>"User", :join_table => :Apps_Users

  VALID_BUNDLE_ID_REGEX = /\A\w+(?:\.\w+)+\z/i

  validates :name,  presence: true, length: { maximum: 50 }
  validates :bundle_id, presence: true, length: { maximum: 100 },
                    format: { with: VALID_BUNDLE_ID_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :user_id,  presence: true
  validate  :picture_size

  mount_uploader :icon, AppIconUploader

  def branches(user)
    unless (user.bamboo_access_token.nil? || bamboo_project.nil? || bamboo_plan.nil? )
      body = user.bamboo_access_token.get("/rest/api/latest/plan/#{bamboo_project}-#{bamboo_plan}?expand=branches.branch.latestResult", { 'Accept'=>'application/json' }).body
      dict = JSON.parse(body)

      if dict["branches"].nil? || dict["branches"]["branch"].nil?
        return Array.new
      end

      branchesHash = dict["branches"]["branch"]
      branches = branchesHash.map { |p|
        {
          name: p["shortName"], key: p["key"]
        }
      }

      develop = { name: "develop", key: dict["key"] }

      return branches.unshift(develop)
    end
    return Array.new
  end

  private

    # Validates the size of an uploaded picture.
    def picture_size
      if icon.size > 5.megabytes
        errors.add(:icon, "should be less than 5MB")
      end
    end

end
