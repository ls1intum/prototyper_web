class DownloadToken < ActiveRecord::Base
  belongs_to :release
  belongs_to :group
  belongs_to :user

  attr_accessor :token
end
