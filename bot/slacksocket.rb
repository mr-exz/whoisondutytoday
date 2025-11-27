# bot/slacksocket.rb
require 'async'
require 'async/http/endpoint'
require 'async/websocket/client'
require 'json'
require 'nice_http'
require 'slack-ruby-client'
require 'set'
require 'openssl'

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
      response = @web_client.auth_test
      raise "Error fetching bot info: #{response['error']}" unless response['ok']

      # Store messages with timestamp to prevent memory leak
      @processed_messages = {}  # Changed from Set to Hash to store timestamps
      @message_ttl_seconds = 3600  # Keep messages for 1 hour
      @reconnect_attempts = 0
      @max_reconnect_attempts = 10
      @reconnect_delay = 2  # Start with 2 seconds
      @self = User.new(response['user'], response['user_id'])
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
      Async do
        loop do
          begin
            @reconnect_attempts = 0  # Reset on successful connection
            @reconnect_delay = 2

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
            raise(AdquisitionError, "Connection failed: #{result.error}") unless result.ok

            websocket_url = result.url

            # Configure SSL context with verification disabled for dev environment
            ssl_context = OpenSSL::SSL::SSLContext.new
            ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE

            endpoint = Async::HTTP::Endpoint.parse(websocket_url, protocols: Async::WebSocket::Client, ssl_context: ssl_context)

            Async::WebSocket::Client.connect(endpoint) do |connection|
              @connection = connection
              set_presence_online
              set_presence_online_via_websocket(connection)
              while (message = connection.read)
                handle_message(message, connection)
              end
            end
          rescue EOFError => e
            puts "EOFError: #{e.message}. Attempting to reconnect..."
            handle_reconnection
          rescue StandardError => e
            puts "An error occurred: #{e.class} - #{e.message}. Attempting to reconnect..."
            handle_reconnection
          end
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
        "<@#{@self.id}>",
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

    def handle_message(message, connection)
      data = JSON.parse(message)

      if data['type'] == 'hello'
        puts 'Connection established.'
      elsif data['envelope_id']
        # Acknowledge the message immediately to prevent re-delivery
        connection.write(JSON.dump(envelope_id: data['envelope_id']))

        # Clean up old messages periodically (every 100 messages)
        cleanup_old_messages if @processed_messages.size % 100 == 0

        # Process the event
        event = data['payload']['event']
        client_msg_id = event['client_msg_id']

        # For events without client_msg_id (like app_mention), use event type + ts as unique identifier
        event_identifier = client_msg_id || "#{event['type']}_#{event['ts']}"

        if !@processed_messages.key?(event_identifier)
          @processed_messages[event_identifier] = Time.now.to_i
          WhoIsOnDutyTodaySlackBot.process_event(self, data) if event
        end
      end
    rescue JSON::ParserError => e
      puts "Failed to parse message: #{e.message}"
    rescue StandardError => e
      puts "An error occurred in handle_message: #{e.message}"
    end

    private

    def handle_reconnection
      if @reconnect_attempts >= @max_reconnect_attempts
        puts "Max reconnection attempts (#{@max_reconnect_attempts}) reached. Giving up."
        raise ConnectionError, "Failed to reconnect after #{@max_reconnect_attempts} attempts"
      end

      @reconnect_attempts += 1
      puts "Reconnection attempt #{@reconnect_attempts}/#{@max_reconnect_attempts}. Waiting #{@reconnect_delay} seconds..."
      sleep @reconnect_delay

      # Exponential backoff: double the delay, max 60 seconds
      @reconnect_delay = [@reconnect_delay * 2, 60].min
    end

    def cleanup_old_messages
      current_time = Time.now.to_i
      @processed_messages.reject! do |msg_id, timestamp|
        current_time - timestamp > @message_ttl_seconds
      end
    end

    class WebClient < Slack::Web::Client
    end
  end
end
