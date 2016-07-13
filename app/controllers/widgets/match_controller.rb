class Widgets::MatchController < ApplicationController
  respond_to :json
  before_action :load_widget
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def show
    @match = Match.find(params[:id])
    authorize @match
    render json: @match.as_json.merge(:widget_title => @widget.settings['title_text'])
  end

  def create
    authorize @widget, :update?
    @match = @widget.matches.new(match_params)
    @match.save!
    render json: @match
  end

  def update
    authorize @widget, :update?
    @match = @widget.matches.find(params[:id])
    @match.update_attribtues(match_params)
    render json: @match
  end

  def destroy
    authorize @widget, :update?
    ###
    # MAYBE WORKING :)
    ###
    body = JSON.parse request.body.read
    column_hash = { body['column_name'] => body['value'] }
    @widget.matches.where(column_hash).destroy_all
    # @match.destroy!
    render json: { ok: true }
  end

  private

  def match_params
    if params[:match]
      params.require(:match).permit(*policy(@match || Match.new).permitted_attributes)
    else
      {}
    end
  end

  def load_widget
    @widget ||= Widget.find(params[:widget_id])
  end
end