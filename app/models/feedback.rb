class Feedback < ActiveRecord::Base
  belongs_to :release
  belongs_to :user

  validates :text, length: { maximum: 2000 }
  validates :release_id,  presence: true
  validates :user_id,  presence: false
  validate  :screenshot_size

  mount_uploader :screenshot, ScreenshotUploader

  private

    # Validates the size of an uploaded picture.
    def screenshot_size
      if screenshot.size > 10.megabytes
        errors.add(:screenshot, "should be less than 10MB")
      end
    end

end
