class ClerksController < ApplicationController
  # GET /clerks
  def index
    @clerks = Clerk.all
  end
end
