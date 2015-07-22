require_relative '../zombie_controller/controller_base'

class ApplicationController < ControllerBase
  def index
    render :index
  end
end