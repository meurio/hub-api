# coding: utf-8
class Mobilizations::DonationsController < ApplicationController
  respond_to :json

  after_action :verify_authorized
  after_action :verify_policy_scoped, only: %i[index]

  def index
    @donations = policy_scope(Donation)
      .by_community(params[:community_id])
      .by_widget(params[:widget_id])

    authorize @donations

    respond_with do |format|
      format.json { render json: @donations }
      format.text { render text: @donations.to_txt, :type => 'text/csv', :disposition => 'inline', layout: false }
    end
  end

  def create
    @donation = Donation.new(donation_params)
    @donation.checkout_data = donation_params[:customer]
    @donation.cached_community_id = @donation.try(:mobilization).try(:community_id)

    activist_params = donation_params[:customer]
    address_params = activist_params.delete(:address)
    find_or_create_activist(activist_params)

    authorize @donation

    if @donation.save!
      address = find_or_create_address(address_params)

      DonationService.run(@donation, address)# unless @donation.subscription?
      #SubscriptionService.run(@donation, address) if @donation.subscription?

      render json: @donation
    else
      render json: @donation.errors, status: :unprocessable_entity
    end
  end

  private

  def find_or_create_activist(activist_params)
    if activist = Activist.by_email(activist_params[:email])
      @donation.activist_id = activist.id
      unless activist.document_number.present?
        activist.update_column(:document_number, @donation.checkout_data['document_number'])
      end
    else
      @donation.create_activist(activist_params.permit(*policy(Activist.new).permitted_attributes))
      Raven.capture_message "Ativista não gravado !\nDonation: #{@donation.to_json}\nParametros: #{params.to_json}\nActivist: #{activist_params}" unless @donation.try(:activist)||@donation.try(:activist_id)
    end
  end

  def find_or_create_address(address_params)
    pr = address_params.permit(*policy(Address.new).permitted_attributes)
    @donation.activist.addresses.find_by(pr) || @donation.activist.addresses.create(pr)
  end

  def donation_params
    params.require(:donation).permit(*policy(@donation || Donation.new).permitted_attributes).tap do |whitelisted|
      customer_params = params[:donation][:customer]
      if customer_params
        whitelisted[:customer] = customer_params
      end
    end
  end
end
