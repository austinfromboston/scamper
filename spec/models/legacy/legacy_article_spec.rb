require File.dirname(__FILE__) + '/../../spec_helper'

describe LegacyArticle do
  before do
    @site = create_site
    @article = LegacyArticle.create :title => "Test Item", :updated => 10.days.ago
  end
  def act!
    @article.import
  end

  it "does not import if an article with the same legacy id already exists" do
    existing_article = create_article :legacy_id => @article.id
    lambda { act! }.should_not change( Article, :count )
  end
  describe "attributes:" do

    describe "clean date" do
      it "clean_date does not pass along 0000 values" do
        @article.date = '0000-00-00'
        @article.clean_date.should be_nil
      end
      it "does pass along standard values" do
        @article.date = Date.new 2006, 1, 1
        @article.clean_date.should == Date.new( 2006, 1, 1 )
      end 
    end
    describe "publish" do
      it "all items are draft by default" do
        @article.publishing_status.should == "draft"
      end
      it "should be live if publish is set to 1" do
        @article.publish = 1
        @article.publishing_status.should == "live"

      end
    end
    describe "class_as_named_display" do
      it "translates fancy classes to text" do
        @article.amp_class = 10
        @article.class_as_named_display.should == "press_release"
      end
    end
  end

  describe "associations" do

    describe "primary placements" do
      it "always creates a primary placement" do
        act!
        @article.imported.pages.should_not be_empty
        @article.imported.primary_page.should_not be_nil
      end

    end

    describe "items marked frontpage" do
      before do
        Site.stub!( :first ).and_return @site
        @article.fplink = 1
      end
      it "creates a frontpage placement" do
        act!
        @article.imported.pages.should include( @site.landing_page )
      end
    end

    describe "items with a class" do
      before do
        @news_page = create_page :name => 'news', :tag => 'news'
        @article.amp_class = 3
      end
      it "placed on a class page" do
        act!
        @article.imported.pages.should include( @news_page )
      end
    end

    describe "items marked as new" do
      before do
        @latest_page = create_page :name => 'latest update', :tag => 'new'
        @article.write_attribute :new, true
      end
      it "should be placed on the new tag page" do
        act!
        @article.imported.pages.should include( @latest_page )
      end
    end
    describe "all tagged pages" do
      before do
        @cat_tag = LegacyTag.create :name => "Fat Cat"
        @cat_taggable = LegacyTagging.create :tag_id => @cat_tag.id, :item_type => 'article', :item_id => @article.id

        @mouse_tag = LegacyTag.create :name => "mink_mouse"
        @mouse_taggable = LegacyTagging.create :item_type => 'article', :item_id => @article.id, :tag_id => @mouse_tag.id

        Page.delete_all "tag = 'fat_cat' or tag='mini_mouse'"
        @cat_page = create_page :name => 'latest update', :tag => 'fat_cat'
        @mouse_page = create_page :name => 'latest update', :tag => 'mini_mouse'
      end

      it "creates tag pages when they don't exist" do
        Page.should_receive( :create ).with( hash_including( :tag => 'mink_mouse')).and_return @mouse_page
        act!
      end
      it "adds articles to existing tagged pages" do
        act!
        Page.find_all_by_tag( 'fat_cat').size.should == 1
        @article.imported.pages.should include( @cat_page )
      end
    end

    describe "add sections as tags with parents" do
      before do
        @section = LegacySection.create :type => "About Us"
        @article.type = @section.id
        Page.delete_all "legacy_id = #{@section.id}"
      end
      it "should create a page with the right tag" do
        act!
        @article.imported.pages.find_by_tag( 'about_us' ).should_not be_nil
      end

      it "should use the existing page when one has already been created" do
        section_page = Page.create :tag => 'about_us', :legacy_id => @section.id
        act!
        @article.imported.pages.should include( section_page )
      end

      describe "section headers" do
        before do
          @article.amp_class = LegacyArticle::AMP_CLASSES['section_header']
        end

        it "uses the section page as it primary page if the section page already exists" do
          section_page = Page.create :tag => 'about_us', :legacy_id => @section.id
          act!
          @article.imported.primary_page.should == section_page
        end

        it "should tag the primary page for section headers" do
          @article.amp_class = 8
          act!
          @article.imported.primary_page.tag.should == 'about_us'
        end
        it "should set page title from section headers" do
          act!
          @article.imported.primary_page.name.should == @article.title
        end
        it "should set the display type on the created section"
      end

    end
  end

    
end

