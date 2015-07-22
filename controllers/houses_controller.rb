require_relative 'application_controller'

class HousesController < ApplicationController
  def index
    @houses = House.all
    render :index
  end
end