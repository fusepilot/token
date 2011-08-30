require "redcarpet"
require 'token/railtie'
require 'token/engine'
require 'action_controller'

module Token
  class Error < StandardError; end
  
  class Render < AbstractController::Base
   include AbstractController::Rendering
   include Token
    
    attr_accessor :rendered
    
    self.view_paths = "app/views"
    
    def initialize text=nil
      unless text.nil? 
        parse_tokens text do |token|
          render_token token
          #markdown(render_token(token[:type], token[:args], token[:value]))
        end
      end
    end
    
    def parse_tokens text, &block
      # matches "@[token-name](main value for token)" and
      # "@[token-name]{arg=value}(main value for token)"
      text.gsub(/@\[(.+)\](?:\{(.*)\})*\((.*)\)/) do |match|
        type, args, value = $1, $2, $3
        args_hash = {}
        unless args.nil?
          args.split(',').each do |arg|
            k, v = arg.strip.split("=").map(&:to_s)
            args_hash[k.to_sym] = v.to_s
          end
        end


        if block_given?
          block.call({:type => type, :args => args_hash, :value => value})
        else 
          match
        end
      end
    end
    
    def render_token token
      Token::Configuration.load
      #locals = token[:args]
      
      #unless token[:model].nil?
      #  model_name = token[:model].constantize
      #  model = model_name.find(arg)
      #  locals[token[:model].downcase.to_sym] = model
      #end
      
      #render :partial => token[:partial], :locals => locals
    end
    
    def markdown text
      html_renderer = Redcarpet::Render::XHTML.new(:hard_wrap => true)
      markdown = Redcarpet::Markdown.new(html_renderer, :autolink => true, :space_after_headers => true)
      rendered_text = markdown.render(text)
    end
    
    def to_s
      @rendered
    end
  end
end