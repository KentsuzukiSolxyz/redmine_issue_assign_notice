module RedmineIssueAssignNotice
  class MessageHelper
    def self.mention_target(assgined_to, author)

      if assgined_to.nil? ||
         Setting.plugin_redmine_issue_assign_notice['mention_to_assignee'] != '1' ||
         assgined_to == author

         return nil
      end

      noteice_field = assgined_to.custom_field_values.find{ |field| field.custom_field.name == 'Assign Notice ID' }
      if noteice_field.nil? || noteice_field.value.blank?
        return nil
      end

      noteice_field.value
    end

    def self.issue_url(issue)
      "#{Setting.protocol}://#{Setting.host_name}/issues/#{issue.id}"
    end

    def self.trimming(note)
      if note.nil?
        return ''
      end

      flat = note.gsub(/\r\n|\n|\r/, ' ')
      if flat.length > 200
        flat[0, 200] + '...'
      else
        flat
      end
    end

  def self.extract_mentions(note, author)
    return ['', []] if note.blank?

    mention_entities = []

    names = note.scan(/@([A-Za-z0-9._-]+)/).flatten

    names.each do |name|
      user = User.find_by_login(name)

      next if user.nil?

      mention_id = mention_target(user, author)
      next if mention_id.blank?

      mention_text = "<at>#{user}</at>"

      note.gsub!("@#{name}", mention_text)

      mention_entities << {
        :type => "mention",
        :text => mention_text,
        :mentioned => {
          :id => mention_id,
          :name => user.to_s
        }
      }
    end

    [note, mention_entities]
  end
end