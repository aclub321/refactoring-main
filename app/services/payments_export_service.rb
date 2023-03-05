class PaymentsExportService
  require "csv"

  def initialize(agent, exported_at, risk_carrier, export_type)
    @agent = agent
    @payments = Payment.ready_for_export
    @exported_at = exported_at
    @risk_carrier = risk_carrier
    @export_type = export_type
  end

  def call
    ActiveRecord::Base.transaction do
      update_data_for_payment
      update_contract(@exported_at)

      create_csv_files
      save_export_log
    end
    @files
  end

  def update_data_for_payment
    @payments.each do |p|
      p.update(exported_at: @exported_at)
    end
  end

  def update_contract(last_export)
    @payments.each do |p|
      p.contract.update(last_export: last_export)
    end
  end

  def create_csv_files
    col_sep = @risk_carrier == "Company_1" ? ";" : "|"

    @files = csv_data(col_sep).map.with_index(1).map do |csv, i|
      File.open(save_path(i), "wb") { |f| f << csv }
    end
  end

  def save_path(part)
    Rails.root.join("tmp", csv_file_name(part))
  end

  def csv_file_name(part)
    "#{@risk_carrier}_payment_#{@export_type}_#{@exported_at.to_i}_part#{part}.csv"
  end

  def csv_data(col_sep)
    @payments.each_slice(rows_limit).map do |slice|
      CSV.generate(col_sep: col_sep) do |csv|
        csv << ["amount", "agent_id", "created_at"]
        slice.each do |payment|
          csv << generate_export_csv(payment) if !payment.processed?
        end
      end
    end
  end

  def generate_export_csv(payment)
    [payment.amount_cents, payment.agent.id, payment.created_at]
  end

  def rows_limit
    @risk_carrier == "Company_1" ? 250 : 2500
  end

  def save_export_log
    1.upto(@payments.each_slice(rows_limit).count) do |i|
      PaymentExportLog.create(
        agent_id: @agent.id,
        file_name: csv_file_name(i),
        exported_at: Time.now
      )
    end
  end
end
