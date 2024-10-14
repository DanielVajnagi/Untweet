class WelcomeController < ApplicationController
  before_action :authenticate_user! # Ensure the user is authenticated

  def index
  end
end
