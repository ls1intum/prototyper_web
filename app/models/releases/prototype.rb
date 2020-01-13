class Prototype < Release
  VALID_MARVEL_URL_REGEX = /https?:\/\/marvelapp.com\/[\S]+/

  validates :url, presence: true, length: { maximum: 100 }, format: { with: VALID_MARVEL_URL_REGEX }
end
