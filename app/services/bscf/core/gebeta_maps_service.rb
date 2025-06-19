require "httparty"

module Bscf
  module Core
    class GebetaMapsService
      include HTTParty
      base_uri "https://mapapi.gebeta.app/api"

      def initialize
        @api_key = Rails.application.credentials.gebeta_api_key || ENV["GEBETA_API_KEY"]
      end

      def optimize_route(origin_address, destination_addresses)
        return {} if destination_addresses.empty?

        origin = origin_address.coordinates
        destinations = destination_addresses.map(&:coordinates).compact
        return {} if origin.nil? || destinations.empty?

        origin_str = "{#{origin[0]},#{origin[1]}}"
        destinations_str = destinations.map { |lat, lon| "{#{lat},#{lon}}" }.join(",")
        json_param = "[#{destinations_str}]"

        url = "https://mapapi.gebeta.app/api/route/onm?origin=#{origin_str}&json=#{json_param}&apiKey=#{@api_key}"
        response = HTTParty.get(url)

        handle_response(response)
      end

      private

      def handle_response(response)
        if response.success?
          JSON.parse(response.body)
        else
          Rails.logger.error("Gebeta Maps API error: #{response.code} - #{response.body}")
          {}
        end
      end
    end
  end
end
