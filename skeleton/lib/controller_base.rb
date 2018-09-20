require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response 
  end

  # Set the response status code and header
  def redirect_to(url)
    @res['Location'] = url
    @res.status = 302
    if already_built_response?
      raise "Double Render Error"
    end 
    @already_built_response = true
    session.store_session(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type = 'text/html')
    if already_built_response?
      raise "Double Render Error"
    end 
    @already_built_response = true
    
    @res['Content-Type'] = content_type
    @res.write(content)
    session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    dir_name = File.dirname(File.dirname(__FILE__))
    path = File.join(dir_name, 'views', snake_case, 
      "#{template_name}.html.erb")
    stuff = File.read(path)
    render_content(ERB.new(stuff).result(binding))
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
  
  private 
  
  def snake_case
    class_name = self.class.to_s
    class_name.downcase!
    array = class_name.split("controller")
    "#{array.first}_controller"
  end 
  
end

