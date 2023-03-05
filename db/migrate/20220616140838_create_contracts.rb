class CreateContracts < ActiveRecord::Migration[7.0]
  def change
    create_table :contracts do |t|
      t.datetime :last_export

      t.timestamps
    end
  end
end
