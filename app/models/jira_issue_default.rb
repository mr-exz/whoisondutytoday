class JiraIssueDefault < ApplicationRecord
  validates :project_key, presence: true, uniqueness: true

  def self.get_defaults(project_key)
    config = find_by(project_key: project_key)
    config&.default_fields || {}
  end

  def self.set_defaults(project_key, fields_config)
    config = find_or_create_by(project_key: project_key)
    config.update(default_fields: fields_config)
    config
  end
end
