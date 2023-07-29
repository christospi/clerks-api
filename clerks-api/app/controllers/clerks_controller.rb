class ClerksController < ApplicationController
  # GET /clerks
  def index
    @clerks = Clerk.all
  end

  # POST /populate
  def populate
    Clerk.create_from_random_user

    redirect_to clerks_path
  end
end
