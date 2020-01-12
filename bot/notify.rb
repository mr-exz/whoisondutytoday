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
    #TODO: move it to database settings
    @opsgenie_url = "https://api.eu.opsgenie.com"
  end
  def send(user,client_info)
    uri = URI.parse("#{@opsgenie_url}/v2/alerts")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "GenieKey %s" % (ENV['OPSGENIE_API_TOKEN'])
    request.body = JSON.dump({
                                 "message" => "#{client_info['user']['real_name']} calls you in slack!",
                                 "responders" => [
                                     {
                                         user['field_name'] => user['name'],
                                         "type" => user['type']
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

    Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end

  def GetOnCall(schedule_name:)
    uri = URI.parse("#{@opsgenie_url}/v2/schedules/#{schedule_name}/on-calls?scheduleIdentifierType=name&flat=true")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "GenieKey %s" % (ENV['OPSGENIE_API_TOKEN'])

    req_options = {
        use_ssl: uri.scheme == "https",
    }

    Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end
end