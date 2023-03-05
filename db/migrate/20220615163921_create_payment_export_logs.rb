class CreatePaymentExportLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_export_logs do |t|
      t.integer :agent_id
      t.string :file_name
      t.datetime :exported_at

      t.timestamps
    end
  end
end
