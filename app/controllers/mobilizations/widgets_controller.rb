class Mobilizations::WidgetsController < ApplicationController
  include ControllerHelper
  
  respond_to :json

  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    @widgets = policy_scope(Widget).joins(:block).where(blocks: {mobilization_id: params[:mobilization_id]}).order(:id)
    render json: @widgets
  end

  def update
    @widget = Widget.find_by({id:params[:id]})
    if @widget
      authorize @widget

      if @widget.update!(widget_params)
        SubscriptionService.create_plans(@widget) if @widget.recurring? && @widget.donation?
        render json: @widget
      else
        render json: @widget.errors, status: :unprocessable_entity
      end
    else
      render_404
    end
  end

  private

  def widget_params
    params.require(:widget).permit(*policy(@widget || Widget.new).permitted_attributes).tap do |whitelisted|
      if params[:widget][:settings] && params[:widget][:settings][:fields]
        whitelisted[:settings][:fields] = params[:widget][:settings][:fields].to_json
      end
    end
  end
end
