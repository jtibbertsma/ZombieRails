require_relative 'application_controller'

class CatsController < ApplicationController
  def index
    if params[:flash]
      flash[:notice] = "We are currently testing flash.now from cats"
    end

    @cats = Cat.all
    render :index
  end
end