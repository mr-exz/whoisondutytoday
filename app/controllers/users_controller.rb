class UsersController < ApplicationController
  def index
    @users = User.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @duties }
      format.json { render json: @duties }
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "Record deleted"
    redirect_to users_url
  end
end
