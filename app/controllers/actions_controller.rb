class ActionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    @actions = Action.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @actions }
      format.json { render json: @actions }
    end
  end

  def create
    action = Action.new(problem: params["problem"], action: params["aktion"], channel: params["channel"])
    action.save
  end

  def destroy
    Action.find(params[:id]).destroy
    flash[:success] = "Record deleted"
    redirect_to actions_url
  end
end
