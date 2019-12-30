require 'mail'
require 'yaml'
require 'erb'
require 'net/http'
require 'uri'
require 'json'

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

class NotifyOpsgenie
  def initialize
    @opsgenie_url = "https://api.eu.opsgenie.com"
  end
  def send(user,client)
    uri = URI.parse("#{@opsgenie_url}/v2/alerts")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "GenieKey %s" % (ENV['OPSGENIE_API_TOKEN'])
    request.body = JSON.dump({
                                 "message" => "#{client.name} calls you in slack!",
                                 "responders" => [
                                     {
                                         "username" => user,
                                         "type" => "user"
                                     }
                                 ],
                                 "tags" => [
                                     "slack_bot"
                                 ],
                                 "priority" => "P2"
                             })

    req_options = {
        use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    return response
  end
end