require 'webrick'

class Server
  def self.require_in_dir(dirname)
    Dir.entries(dirname).each do |filename|
      require_relative(dirname + '/' + filename) if filename.end_with?('.rb')
    end
  end

  require_in_dir 'zombie_record'
  require_in_dir 'zombie_controller'
  require_in_dir 'controllers'
  require_in_dir 'models'

  def initialize
    @router = Router.new
    
    @router.draw do
      get(/^\/cats$/, CatsController, :index)
      get(/^\/humans$/, HumansController, :index)
      get(/^\/houses$/, HousesController, :index)
    end

    @server = WEBrick::HTTPServer.new(Port: 3000)
    @server.mount_proc('/') do |req, res|
      route = @router.run(req, res)
    end

    trap('INT') { @server.stop }
  end

  def run
    @server.start
  end
end

Server.new.run