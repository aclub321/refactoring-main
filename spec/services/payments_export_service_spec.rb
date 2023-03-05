require 'rails_helper'

describe PaymentsExportService do
  # Freezes time to Time.current timestamp
  Timecop.freeze(Time.current)

  let(:agent) { create(:agent) }
  let(:contract) { create(:contract) }

  let!(:payment) do
    create(:payment, :not_ready_for_export, contract: contract)
  end

  let(:risk_carrier) { 'Company_1' }
  let(:export_type) { 'my_export_type' }

  let(:payment_export_service_obj) do
    described_class.new(agent, Time.current, risk_carrier, export_type)
  end

  subject { payment_export_service_obj.call }

  context 'when no payment ready for export' do
    it 'does not update payment exported_at timestamp' do
      subject
      expect(payment.reload.exported_at).to be_nil
    end

    it 'does not update contract last_export timestamp' do
      subject
      expect(contract.reload.last_export).to be_nil
    end

    it 'does not create CSV files' do
      expect(subject).to be_empty
    end

    it 'does not create payment_export_log' do
      subject
      expect(PaymentExportLog.all).to be_empty
    end
  end

  context 'when payments ready for export' do
    let(:payment) { create(:payment, contract: contract) }

    it 'updates payment exported_at timestamp' do
      subject
      expect(payment.reload.exported_at).to eq(Time.current)
    end

    it 'updates contract last_export timestamp' do
      subject
      expect(contract.reload.last_export).to eq(Time.current)
    end

    it 'creates a CSV file' do
      expect(subject.count).to eq(1)
    end

    it 'adds correct CSV headers' do
      subject

      csv_file_path = "tmp/#{agent.reload.payment_export_logs.first.file_name}"

      expect(File.read(csv_file_path)).to include("amount;agent_id;created_at")
    end

    it 'generates CSV files with rows 250' do
      expect(payment_export_service_obj.send(:rows_limit)).to eq(250)
    end

    it 'creates payment_export_log' do
      subject
      expect(PaymentExportLog.all)
        .to match_array(
          [
            have_attributes(
              agent_id: agent.id,
              file_name: "#{risk_carrier}_payment_#{export_type}_#{Time.current.to_i}_part1.csv",
              exported_at: Time.current
            )
          ]
        )
    end

    context 'when risk_carrier NOT Company_1' do
      let(:risk_carrier) { 'Company_2' }

      it 'adds correct CSV headers' do
        subject

        csv_file_path = "tmp/#{agent.reload.payment_export_logs.first.file_name}"

        expect(File.read(csv_file_path)).to include("amount|agent_id|created_at")
      end

      it 'generates CSV files with rows 2500' do
        expect(payment_export_service_obj.send(:rows_limit)).to eq(2500)
      end
    end
  end
end
