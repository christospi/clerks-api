# The RandomUserSerializer class is responsible for transforming data
# from the Random User API into a format that can be used by the Clerk model.
#
# The `.to_clerk_attributes` class method converts user's data into a
# hash of attributes suitable for creating or updating a Clerk record.
#
# Example usage:
#
#     user = RandomUser.fetch_users.first
#     attributes = RandomUserSerializer.to_clerk_attributes(user)
#     clerk = Clerk.create!(attributes)
#
# For more info, see RandomUser module documentation.
class RandomUserSerializer
  # Converts the random user hash to a Hash with the attributes required to
  # create a Clerk.
  #
  # @param user [Hash] A Hash representing a random user.
  # @return [Hash] A Hash with the attributes required to create a Clerk.
  def self.to_clerk_attributes(user)
    {
      first_name: user['name']['first'],
      last_name: user['name']['last'],
      email: user['email'],
      phone: user['phone'],
      registration_date: DateTime.parse(user['registered']['date']),
      picture_url: user['picture']['thumbnail']
    }
  end
end
