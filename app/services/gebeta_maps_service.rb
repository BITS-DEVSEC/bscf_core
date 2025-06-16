  require 'httparty'

  module Bscf
    module Core
      class GebetaMapsService
        include HTTParty
        base_uri "https://api.gebeta.app/api/v1"

        def initialize
          @api_key = Rails.application.credentials.gebeta_maps[:api_key]
        end

        # One-to-Many (ONM) API for route optimization
        def optimize_route(origin_address, destination_addresses)
          return {} if destination_addresses.empty?

          # Extract coordinates
          origin = origin_address.coordinates
          destinations = destination_addresses.map(&:coordinates).compact

          return {} if origin.nil? || destinations.empty?

          # Prepare destinations in the format expected by Gebeta Maps
          destinations_json = destinations.map.with_index do |coords, index|
            {
              id: index,
              point: {
                lat: coords[0],
                lng: coords[1]
              }
            }
          end.to_json

          # Make API request
          response = self.class.get(
            "/direction/onm",
            query: {
              origin: "#{origin[0]},#{origin[1]}",
              json: destinations_json,
              key: @api_key
            }
          )

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
