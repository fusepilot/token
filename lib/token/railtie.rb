require 'rails'
require 'token/core'

module Token
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'token' do |app|
      ActiveSupport.on_load(:action_view) do
        ::ActionView::Base.send :include, Token::ActionViewExtension
      end
    end
  end
end