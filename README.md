# MTF-Challenge

A Ruby on Rails API REST application to test some scenarios and, who knows, grant me an opportunity to work with 
these guys! :)

_____________________
### Setting up environment

  * Clone this project
  * Setup project `rake db:setup`
  * Start server `rails s`

Now you can perform requests to endpoints on base url [`localhost:3000`](http://localhost:3000).

### Database
```sh
product_name,	supplier,		delivery_times,			in_stock
black_mug,      Shirts4U,		'{ "eu": 1, "us": 6, "uk": 2}',	3
blue_t-shirt,	Best Tshirts,           '{ "eu": 1, "us": 5, "uk": 2}',	10
white_mug,      Shirts Unlimited,	'{ "eu": 1, "us": 8, "uk": 2}',	3
black_mug,      Shirts Unlimited,	'{ "eu": 1, "us": 7, "uk": 2}',	4
pink_t-shirt,	Shirts4U,		'{ "eu": 1, "us": 6, "uk": 2}',	8
pink_t-shirt,	Best Tshirts,		'{ "eu": 1, "us": 3, "uk": 2}',	2
```
____________________________

### Available Endpoints

| HTTP METHOD| PATH   | USAGE |
| -----------| ------ | ------|
|   GET      | /api/v1/carts  | Returns a message indicating base url is working                                         |
|   POST     | /api/v1/carts  | Returns information on shipments and items

### HTTP Statuses
- 200 OK: The request has succeeded
- 400 Bad Request: The request could not be understood by the server 
_________________

# Endpoints

## GET /api/v1/carts

##### Required body parameters:
```json
{
  "shipping_region": "string - An alpha-2 country code (2 digits)",
  "items": [ 
    {
      "name": "string - some_product",
      "count": "integer - a positive number"
    }
  ]
}
```

##### How to test:
```sh
curl -H "Content-Type: application/json" -X GET http://localhost:3000/api/v1/carts
```

##### Success Response:
```json
{ "success": true, "message": "Yay! Route is working." }
```
___

## POST /api/v1/carts

##### How to test:
```sh
curl -H "Content-Type: application/json" -X POST -d '{
                                                         "shipping_region":"us",
                                                         "items": [
                                                             {
                                                                 "name": "black_mug",
                                                                 "count": 4
                                                             },
                                                             {
                                                                 "name": "pink_t-shirt",
                                                                 "count": 3
                                                             },
                                                             {
                                                                 "name": "white_mug",
                                                                 "count": 1
                                                             }
                                                         ]
                                                     }' http://localhost:3000/api/v1/carts
```
##### Success response:
```json
{
    "delivery_date": "2020-07-05",
    "shipments": [
        {
            "supplier": "Shirts4U",
            "delivery_date": "2020-07-04",
            "items": [
                {
                    "title": "black_mug",
                    "count": 3
                },
                {
                    "title": "pink_t-shirt",
                    "count": 1
                }
            ]
        },
        {
            "supplier": "Shirts Unlimited",
            "delivery_date": "2020-07-05",
            "items": [
                {
                    "title": "black_mug",
                    "count": 1
                },
                {
                    "title": "white_mug",
                    "count": 1
                }
            ]
        },
        {
            "supplier": "Best Tshirts",
            "delivery_date": "2020-07-01",
            "items": [
                {
                    "title": "pink_t-shirt",
                    "count": 2
                }
            ]
        }
    ]
}
```
___

### ERROR RESPONSES

#### Undeliverable Shipping Region

###### - Test by posting a shipping region other than the deliverable ones (eu us uk)
```sh
curl -H "Content-Type: application/json" -X POST -d '{"shipping_region":"br","items": [{"name":"white_mug","count":1}]}' http://localhost:3000/api/v1/carts
```

###### Response:
```json
{"success":false,"message":"Cannot send to this region"}
```
---

#### Missing Shipping Region

###### - Test by posting a request without a shipping region
```sh
curl -H "Content-Type: application/json" -X POST -d '{"items": [{"name":"white_mug","count":1}]}' http://localhost:3000/api/v1/carts
```

###### Response:
```json
{"success":false,"message":"Shipping Region not found"}
```
---

#### Missing items

###### - Test by posting a basket list without any items
```sh
curl -H "Content-Type: application/json" -X POST -d '{"shipping_region":"eu","items": []}' http://localhost:3000/api/v1/carts

or

curl -H "Content-Type: application/json" -X POST -d '{"shipping_region":"eu"}' http://localhost:3000/api/v1/carts
```

###### Response:
```json
{"success":false,"message":"No items in your basket. Shop now"}
```
---

#### Zeroed item(s)

###### - Test by posting one or more items with zeroed count
```sh
curl -H "Content-Type: application/json" -X POST -d '{"shipping_region":"uk","items": [{"name":"white_mug","count":1}, {"name":"black_mug","count":0}]}' http://localhost:3000/api/v1/carts
```

###### Response:
```json
{"success":false,"message":"An item amount in your basket is zeroed"}
```
---

#### EXTRA SCENARIO: Items which basket amount surpass in stock amount are ignored

###### - Test by posting one or more items with high quantity (compared to sample database)
```sh
curl -H "Content-Type: application/json" -X POST -d '{"shipping_region":"uk","items": [{"name":"white_mug","count":2}, {"name":"black_mug","count":10}]}' http://localhost:3000/api/v1/carts
```

###### Response:
```json
{
    "delivery_date": "2020-06-30",
    "shipments": [
        {
            "supplier": "Shirts Unlimited",
            "delivery_date": "2020-06-30",
            "items": [
                {
                    "title": "white_mug",
                    "count": 2
                }
            ]
        }
    ]
}
```


## SHAME WALL

- Although I'm used to work with FactoryBot, today it decided not to cooperate. Bad bot! Bad bot!
