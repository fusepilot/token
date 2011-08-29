require "redcarpet"

module Token
  
  class Error < StandardError; end
  
  class Render < AbstractController::Base
   include AbstractController::Rendering
    
    attr_accessor :rendered
    
    self.view_paths = "app/views"
    
    def initialize text=nil
      unless text.nil? 
        @rendered = markdown(replace(text, tokens))
      end
    end
    
    def replace text
      text.gsub(/@\[(?<type>.*)\]\((?<id>.*)\)/) do |token|
        type, id = $1, $2
        token = get_token_view(type, id)
      end
    end
      
    def get_token_view type, id
      return case type
        when "vimeo"
          render :partial => 'shared/vimeo', :locals => {:id => id}
        when "youtube"
          render :partial => 'shared/youtube', :locals => {:id => id}
        when "teaser-image"
          render :partial => 'shared/teaser_image', :locals => {:image => Image.find(id)}
        when "gallery"
          render :partial => 'shared/gallery', :locals => {:gallery => Gallery.find(id)}
        
        else
          raise Token::Error, "Couldn't find token template: #{type}."
      end
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
        
        unless self.column_names.include?(attribute.to_s) &&
                 self.column_names.include?("rendered_#{attribute}")
          raise "#{self.name} doesn't have required attributes :#{attribute} and :rendered_#{attribute}\nPlease generate a migration to add these attributes -- both should have type :text."
        end
        
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