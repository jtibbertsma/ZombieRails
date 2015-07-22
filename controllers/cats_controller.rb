require_relative 'application_controller'

class CatsController < ApplicationController
  def index
    render :index
  end
end