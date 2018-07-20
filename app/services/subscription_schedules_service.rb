class SubscriptionSchedulesService
  def self.schedule_charges(subscription)
    if can_process?(subscription)
      if subscription.next_transaction_charge_date <= DateTime.now
        Rails.logger.info "Creating next payment for subscription -> #{subscription.id}"
        SubscriptionWorker.perform_async(subscription.id)
      end
    end
  end

  def self.can_process?(subscription)
    current_state = subscription.current_state

    (
      current_state == 'paid' || (
        subscription.current_state == 'unpaid' &&
        !subscription.reached_retry_limit? && subscription.reached_retry_interval?))
  end
end
