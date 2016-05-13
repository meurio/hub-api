class WidgetPolicy < ApplicationPolicy
  def permitted_attributes
    if create?
      [:kind, settings: [
        :content,
        :call_to_action,
        :button_text,
        :count_text,
        :sender_name,
        :sender_email,
        :email_text,
        :email_subject,
        :action_community,

        :title_text,
        :main_color,
        :donation_value1,
        :donation_value2,
        :donation_value3,
        :donation_value4,
        :donation_value5,
        :payment_methods,
        :customer_data
        ]
      ]
    else
      []
    end
  end

  private

  def is_owned_by?(user)
    user.present? && record.mobilization.user == user
  end
end
