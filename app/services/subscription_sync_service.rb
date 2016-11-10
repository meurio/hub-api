require 'pagarme'

class SubscriptionSyncService
  # class method
  def self.sync(subscription_id)
    self.new(subscription_id).sync
  end

  def initialize(subscription_id)
    @subscription = PagarMe::Subscription.find_by_id(subscription_id)
    @parent_donation = Donation.unscoped.find @subscription.metadata['donation_id']
  end

  def sync
    # TODO: thie unless, fixes weird missing transaction_id and status on donation
    unless @parent_donation.transaction_id.present?
      first_d = @subscription.transactions.last
      @parent_donation.update_attributes(
        transaction_id: first_d.try(:id),
        transaction_status: first_d.try(:status)
      )
    end

    @subscription.transactions.each do |transaction|
      payables = transaction.payables
      donation = Donation.unscoped.find_by_transaction_id(transaction.id)

      if donation.present?
        donation.update_attributes(
          payables: payables.to_json,
          transaction_status: transaction.status,
          gateway_data: transaction.to_json
        )
      else
        create_donation
      end

      sleep 0.5
    end
  end

  private

    def create_donation
      Donation.create(
        transaction_id: transaction.id,
        amount: @parent_donation.amount,
        activist_id: @parent_donation.activist_id,
        transaction_status: transaction.status,
        widget_id: @parent_donation.widget_id,
        subscription_id: @subscription.id,
        subscription: true,
        skip: true,
        period: @parent_donation.period,
        plan_id: @parent_donation.plan_id,
        email: @parent_donation.email,
        payment_method: @parent_donation.payment_method,
        parent_id: @parent_donation.id,
        created_at: transaction.date_created,
        gateway_data: transaction.to_json,
        payables: payables.to_json
      )
    end
end
