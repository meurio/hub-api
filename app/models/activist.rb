class Activist < ActiveRecord::Base
  has_many :donations
  has_many :credit_cards, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :form_entries
  has_many :activist_pressures
  has_many :activist_matches
  has_many :activist_tags

  validates :name, :email, presence: true
  validates :name, length: { in: 3..70 }
  validates_format_of :email, with: Devise.email_regexp

  def self.by_email email
    self.where("lower(email) = lower(?)", email).order(id: :asc).first
  end

  def first_name
    name.split(' ')[0] if name
  end

  def last_name
    (name.split(' ')[1..-1]).join(' ') if name
  end

  def self.update_from_csv_content csv_content, community_id
    update_from_csv CsvReader.new(content: csv_content), community_id
  end

  def self.update_from_csv_file csv_filename, community_id
    update_from_csv CsvReader.new(file_name: csv_filename), community_id
  end

  def tag_list community_id
    activist_tag = self.activist_tags.find_by_community_id community_id
    return activist_tag.nil? ? nil : activist_tag.tag_list
  end

  def add_tag community_id, tag
    activist_tag = (self.activist_tags.find_by_community_id community_id) || (self.activist_tags.create! community_id: community_id)
    activist_tag.tag_list.add tag
    activist_tag.save
  end

  private

  def self.update_from_csv csv_reader, community_id
    list = []
    (1 .. csv_reader.max_records).each do
      activist = (Activist.find_by_email csv_reader.email) || Activist.new
      activist.name = csv_reader.try(:name) if csv_reader.try(:name)
      activist.email = csv_reader.try(:email) if csv_reader.try(:email)
      activist.phone = csv_reader.try(:phone) if csv_reader.try(:phone)
      activist.document_number = csv_reader.try(:document_number) if csv_reader.try(:document_number)
      activist.document_type = csv_reader.try(:document_type) if csv_reader.try(:document_type)
      activist.save!

      csv_reader.tags.split(';').each { |tag| activist.add_tag community_id, tag } if csv_reader.try(:tags)

      csv_reader.next_record
      list << activist
    end
    list
  end
end
