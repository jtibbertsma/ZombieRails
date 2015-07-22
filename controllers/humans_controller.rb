require_relative 'application_controller'

class HumansController < ApplicationController
  def index
    render :index
  end
end