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
    existing_article = create_article :legacy_id => @article.id, :legacy_type => 'article'
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
        Page.destroy_all ["tag = ?", 'new' ]
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
        @section = LegacySection.create :type => "About Us", :parent => LegacySection::AMP_ROOT
        @article.type = @section.id
        Page.delete_all "legacy_id = #{@section.id}"
      end
      it "should create a page with the right tag" do
        act!
        @article.imported.pages.find_by_tag( 'about_us' ).should_not be_nil
      end

      it "should use the existing page when one has already been created" do
        section_page = Page.create :tag => 'about_us', :legacy_id => @section.id, :legacy_type => 'section'
        act!
        @article.imported.pages.should include( section_page )
      end

      describe "section headers" do
        before do
          @article.amp_class = LegacyArticle::AMP_CLASSES['section_header']
        end

        it "uses the section page as it primary page if the section page already exists" do
          section_page = Page.create :tag => 'about_us', :legacy_id => @section.id, :legacy_type => 'section'
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
        describe "section parents" do
          before do
            @parent_section = LegacySection.create :type => "stuff", :parent => LegacySection::AMP_ROOT
            @parent_import = @parent_section.import
            @section = LegacySection.create :type => "About Us", :parent => @parent_section.id
            @article.type = @section.id
            Page.delete_all "legacy_id = #{@section.id}"
          end

          it "sets the parent on the created section based on the legacy parent" do
            act!
            #@article.imported.primary_page.parent_pages.should include(@parent_import)
            @article.imported.primary_page.parent_page.should == @parent_import
          end
        end
        describe "trashed sections" do
          before do
            @section.update_attribute :parent, LegacySection::AMP_TRASH 
          end
          it "raises an error" do
            lambda { act! }.should raise_error( LegacyData::TrashedItemImport )
          end
          it "do not import" do
            begin
              act!
            rescue LegacyData::TrashedItemImport
              @article.kill_tree
            end
            Page.find_by_legacy_id( @section.id ).should be_nil
          end
        end
        describe "orphaned sections" do
          before do
            @nonexistent_id = 30
            LegacySection.delete_all( "id  = #{@nonexistent_id}" )
            @section = LegacySection.create :type => "About Us", :parent => @nonexistent_id
            @article.type = @section.id
            #Page.delete_all "legacy_id = #{@section.id}"
          end
          it "raise an OrphanItemImport error" do
            lambda { act! }.should raise_error( LegacyData::OrphanItemImport )
            #LegacyArticle.find( @article.id ).should_raise (ActiveRecord::RecordNotFound )
            #LegacySection.find( @section.id ).should_raise (ActiveRecord::RecordNotFound )
          end
          it "kills the orphan parent" do
            begin
              act! 
            rescue LegacyData::OrphanItemImport
              @article.kill_tree
            end
            Article.find_by_legacy_id( @article.id ).should be_nil
            Page.find_by_legacy_id( @section.id ).should be_nil
          end
          it "kills the orphan great-grandparent" do
            section_gg = LegacySection.create :type => "great-grandparent", :parent => @nonexistent_id
            section_g = LegacySection.create :type => "grandparent", :parent => section_gg.id
            @section.update_attribute :parent, section_g.id

            begin
              act! 
            rescue LegacyData::OrphanItemImport
              @article.kill_tree
            end

            Article.find_by_legacy_id( @article.id ).should be_nil
            Page.find_by_legacy_id( @section.id ).should be_nil
            Page.find_by_legacy_id( section_g.id ).should be_nil
            Page.find_by_legacy_id( section_gg.id ).should be_nil
=begin
            @article.should_receive(:imported).exactly(3).times.
              and_return( 
                         stub( "imported_article", 
                              :delete => true, 
                              :delete_all => true, 
                              :primary_page => stub( "pp", :delete => true )))
=end

          end
              
        end
        
      end


    end
  end

    
end

