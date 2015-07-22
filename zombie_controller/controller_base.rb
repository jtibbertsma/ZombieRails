require 'active_support'
require 'active_support/core_ext'
require 'erb'

require_relative 'session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @params = Params.new(req, route_params)
    @req, @res = req, res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Already built response!" if already_built_response?
    @already_built_response = true

    session.store_session(res)
    res.header["location"] = url
    res.status = 302
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Already built response!" if already_built_response?
    @already_built_response = true

    session.store_session(res)
    res.content_type = content_type
    res.body = content
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    raw = File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb")
    template = ERB.new(raw)

    render_content template.result(binding), 'text/html'
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
  end
end