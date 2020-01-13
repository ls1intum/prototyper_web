# encoding: utf-8

class IpaUploader < CarrierWave::Uploader::Base

  storage :file

  def store_dir
    "#{Rails.root}/private/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

end
