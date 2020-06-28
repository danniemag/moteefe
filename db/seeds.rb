# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

products = [
    {
        product_name: 'black_mug',
        supplier: 'Shirts4U',
        delivery_times: { "eu": 1, "us": 6, "uk": 2 },
        in_stock: 3
    },
    {
        product_name: 'blue_t-shirt',
        supplier: 'Best Tshirts',
        delivery_times: { "eu": 1, "us": 5, "uk": 2 },
        in_stock: 10
    },
    {
        product_name: 'white_mug',
        supplier: 'Shirts Unlimited',
        delivery_times: { "eu": 1, "us": 8, "uk": 2 },
        in_stock: 3
    },
    {
        product_name: 'black_mug',
        supplier: 'Shirts Unlimited',
        delivery_times: { "eu": 1, "us": 7, "uk": 2 },
        in_stock: 4
    },
    {
        product_name: 'pink_t-shirt',
        supplier: 'Shirts4U',
        delivery_times: { "eu": 1, "us": 6, "uk": 2 },
        in_stock: 8
    },
    {
        product_name: 'pink_t-shirt',
        supplier: 'Best Tshirts',
        delivery_times: { "eu": 1, "us": 3, "uk": 2 },
        in_stock: 2
    }
]

products.each do |product_attributes|
  Product.create(product_attributes)
end
