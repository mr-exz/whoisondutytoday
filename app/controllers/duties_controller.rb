class DutiesController < ApplicationController
  def index
    @duties = Duty.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @duties }
      format.json { render json: @duties }
    end
  end

  def new
    dutie = Duty.new
  end

  def destroy
    Duty.find(params[:id]).destroy
    flash[:success] = "Record deleted"
    redirect_to duties_url
  end
end
