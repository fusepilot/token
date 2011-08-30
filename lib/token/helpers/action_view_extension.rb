module Token
  module ActionViewExtension
    extend ::ActiveSupport::Concern
    
    module InstanceMethods
      def tokenize text
        Token::Render.new(text).rendered
      end
    end
  end
end