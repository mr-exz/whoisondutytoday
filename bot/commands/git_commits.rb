module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class UserCommits

      DESCRIPTION = 'Will display the last 10 commits of a user.'.freeze
      EXAMPLE = '`git commits <user>` example: `git commits @user`'.freeze
      def self.call(client:, data:, match:)
        message_processor = MessageProcessor.new
        user_name = match['expression'][/<@(.+)>/, 1]
        message_processor.collectUserInfoBySlackUserId(user_name)
        user = User.where(slack_user_id: user_name).first
        return unless user

        client.web_client.chat_postMessage(
          channel: data.channel,
          text: 'Got your request. Let me check the latest commits for you.',
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )

        commits = BitbucketCommit.where('LOWER(author) = ?', user.contacts.downcase).order(date: :desc).limit(10)
        created_at = commits.first.created_at.strftime('%Y-%m-%d %H:%M:%S')

        commit_messages = commits.map { |commit|
          commit_url = generate_commit_url(commit)
          "*#{commit.date.strftime('%Y-%m-%d')}*: <#{commit_url}|#{commit.repo_slug}>"
        }.join("\n")

        client.web_client.chat_postMessage(
          channel: data.channel,
          text: "Last 10 commits by #{user.name} synced at: #{created_at}:\n#{commit_messages}",
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
      end
      def self.generate_commit_url(commit)
        "#{ENV['BITBUCKET_URL']}/projects/#{commit.project_key}/repos/#{commit.repo_slug}/commits/#{commit.commit_id}"
      end
    end
  end
end