class ChannelsController < ApplicationController
  def index
    @channels = Channel.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render xml: @channels }
      format.json { render json: @channels }
    end
  end

  def destroy
    Channel.find(params[:id]).destroy
    flash[:success] = "Record deleted"
    redirect_to channels_url
  end
end
