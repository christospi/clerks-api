class ClerkPictureDownloadJob < ApplicationJob
  queue_as :default

  def perform(clerk_id, picture_url)
    clerk = Clerk.find(clerk_id)
    picture = Downloader.download(picture_url)

    if picture.present?
      clerk.picture.attach(io: picture, filename: "#{Digest::MD5.hexdigest(clerk.email)}.jpg",
                           content_type: 'image/jpeg')
    end
  end
end
