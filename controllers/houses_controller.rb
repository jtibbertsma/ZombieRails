require_relative 'application_controller'

class HousesController < ApplicationController
  def index
    render :index
  end
end