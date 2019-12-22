require 'mail'
require 'yaml'
require 'erb'

class Notify

  def initialize
    @options = {
        :address => 'replme',
        :port    => 587,
        :domain  => 'replme'
    }
    @auth_options = {
        :user_name			  => 'replme',
        :password		      => 'replme',
        :authentication		=> :login,
        :enable_starttls_auto => true
    }
    @options.merge!(@auth_options)
  end

  def send(data)
    @user_list = data

    mail = Mail.new
    mail.delivery_method :smtp, @options

    mail.from ''
    mail.to ''
    mail.subject ''
    mail.content_type 'text/html; charset=UTF-8'
    mail.body data
    mail.deliver
  end

end