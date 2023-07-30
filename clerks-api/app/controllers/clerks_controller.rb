class ClerksController < ApplicationController
  DEFAULT_PAGE_SIZE = 10
  MAX_PAGE_SIZE = 100

  # GET /clerks
  def index
    params = index_params

    @clerks = Clerk.with_attached_picture.order(registration_date: :desc, id: :desc)

    if params[:email]
      # No need to downcase email column; it's already downcase-d in the model
      @clerks = @clerks.where(email: params[:email].downcase)
    end

    if params[:ending_before]
      ending_before_attrs = Clerk.where(id: params[:ending_before]).
        pick(:registration_date, :id)

      if ending_before_attrs.present?
        @clerks = @clerks.where('(registration_date, id) > (?, ?)', ending_before_attrs[0], ending_before_attrs[1])
        # Reverse the order of Clerks if we're fetching the previous page to
        # get the immediate preceding Clerks, not the preceding starting from
        # the start (i.e. the least recent of the most recent).
        @clerks = @clerks.reverse_order
      else
        # If the Clerk with the given ID doesn't exist, return an empty result
        @clerks = Clerk.none
      end
    elsif params[:starting_after]
      starting_after_attrs = Clerk.where(id: params[:starting_after]).
        pick(:registration_date, :id)

      @clerks =
        if starting_after_attrs.present?
          @clerks.where('(registration_date, id) < (?, ?)', starting_after_attrs[0], starting_after_attrs[1])
        else
          Clerk.none
        end
    end

    @page_size = params[:limit].to_i
    @page_size = @page_size.positive? && @page_size <= MAX_PAGE_SIZE ? @page_size : DEFAULT_PAGE_SIZE

    # Fetch one more Clerk than the page size to determine if there's a next
    # or previous page
    @clerks = @clerks.limit(@page_size + 1)

    # Convert the ActiveRecord::Relation to an Array to avoid any extra
    # queries to the database
    @clerks = @clerks.to_a
    @fetched_records_count = @clerks.size

    # Remove the extra Clerk from the collection
    @clerks = @clerks.take(@page_size)

    # Reverse the order of Clerks if we're fetching the previous page to
    # save a few %#@$%! from the user :)
    @clerks.reverse! if params[:ending_before]

    set_pagination_state!

    respond_to do |format|
      format.html
      format.json { render json: @clerks }
    end
  end

  # POST /populate
  def populate
    Clerk.create_from_random_user

    redirect_to clerks_path
  end

  private

  def index_params
    params.permit(:limit, :starting_after, :ending_before, :email)
  end

  def set_pagination_state!
    params = index_params

    # TODO: Improve this logic (email is unique, so we can't have more than one)
    if !@fetched_records_count.positive? || params[:email].present?
      @has_previous_page = false
      @has_next_page = false

      return
    end

    if params[:starting_after].blank? && params[:ending_before].blank?
      # We are on the first page, no previous exists
      @has_previous_page = false
      @has_next_page = @fetched_records_count > @page_size
    elsif params[:starting_after].present?
      # We are moving forward, so there is a previous page
      @has_previous_page = true
      @has_next_page = @fetched_records_count > @page_size
    elsif params[:ending_before].present?
      # We are moving backward, so there is a next page
      @has_previous_page = @fetched_records_count > @page_size
      @has_next_page = true
    end
  end
end
