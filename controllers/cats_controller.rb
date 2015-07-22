require_relative 'application_controller'

class CatsController < ApplicationController
  def index
    @cats = Cat.all
    render :index
  end
end