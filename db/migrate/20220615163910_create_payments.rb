class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.integer :amount_cents
      t.integer :contract_id
      t.integer :agent_id
      t.boolean :new
      t.boolean :verified
      t.boolean :cancelled
      t.boolean :processed
      t.datetime :exported_at

      t.timestamps
    end
  end
end
