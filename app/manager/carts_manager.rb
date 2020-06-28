module CartsManager
  def self.delivery_information(params)
    @region = params[:shipping_region]

    items = group_items_by_supplier(fetch_basket_items(params[:items]))
    shipments = serialize_items(items)

    [order_delivery_date(shipments), shipments]
  end

  def fetch_basket_items(basket_items)
    items_information = []

    basket_items.each do |item|
      remain_amount = item[:count].to_i
      products = fetch_product(item[:name])
      next if remain_amount > products.sum(:in_stock)

      products.each do |prd|
        amount = remain_amount > prd.in_stock ? prd.in_stock : remain_amount
        remain_amount -= amount

        items_information << { name: prd.product_name, count: amount, supplier: prd.supplier,
                               days_to_deliver: prd.delivery_times[@region] }
        break if remain_amount.zero?
      end
    end
    items_information
  end
  module_function :fetch_basket_items

  def group_items_by_supplier(items)
    items.group_by { |d| d[:supplier] }
  end
  module_function :group_items_by_supplier

  def serialize_items(items)
    shipments = []

    items.each do |item|
      spm = { supplier: item.first,
              delivery_date: Date.today + (item.last.min_by { |h| h[:days_to_deliver] }[:days_to_deliver]).days,
              items: [] }

      item.last.each { |i| spm[:items] << { title: i[:name], count: i[:count] } }
      shipments << spm
    end
    shipments
  end
  module_function :serialize_items

  def fetch_product(item_name)
    Product
        .where(product_name: item_name)
        .order("(delivery_times ->> '#{@region}')::integer")
  end
  module_function :fetch_product

  def order_delivery_date(shipments)
    shipments.max_by { |h| h[:delivery_date] }[:delivery_date]
  end
  module_function :order_delivery_date
end
