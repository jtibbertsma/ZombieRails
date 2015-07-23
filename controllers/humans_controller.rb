require_relative 'application_controller'

class HumansController < ApplicationController
  def index
    if params[:flash]
      flash[:notice] = "We are currently testing flash.now from humans"
    end

    @humans = Human.all
    render :index
  end
end