require "net/http"
require "uri"
require "json"

class NotifyOpsgenie
  def initialize
    # TODO: move it to database settings
    @opsgenie_url = "https://api.eu.opsgenie.com"
  end

  def send(user, client_info, message_info)
    uri = URI.parse("#{@opsgenie_url}/v2/alerts")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "GenieKey %s" % (ENV["OPSGENIE_API_TOKEN"])
    request.body = JSON.dump({
                               "message" => "#{client_info["user"]["real_name"]} calls you in slack!",
                               "description" => (message_info["permalink"]).to_s,
                               "responders" => [
                                 {
                                   user["field_name"] => user["name"],
                                   "type" => user["type"]
                                 }
                               ],
                               "tags" => [
                                 "slack_bot"
                               ],
                               "priority" => "P2"
                             })

    req_options = {
      use_ssl: uri.scheme == "https"
    }

    Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end

  def GetOnCall(schedule_name:)
    encoded_schedule_name = URI.encode_www_form_component(schedule_name)
    uri = URI.parse("#{@opsgenie_url}/v2/schedules/#{encoded_schedule_name}/on-calls?scheduleIdentifierType=name&flat=true")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "GenieKey %s" % (ENV["OPSGENIE_API_TOKEN"])

    req_options = {
      use_ssl: uri.scheme == "https"
    }

    Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end
end
