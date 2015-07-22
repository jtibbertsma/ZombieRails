require 'json'
require 'webrick'

class Session
  COOKIE_NAME = '_rails_lite_app'

  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    req.cookies.each do |cookie|
      if cookie.name == COOKIE_NAME
        @values = JSON.parse(cookie.value)
        break
      end
    end
    @values ||= {}
  end

  def [](key)
    @values[key]
  end

  def []=(key, val)
    @values[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << WEBrick::Cookie.new(COOKIE_NAME, @values.to_json)
  end
end