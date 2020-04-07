class Group < ApplicationRecord
  belongs_to :app
  has_many :group_users
  has_many :users, through: :group_users

  belongs_to :main_release, class_name: 'Release', optional: true
  belongs_to :second_release, class_name: 'Release', optional: true

  validates :name,  presence: true, length: { maximum: 100 }
  validates :app_id,  presence: true

  def remove_user(user)
    group_users.reject! do |group_user|
      group_user.user_id == user.id
    end
  end
end
