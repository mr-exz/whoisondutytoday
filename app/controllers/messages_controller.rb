class MessagesController < ApplicationController
  def index
    @messages = Message.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render xml: @duties }
      format.json { render json: @duties }
    end
  end
end
