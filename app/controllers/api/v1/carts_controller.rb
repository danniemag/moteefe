module Api
  module V1
    class CartsController < ApplicationController
      def index
        render json: { success: true, message: 'Yay! Route is working.' }, status: :ok
      end
    end
  end
end
