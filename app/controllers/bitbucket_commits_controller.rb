class BitbucketCommitsController < ApplicationController
  def index
    @commits = BitbucketCommit.order(created_at: :desc).limit(10)
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render xml: @commits }
      format.json { render json: @commits }
    end
  end
  # curl -X GET "http://127.0.0.1:3000/bitbucket_commits/user_commits?author=user@example.com&year=2023&quarter=1"
  def user_commits
    if params[:year].present? && params[:quarter].present?
      start_date = Date.new(params[:year].to_i, (params[:quarter].to_i - 1) * 3 + 1, 1)
      end_date = start_date.end_of_quarter
      @commits = BitbucketCommit.where(author: params[:author], date: start_date..end_date).order(date: :desc)
    else
      @commits = BitbucketCommit.where(author: params[:author]).order(date: :desc)
    end

    respond_to do |format|
      format.json { render json: @commits }
    end
  end
end
