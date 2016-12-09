require 'rails_helper'

RSpec.describe Mobilization, type: :model do
  it { should belong_to :user }
  it { should have_many :blocks }
  it { should have_many(:widgets).through(:blocks) }
  it { should have_many(:form_entries).through(:widgets) }
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :name }
  it { should validate_presence_of :goal }
  it { should validate_length_of :twitter_share_text }

  before { @community = Community.make! }

  context "generate a slug" do
    before do
      @mobilization = Mobilization.create!(
        name: "mobilization",
        goal: "change the world",
        user: User.make!,
        community_id: @community.id
      )
    end

    it "should include mobilization's name" do
      expect(@mobilization.slug).to include @mobilization.name.parameterize
    end
  end

  context "set Twitter's share text" do
    subject {
      Mobilization.create!(
        name: "mobilization",
        goal: "change the world",
        user: User.make!,
        community_id: @community.id
      )
    }

    it "should include mobilization's name" do
      expect(subject.twitter_share_text).to include subject.name
    end
  end

  context "create mobilization from TemplateMobilition object" do
    before do 
      @template = TemplateMobilization.make!
    end
    subject {
      Mobilization.make!.copy_from(@template)
    }

    it "should copy the color_scheme value" do
      expect(subject.color_scheme).to eq(@template.color_scheme)
    end

    it "should copy the facebook_share_title value" do
      expect(subject.facebook_share_title).to eq(@template.facebook_share_title)
    end

    it "should copy the facebook_share_description value" do
      expect(subject.facebook_share_description).to eq(@template.facebook_share_description)
    end

    it "should copy the header_font value" do
      expect(subject.header_font).to eq(@template.header_font)
    end

    it "should copy the body_font value" do
      expect(subject.body_font).to eq(@template.body_font)
    end

    it "should copy the facebook_share_image value" do
      expect(subject.facebook_share_image).to eq(@template.facebook_share_image)
    end

    it "should copy the slug value" do
      expect(subject.slug).to eq(@template.slug)
    end

    it "should copy the custom_domain value" do
      expect(subject.custom_domain).to eq(@template.custom_domain)
    end

    it "should copy the twitter_share_text value" do
      expect(subject.twitter_share_text).to eq(@template.twitter_share_text)
    end

    it "should not copy the community_id value" do
      expect(subject.community_id).to_not eq(@template.community_id)
    end
  end
end
