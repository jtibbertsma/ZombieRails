require_relative '../zombie_controller/controller_base'

class ApplicationController < ControllerBase
  def index
    render :index
  end

  def flash_test
    flash[:notice] = "Now we're testing legit flash"

    redirect_to '/cats'
  end
end