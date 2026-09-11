module RedmineIssueAssignNotice
  module MessageCreatorComment

    def from(url)
      return AdaptiveCardCreatorComment.new
    end

    module_function :from
    
    class AdaptiveCardCreatorComment
      def initialize()
        @formatter = Formatter::Teams.new
      end
  
      def create(issue, note, author)

        note, mention_entities =
          MessageHelper.extract_mentions(note, author)

        {
          :type => "message",
          :attachments => [
            {
              :contentType => "application/vnd.microsoft.card.adaptive",
              :content => {
                :type => "AdaptiveCard",
                :body => [
                  {
                    :type => "TextBlock",
                    :text => issue.project.to_s,
                    :weight => "Bolder",
                    :size => "Medium"
                  },
                  {
                    :type => "TextBlock",
                    :text => @formatter.link(
                      "#{issue.tracker} ##{issue.id} #{@formatter.escape(issue.subject)}",
                      MessageHelper.issue_url(issue)
                    ),
                    :wrap => true
                  },
                  {
                    :type => "TextBlock",
                    :text => "【コメント・#{author.name}】",
                    :weight => "Bolder",
                    :wrap => true
                  },
                  {
                    :type => "TextBlock",
                    :text => note.to_s,
                    :wrap => true
                  }
                ],
                :$schema => "http://adaptivecards.io/schemas/adaptive-card.json",
                :version => "1.0",
                :msteams => {
                  :width => "Full",
                  :entities => mention_entities
                }
              }
            }
          ]
        }
      end
    end
  end
end