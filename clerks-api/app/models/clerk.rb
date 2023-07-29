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

  # Create Clerk records from users fetched from the RandomUser API. If a user
  # fails to be created, the error is logged and the process continues.
  #
  # @option options [Integer] :size (5) The number of users to fetch and create.
  # @return [void]
  def self.create_from_random_user(size: 5)
    users = RandomUser.fetch_users(size: size)
    success_count = 0

    users.each do |user|
      attributes = RandomUserSerializer.to_clerk_attributes(user)

      clerk = Clerk.new(attributes.except(:picture_url))
      picture = Downloader.download(attributes[:picture_url])

      if picture.present?
        clerk.picture.attach(io: picture, filename: "#{Digest::MD5.hexdigest(clerk.email)}.jpg",
                             content_type: 'image/jpeg')
      end

      if clerk.save
        Rails.logger.info("Successfully created Clerk record for #{clerk.email}")
        success_count += 1
      else
        errors = clerk.errors.full_messages.join(', ')
        Rails.logger.error("Failed to create Clerk record for #{attributes[:email]}: #{errors}")
      end
    end

    Rails.logger.info("Successfully created #{success_count}/#{size} Clerk records")
  end

  private

  def acceptable_picture
    return unless picture.attached?

    errors.add(:picture, 'is too big') unless picture.byte_size < VALID_PICTURE_SIZE
    errors.add(:picture, 'must be JPEG or PNG') unless VALID_PICTURE_TYPES.include?(picture.content_type)
  end
end
