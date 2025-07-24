# bot/slacksocket.rb
require 'async'
require 'async/http/endpoint'
require 'async/websocket/client'
require 'json'
require 'nice_http'
require 'slack-ruby-client'
require 'set'

module SlackSocket
  class Client < Slack::RealTime::Client
    attr_accessor :self
    AdquisitionError = Class.new(StandardError)
    ConnectionError = Class.new(StandardError)
    AcknowledgeError = Class.new(StandardError)

    def initialize(attrs = {})
      super(attrs)
      @aliases = attrs[:aliases]
      @allow_message_loops = attrs.fetch(:allow_message_loops, false)
      @allow_bot_messages = attrs.fetch(:allow_bot_messages, false)
      @socket_token = ENV['SLACK_SOCKETS_TOKEN']
      @bot_token = ENV['SLACK_BOT_TOKEN'] # Ensure this is set with your Bot User OAuth Token
      @web_client = WebClient.new(token: @bot_token)
      @processed_messages = Set.new
      @self = User.new('cibot', 'U08LT6D4BE1')
    end

    class User
      attr_accessor :name, :id

      def initialize(name, id)
        @name = name
        @id = id
      end
    end

    def allow_message_loops?
      @allow_message_loops.nil? ? SlackRubyBot::Config.allow_message_loops? : !!@allow_message_loops
    end

    def allow_bot_messages?
      @allow_bot_messages.nil? ? SlackRubyBot::Config.allow_bot_messages? : !!@allow_bot_messages
    end

    def connect
      http = NiceHttp.new('https://slack.com')
      request = {
        headers: {
          Authorization: "Bearer #{@socket_token}",
        },
        path: '/api/apps.connections.open',
      }
      connection_info = http.post(request)
      http.close
      result = connection_info.data.json
      raise(AdquisitionError) unless result.ok

      websocket_url = result.url
      endpoint = Async::HTTP::Endpoint.parse(websocket_url, protocols: Async::WebSocket::Client)

      Async do
        begin
          Async::WebSocket::Client.connect(endpoint) do |connection|
            @connection = connection
            set_presence_online
            set_presence_online_via_websocket(connection)
            while (message = connection.read)
              handle_message(message, connection)
            end
          end
        rescue EOFError => e
          puts "EOFError: #{e.message}. Reconnecting..."
          Thread.current.kill
        rescue StandardError => e
          puts "An error occurred: #{e.message}. Reconnecting..."
        end
      end
    end

    def set_presence_online
      response = @web_client.users_setPresence(presence: 'auto')
      if response['ok']
        puts 'Bot presence set to online.'
      else
        puts "Failed to set presence: #{response['error']}"
      end
    end

    def set_presence_online_via_websocket(connection)
      presence_update = {
        type: 'presence_change',
        presence: 'active',
        user: @self.id
      }
      connection.write(JSON.dump(presence_update))
      puts "Sent presence update via WebSocket: #{presence_update}"
    end
    def web_client
      @web_client
    end

    def names
      [
        '<@U08LT6D4BE1>',
      ].compact.flatten
    end
    def name?(name)
      name && names.include?(name)
    end

    def name
      SlackRubyBot.config.user || self.self&.name
    end

    def say(options = {})
      logger.warn '[DEPRECATION] `gif:` is deprecated and has no effect.' if options.key?(:gif)
      message({ text: '' }.merge(options))
    end

    def message(options = {})
      raise ArgumentError, 'Required arguments :channel missing' if options[:channel].nil?
      raise ArgumentError, 'Required arguments :text missing' if options[:text].nil?

      send_json({ type: 'message', id: next_id }.merge(options))
    end

    def send_json(data)
      @web_client.chat_postMessage(data)
    end

    def message_to_self?(data)
      !!(self.self && self.self.id == data.user)
    end

    def bot_message?(data)
      data.subtype == 'bot_message'
    end

    private

    def handle_message(message, connection)
      data = JSON.parse(message)
      #puts "Received message: #{data}"

      if data['type'] == 'hello'
        puts 'Connection established.'
      elsif data['envelope_id']
        # Acknowledge the message
        connection.write(JSON.dump(envelope_id: data['envelope_id']))
        #puts "Acknowledged message with envelope_id: #{data['envelope_id']}"

        # Process the event
        event = data['payload']['event']
        client_msg_id = event['client_msg_id']

        if client_msg_id && !@processed_messages.include?(client_msg_id)
          @processed_messages.add(client_msg_id)
          WhoIsOnDutyTodaySlackBot.process_event(self, data) if event
        end
      end
    rescue JSON::ParserError => e
      puts "Failed to parse message: #{e.message}"
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
    end

    class WebClient < Slack::Web::Client

    end
  end
end
