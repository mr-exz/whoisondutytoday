require 'minitest/autorun'
require 'fileutils'
require 'tmpdir'
require_relative '../../bot/commands/claude_prompt'

class ClaudePromptStandaloneTest < Minitest::Test
  def test_download_and_save_file_returns_unique_filename
    temp_dir = Dir.mktmpdir('claude_prompt_test')

    begin
      # Mock Slack client
      mock_client = Minitest::Mock.new
      mock_web_client = Minitest::Mock.new
      mock_client.expect(:web_client, mock_web_client)
      mock_client.expect(:web_client, mock_web_client)

      # Mock file info response
      file_response = {
        'file' => {
          'url_private' => 'https://files.slack.com/files-pri/T123/F09V5KEH1CK/image.png'
        }
      }
      mock_web_client.expect(:files_info, file_response, [], file: 'F09V5KEH1CK')
      mock_web_client.expect(:token, 'fake-token')

      # Mock file hash from Slack message
      file_hash = {
        'id' => 'F09V5KEH1CK',
        'name' => 'image.png'
      }

      # Mock Net::HTTP to avoid actual download
      mock_http_response = "fake image data"
      WhoIsOnDutyTodaySlackBotModule::Commands::ClaudePrompt.stub(:download_with_redirects, mock_http_response) do
        # Call the method
        result = WhoIsOnDutyTodaySlackBotModule::Commands::ClaudePrompt.download_and_save_file(
          mock_client,
          file_hash,
          temp_dir
        )

        # Assert the returned filename has the correct format: basename_FILEID.extension
        assert_equal 'image_F09V5KEH1CK.png', result, "Expected filename to be 'image_F09V5KEH1CK.png' but got '#{result}'"

        # Assert the file actually exists at the expected path
        expected_filepath = File.join(temp_dir, 'image_F09V5KEH1CK.png')
        assert File.exist?(expected_filepath), "File should exist at #{expected_filepath}"

        # Assert the file contains the mocked data
        assert_equal mock_http_response, File.binread(expected_filepath)
      end

      # Verify all mock expectations were met
      mock_client.verify
      mock_web_client.verify
    ensure
      # Cleanup temp directory
      FileUtils.rm_rf(temp_dir) if temp_dir && Dir.exist?(temp_dir)
    end
  end

  def test_download_and_save_file_handles_files_without_extension
    temp_dir = Dir.mktmpdir('claude_prompt_test')

    begin
      mock_client = Minitest::Mock.new
      mock_web_client = Minitest::Mock.new
      mock_client.expect(:web_client, mock_web_client)
      mock_client.expect(:web_client, mock_web_client)

      file_response = {
        'file' => {
          'url_private' => 'https://files.slack.com/files-pri/T123/F123/README'
        }
      }
      mock_web_client.expect(:files_info, file_response, [], file: 'F123')
      mock_web_client.expect(:token, 'fake-token')

      file_hash = {
        'id' => 'F123',
        'name' => 'README'
      }

      mock_http_response = "readme content"
      WhoIsOnDutyTodaySlackBotModule::Commands::ClaudePrompt.stub(:download_with_redirects, mock_http_response) do
        result = WhoIsOnDutyTodaySlackBotModule::Commands::ClaudePrompt.download_and_save_file(
          mock_client,
          file_hash,
          temp_dir
        )

        # For files without extension, format should be: filename_FILEID
        assert_equal 'README_F123', result, "Expected filename to be 'README_F123' but got '#{result}'"

        expected_filepath = File.join(temp_dir, 'README_F123')
        assert File.exist?(expected_filepath), "File should exist at #{expected_filepath}"
      end

      mock_client.verify
      mock_web_client.verify
    ensure
      FileUtils.rm_rf(temp_dir) if temp_dir && Dir.exist?(temp_dir)
    end
  end
end
