class Clerk < ApplicationRecord
  VALID_PICTURE_TYPES = %w[image/jpeg image/png].freeze
  VALID_PICTURE_SIZE = 5.megabytes

  has_one_attached :picture

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, length: { maximum: 128 },
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { case_sensitive: false }
  validates :phone, presence: true, length: { maximum: 32 }
  validates :registration_date, presence: true

  validate :acceptable_picture

  before_save { email.downcase! if email_changed? }

  private

  def acceptable_picture
    return unless picture.attached?

    errors.add(:picture, 'is too big') unless picture.byte_size < VALID_PICTURE_SIZE
    errors.add(:picture, 'must be JPEG or PNG') unless VALID_PICTURE_TYPES.include?(picture.content_type)
  end
end
