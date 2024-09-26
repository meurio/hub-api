class DnsHostedZonesController < ApplicationController
  before_action :set_community
  before_action :set_dns_hosted_zone, except: [:index, :create]

  # GET /dns_hosted_zones
  # GET /dns_hosted_zones.json
  def index
    authorize @community
    skip_policy_scope

    render json: ([])
  end

  # GET /dns_hosted_zones/1
  # GET /dns_hosted_zones/1.json
  def show
    authorize @dns_hosted_zone
    skip_policy_scope
    render json: @dns_hosted_zone
  end

  # POST /dns_hosted_zones
  # POST /dns_hosted_zones.json
  def create
    authorize @community
    skip_policy_scope

    @dns_hosted_zone = DnsHostedZone.new(dns_hosted_zone_params)
    @dns_hosted_zone.community = @community
    @dns_hosted_zone.validate

    if @dns_hosted_zone.save
      render json: @dns_hosted_zone
    else
      render json: @dns_hosted_zone.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /dns_hosted_zones/1
  # PATCH/PUT /dns_hosted_zones/1.json
  def update
    authorize @dns_hosted_zone
    skip_policy_scope
    if @dns_hosted_zone.update(dns_hosted_zone_params)
      render json: @dns_hosted_zone
    else
      render json: @dns_hosted_zone.errors, status: :unprocessable_entity
    end
  end

  # DELETE /dns_hosted_zones/1
  # DELETE /dns_hosted_zones/1.json
  def destroy
    authorize @dns_hosted_zone
    skip_policy_scope
    
    @dns_hosted_zone.destroy

    head :no_content
  end

  # GET /dns_hosted_zones/1/check
  # GET /dns_hosted_zones/1/check.json
  def check

    authorize @dns_hosted_zone

    skip_policy_scope
    
    @dns_hosted_zone.check_ns_correctly_filled!
    @dns_hosted_zone.reload

    render json: @dns_hosted_zone
  end

  private

    def set_community
      @community = Community.find(params[:community_id])
    end

    def set_dns_hosted_zone
      @dns_hosted_zone = DnsHostedZone.find(params[:id]||params[:dns_hosted_zone_id])
    end

    def dns_hosted_zone_params
      if params[:dns_hosted_zone]
        params.require(:dns_hosted_zone).permit(*policy(@dns_hosted_zone || DnsHostedZone.new).permitted_attributes)
      else
        {}
      end
    end
end
