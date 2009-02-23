require File.dirname(__FILE__) + '/../../spec_helper'

describe LegacyData do
  before do
    @site = create_site
    @article = LegacyArticle.create :title => "Test Item", :updated => 10.days.ago
  end

  describe "import" do

    def act!
      @article.import
    end

    it "creates a new article at import time" do
      lambda { act! }.should change( Article, :count ).by(1)
    end

    it "calls local object" do
      fake_article =stub( 'fake_article').as_null_object 
      @article.stub!(:local_object).and_return( fake_article )
      @article.should_receive(:local_object).with(Article)
      act!
    end

    it "calls after import chain" do
      @article.should_receive :create_primary_placement
      act!
    end
  end
end
