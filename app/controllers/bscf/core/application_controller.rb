module Bscf
  module Core
    class ApplicationController < ActionController::API
      include Pundit::Authorization

      private

      def is_authenticated
        render json: { error: "Not authenticated" }, status: :unauthorized unless current_user
      end

      def current_user
        return @current_user if defined?(@current_user)

        return unless auth_token

        begin
          payload = TokenService.new.decode(auth_token)
          @current_user = User.find_by(id: payload["user"]["id"])
        rescue JWT::DecodeError => e
          Rails.logger.warn "Token decode error: #{e.message}"
          nil
        rescue ActiveRecord::RecordNotFound => e
          Rails.logger.warn "User not found: #{e.message}"
          nil
        end
      end

      def auth_token
        auth_header = request.headers["Authorization"]
        auth_header&.split(" ")&.last
      end
    end
  end
end
