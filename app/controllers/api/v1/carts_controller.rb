module Api
  module V1
    class CartsController < ApplicationController
      protect_from_forgery with: :null_session

      SHIPPING_REGIONS = %w[eu us uk].freeze
      before_action :sanitize_input_parameters, only: :create

      def index
        CartsManager.delivery_information(params)
        render json: { success: true, message: 'Yay! Route is working.' }, status: :ok
      end

      def create
        render json: { success: true, message: 'Yay! Route is working.' }, status: :ok
      end

      private

      def sanitize_input_parameters
        check_shipping_region and return
        check_items
      end

      def check_shipping_region
        if params[:shipping_region]
          unless SHIPPING_REGIONS.include?(params[:shipping_region])
            malformed_request(I18n.t('bad_request.region.non_deliverable'))
          end
        else
          malformed_request(I18n.t('bad_request.region.not_found'))
        end
      end

      def check_items
        malformed_request(I18n.t('bad_request.items.empty')) and return if params[:items].blank?

        malformed_request(I18n.t('bad_request.items.zeroed')) if params[:items].pluck(:count).map(&:to_i).include?(0)
      end

      def malformed_request(message)
        render json: { success: false, message: message }, status: :bad_request
      end
    end
  end
end
