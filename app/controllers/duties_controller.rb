class DutiesController < ApplicationController
  def index
    @duties = Duty.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render xml: @duties }
      format.json { render json: @duties }
    end
  end

  def new
    Duty.new
  end

  def destroy
    Duty.find(params[:id]).destroy
    flash[:success] = "Record deleted"
    redirect_to duties_url
  end

  def edit
    @duty = Duty.find(params[:id])
  end

  def update
    @duty = Duty.find(params[:id])
    Duty.update(
      opsgenie_escalation_name: params[:duty][:opsgenie_escalation_name],
      opsgenie_schedule_name: params[:duty][:opsgenie_schedule_name]
    )
    redirect_to duties_path(@duty)
  end
end
