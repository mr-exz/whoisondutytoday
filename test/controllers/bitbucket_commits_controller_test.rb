require "test_helper"

class BitbucketCommitsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get bitbucket_commits_index_url
    assert_response :success
  end
end
