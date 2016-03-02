class Page < ActiveRecord::Base
  before_save :sanitize_name

  validates :name, presence: true
  validates :config, presence: true

  serialize :config

  private

  def sanitize_name
    self.name = self.name.downcase.gsub(/\W+/, '')
  end
end
