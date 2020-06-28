class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :product_name
      t.string :supplier
      t.json :delivery_times
      t.integer :in_stock

      t.timestamps
    end
  end
end
