class ThemeImage < ApplicationRecord
  KEY_PREFIX = "theme:"

  has_one_attached :file

  validates :name, presence: true
  validates :file, presence: true
  validate :file_must_be_image

  scope :ordered, -> { order(:name, :id) }

  def image_key
    "#{KEY_PREFIX}#{id}"
  end

  def self.id_from_image_key(image_key)
    image_key.to_s.delete_prefix(KEY_PREFIX).to_i if image_key.to_s.start_with?(KEY_PREFIX)
  end

  private

  def file_must_be_image
    return unless file.attached?
    return if file.content_type.to_s.start_with?("image/")

    errors.add(:file, "must be an image")
  end
end
