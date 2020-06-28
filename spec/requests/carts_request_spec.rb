require 'rails_helper'

RSpec.describe 'Carts', type: :request do
  deliverable_regions = %w[eu us uk]

  non_deliverable_regions = []
  while non_deliverable_regions.length < 5
    country_code = Faker::Address.country_code
    non_deliverable_regions << country_code unless %w[eu us uk].include? country_code
  end

  describe 'GET /api/v1/carts' do
    context 'test route request' do
      before do
        get '/api/v1/carts.json'
      end

      it 'should return some useful response' do
        expect(JSON(response.body)).not_to be_nil
      end

      it 'should contain expected attributes' do
        json_response = JSON(response.body)
        expect(json_response.keys).to match_array(%w[success message])
      end

      it 'returns http status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns success parameter' do
        json_response = JSON(response.body)
        expect(json_response['success']).to eq(true)
      end
    end
  end

  describe 'POST /api/v1/carts' do
    context 'when shipping_region is undeliverable' do
      before do
        request_body = { shipping_region: non_deliverable_regions.sample }

        post '/api/v1/carts.json', params: request_body
        @json_response = JSON(response.body)
      end

      it 'returns some useful response' do
        expect(@json_response).not_to be_nil
      end

      it 'returns bad_request http status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'contains some expected attributes' do
        expect(@json_response.keys).to match_array(%w[success message])
      end

      it 'returns success parameter equals to false' do
        expect(@json_response['success']).to eq(false)
      end

      it 'returns a message' do
        expect(@json_response['message']).to include(I18n.t('bad_request.region.non_deliverable'))
      end
    end

    context 'when shipping_region is missing' do
      let(:request_body) do
        { items: [
            {
                "name": 'blue_t-shirt',
                "count": rand(1..10)
            }
        ] }
      end

      before do
        post '/api/v1/carts.json', params: request_body
        @json_response = JSON(response.body)
      end

      it 'returns some useful response' do
        expect(@json_response).not_to be_nil
      end

      it 'returns bad_request http status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'contains some expected attributes' do
        expect(@json_response.keys).to match_array(%w[success message])
      end

      it 'returns success parameter equals to false' do
        expect(@json_response['success']).to eq(false)
      end

      it 'returns message' do
        expect(@json_response['message']).to include(I18n.t('bad_request.region.not_found'))
      end
    end

    context 'when basket is empty' do
      let(:request_body) do
        { "shipping_region": deliverable_regions.sample }
      end

      before do
        post '/api/v1/carts.json', params: request_body
        @json_response = JSON(response.body)
      end

      it 'returns some useful response' do
        expect(@json_response).not_to be_nil
      end

      it 'returns bad_request http status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'contains some expected attributes' do
        expect(@json_response.keys).to match_array(%w[success message])
      end

      it 'returns success parameter equals to false' do
        expect(@json_response['success']).to eq(false)
      end

      it 'returns a message' do
        expect(@json_response['message']).to include(I18n.t('bad_request.items.empty'))
      end
    end

    context 'when one or more basket items are zeroed' do
      let(:request_body) do
        {
            "shipping_region": 'eu',
            "items": [
                {
                    "name": 'blue_t-shirt',
                    "count": rand(1..10)
                },
                {
                    "name": 'black_mug',
                    "count": 0
                }
            ]
        }
      end

      before do
        post '/api/v1/carts.json', params: request_body
        @json_response = JSON(response.body)
      end

      it 'returns some useful response' do
        expect(@json_response).not_to be_nil
      end

      it 'returns bad_request http status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'contains some expected attributes' do
        expect(@json_response.keys).to match_array(%w[success message])
      end

      it 'returns success parameter equals to false' do
        expect(@json_response['success']).to eq(false)
      end

      it 'returns a message' do
        expect(@json_response['message']).to include(I18n.t('bad_request.items.zeroed'))
      end
    end

    context 'when one or more basket items amount exceed stock amount' do
      let(:request_body) do
        {
            "shipping_region": 'us',
            "items": [
                {
                    "name": 'white_mug',
                    "count": 1
                },
                {
                    "name": 'black_mug',
                    "count": rand(50..100)
                },
                {
                    "name": 'blue_t-shirt',
                    "count": rand(1..10)
                }
            ]
        }
      end

      before do
        Rails.application.load_seed

        post '/api/v1/carts.json', params: request_body
        @json_response = JSON(response.body)
      end

      it 'returns some useful response' do
        expect(@json_response).not_to be_nil
      end

      it 'returns http status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'contains some expected attributes' do
        expect(@json_response.keys).to match_array(%w[delivery_date shipments])
      end

      it 'excludes exceeded item from the response' do
        expect(@json_response['shipments'].pluck('items').flatten.pluck('title')).to_not include('black_mug')
      end

      it 'includes all other items to the response' do
        expect(@json_response['shipments'].pluck('items').flatten.pluck('title')).to include('white_mug')
        expect(@json_response['shipments'].pluck('items').flatten.pluck('title')).to include('blue_t-shirt')
      end
    end

    context 'when request is OK' do
      let(:request_body) do
        {
            "shipping_region": 'us',
            "items": [
                {
                    "name": 'black_mug',
                    "count": 4
                },
                {
                    "name": 'pink_t-shirt',
                    "count": 3
                },
                {
                    "name": 'white_mug',
                    "count": 1
                }
            ]
        }
      end

      before do
        Rails.application.load_seed

        post '/api/v1/carts.json', params: request_body
        @json_response = JSON(response.body)
      end

      it 'returns some useful response' do
        expect(@json_response).not_to be_nil
      end

      it 'returns http status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'contains some expected attributes' do
        expect(@json_response.keys).to match_array(%w[delivery_date shipments])
      end

      it 'includes all other items to the response' do
        request_body[:items].pluck(:name).each do |request_item|
          expect(@json_response['shipments'].pluck('items').flatten.pluck('title')).to include(request_item)
        end
      end

      it 'returns delivery_date as latest date among all shipments' do
        expect(@json_response['shipments'].pluck('delivery_date').max).to eq(@json_response['delivery_date'])
      end
    end

    context 'when there are different suppliers for a product in stock' do
      let(:request_body) do
        { "shipping_region": 'us', "items": [{ "name": 'pink_t-shirt', "count": 2 }] }
      end

      before do
        Rails.application.load_seed

        post '/api/v1/carts.json', params: request_body
        @json_response = JSON(response.body)
      end

      it 'delivers most from faster supplier' do
        product_deliver_date = (Date.today + Product
                                                 .where(product_name: request_body[:items].first[:name])
                                                 .pluck(:delivery_times)
                                                 .pluck('us')
                                                 .min).to_s
        expect(@json_response['delivery_date']).to eq(product_deliver_date)
      end
    end

    context 'when an item in the basket exceeds a supplier stock' do
      let(:request_body) do
        { "shipping_region": 'us', "items": [{ "name": 'black_mug', "count": 4 }] }
      end

      before do
        Rails.application.load_seed

        post '/api/v1/carts.json', params: request_body
        @json_response = JSON(response.body)
      end

      it 'delivers most of it from supplier with less items in stock' do
        suppliers = Product.where(product_name: request_body[:items].first[:name]).pluck(:supplier, :in_stock)
        expect(@json_response['shipments'][0]['supplier']).to eq(suppliers[0].first)
        expect(@json_response['shipments'][1]['supplier']).to eq(suppliers[1].first)
      end
    end
  end
end
