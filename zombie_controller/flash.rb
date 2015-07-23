class Flash
  attr_reader :now

  COOKIE_NAME_REDIR = Session::COOKIE_NAME + '_redir'
  COOKIE_NAME_SHOW  = Session::COOKIE_NAME + '_flash'

  def initialize(request)
    request.cookies.each do |cookie|
      if cookie.name == COOKIE_NAME_REDIR
        @redir_values = JSON.parse(cookie.value)
      elsif cookie.name == COOKIE_NAME_SHOW
        @show_values = JSON.parse(cookie.value)
      end
    end
    @redir_values ||= {}
    @show_values ||= {}
    @values_to_persist = {}
    @now = {}
  end

  def [](key)
    @redir_values[key] || @values_to_persist[key] || @now[key]
  end

  def []=(key, value)
    @values_to_persist[key] = value
  end

  def store_session(res)
    res.cookies << WEBrick::Cookie.new(COOKIE_NAME_REDIR, @values_to_persist.to_json)
    res.cookies << WEBrick::Cookie.new(COOKIE_NAME_SHOW, @redir_values.to_json)
  end
end