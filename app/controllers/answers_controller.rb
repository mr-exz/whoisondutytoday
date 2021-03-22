class AnswersController < ApplicationController
  def index
    @answers = Answer.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @answers }
      format.json { render json: @answers }
    end
  end
end
