require 'action_controller'

module Token
  
  mattr_accessor :options
  Token.options = {}
  
  class << self
    def render text=nil
      unless text.nil? 
        @replaced = find_tokens text do |token|
          Token::Render.new.render_token token
        end
        @replaced = markdown(@replaced)
      end
    end
    
    def config_file
      Rails.root.join("config", "token.yml")
    end
    
    def views_directory
      Rails.root.join("app", "views")
    end
    
    def find_tokens text, &block
      tokens = []

      text.gsub!(/@\[(.+)\](?:\{(.*)\})*\((.*)\)/) do |match|
        type, args, value = $1, $2, $3
        if block_given?
          block_replace = block.call({:type => type, :args => parse_args(args), :value => value})
          match = block_replace
        end
      end
      return text
    end
    
    def parse_args args
      args_hash = {}
      unless args.nil?
        args.split(',').each do |arg|
          k, v = arg.strip.split("=").map(&:to_s)
          args_hash[k.to_sym] = v.to_s
        end
      end
      return args_hash
    end
    
    def reload!
      Token::Config.load!
    end
    
    private
    
    def markdown text
      html_renderer = Redcarpet::Render::XHTML.new(:hard_wrap => true)
      markdown = Redcarpet::Markdown.new(html_renderer, :autolink => true)
      rendered_text = markdown.render(text)
    end
  end
  
  class TokenConfigError < Exception; end
  
  module Config
    mattr_accessor :options
    
    def self.load!
      if File.exists?(Token.config_file)
        Token.options = {}
        File.open(Token.config_file) do |f|
          file_options = YAML::load(ERB.new(f.read).result).symbolize_keys
          file_options.each do |k, v|
            Token.options[k] = v.symbolize_keys!
          end if file_options
        end
      else
        #raise TokenConfigError, "Config file 'token.yml', was not found."
        return false
      end
    end
  end
  
  
  class Render < AbstractController::Base
    include AbstractController::Rendering
    
    def render_token token
      Render.view_paths = Token.views_directory.to_s
      locals = token[:args].merge!({:type => token[:type], :value => token[:value]})
      
      #unless token[:model].nil?
      #  model_name = token[:model].constantize
      #  model = model_name.find(arg)
      #  locals[token[:model].downcase.to_sym] = model
      #end
      
      #merge in config parameters
      token.merge! Token.options[token[:type].to_sym]
      return render :partial => token[:partial], :locals => locals
    end
  end
  
  module ActionViewExtension
    extend ::ActiveSupport::Concern
    
    module InstanceMethods
      def tokenize text
        ::Token.render text
      end
    end
  end
  
  ::ActionView::Base.send :include, Token::ActionViewExtension
end