require "redcarpet"

module Token
  
  class Error < StandardError; end
  
  class Render < AbstractController::Base
   include AbstractController::Rendering
    
    attr_accessor :rendered
    
    self.view_paths = "app/views"
    
    def initialize text=nil
      unless text.nil? 
        tokens = find_tokens(text)
        @rendered = markdown(replace(text, tokens))
      end
    end
    
    def find_tokens text
      tokens = []
      text.scan(/@\[(?<type>.*)\]\((?<id>.*)\)/).each do |match|
        type = match[0]
        id = match[1]
        pattern = "@[#{type}](#{id})"
        tokens << {:type => type, :id => id, :pattern => pattern}
      end
      tokens
    end
      
    def get_token_view type, id
      return case type
        when "vimeo"
          render :partial => 'token/vimeo', :locals => {:id => id}
        when "youtube"
          render :partial => 'token/youtube', :locals => {:id => id}
        when "gallery"
          render :partial => 'token/gallery', :locals => {:gallery => Gallery.find(id)}
        else
          raise Token::Error, "Couldn't find token template: #{type}."
      end
    end
    
    def replace text, tokens
      tokens.each do |token|
        token_view = get_token_view(token[:type], token[:id])
        text.gsub!(/#{Regexp.quote(token[:pattern])}/, token_view)
      end
      text
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
  
  module Tokenize
    extend ActiveSupport::Concern
  
    module ClassMethods
      def tokenize attribute
        self.before_validation :"render_#{attribute}"

        define_method :"render_#{attribute}" do
          self.send :"rendered_#{attribute}=", Token::Render.new(self.send(attribute)).rendered
        end
      end
    end
  end
  
  module TokenizeHelper
    extend ActiveSupport::Concern
    
    module InstanceMethods
      def tokenize text
        Token::Render.new(text).rendered
      end
    end
  end
end

ActiveRecord::Base.send :include, Token::Tokenize
ActionView::Base.send :include, Token::TokenizeHelper