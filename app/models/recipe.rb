class Recipe < ApplicationRecord
  ALLOWED_PHOTO_TYPES = %w[image/jpeg image/png].freeze

  has_one_attached :photo

  validates :title, presence: true
  validates :prep_time, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :photo_must_be_an_allowed_image

  private

  def photo_must_be_an_allowed_image
    return unless photo.attached?
    return if ALLOWED_PHOTO_TYPES.include?(photo.content_type)

    errors.add(:photo, "must be a JPEG or PNG")
  end
end
