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
    end

    @files
  end

  private

  def update_data_for_payment
    @payments.in_batches.update_all(exported_at: @exported_at)
  end

  def update_contract(last_export)
    Contract.where(payments: @payments)
            .in_batches
            .update_all(last_export: last_export)
  end

  def create_csv_files
    @files = []

    col_sep = @risk_carrier == "Company_1" ? ";" : "|"

    @payments.includes(:agent).in_batches(of: rows_limit).map.with_index(1) do |slice, i|
      csv_data = generate_csv_data(col_sep, slice)

      @files << File.open(save_path(i), "wb") { |f| f << csv_data }

      save_export_log(i)
    end

    @files
  end

  def save_path(part)
    Rails.root.join("tmp", csv_file_name(part))
  end

  def csv_file_name(part)
    "#{@risk_carrier}_payment_#{@export_type}_#{@exported_at.to_i}_part#{part}.csv"
  end

  def generate_csv_data(col_sep, slice)
    CSV.generate(col_sep: col_sep) do |csv|
      csv << ["amount", "agent_id", "created_at"]
      slice.unprocessed.each do |payment|
        csv << generate_export_csv(payment)
      end
    end
  end

  def generate_export_csv(payment)
    [payment.amount_cents, payment.agent.id, payment.created_at]
  end

  def rows_limit
    @risk_carrier == "Company_1" ? 250 : 2500
  end

  def save_export_log(part)
    PaymentExportLog.create(
      agent_id: @agent.id,
      file_name: csv_file_name(part),
      exported_at: Time.now
    )
  end
end
