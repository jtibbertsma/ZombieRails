require_relative 'application_controller'

class HousesController < ApplicationController
  def index
    if params[:flash]
      flash[:notice] = "We are currently testing flash.now from houses"
    end

    @houses = House.all
    render :index
  end
end