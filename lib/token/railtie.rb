require 'rails'

require 'token/config'
require 'token/helpers/action_view_extension'

module Token
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'token' do |app|
      
      ActiveSupport.on_load(:action_view) do
        ::ActionView::Base.send :include, Token::ActionViewExtension
      end
    end
  end
end