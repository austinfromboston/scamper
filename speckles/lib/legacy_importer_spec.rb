require File.dirname(__FILE__) + '/../spec_helper'

describe LegacyImporter do
  it "calls import on each returned article" do
    # this should be a before block -- but sqlite throws a locked error 
=begin
    @leg_template = stub( 'legacy_template', :imported => create_page_layout, :id => 5 )
    @leg_intro = stub( 'legacy_introtext', :imported => create_article, :templateid => @leg_template.id )
=end

    @leg_site = stub( 'legacy_site', :imported => create_site )
    @leg_article = stub( 'legacy_article', :imported => create_article )
    @leg_site.should_receive( :import )
    @leg_article.should_receive(:import).any_number_of_times
    #LegacyIntrotext.stub!(:find).and_return(@leg_intro)
    #LegacyTemplate.stub!(:find).and_return(@leg_template)
    LegacySite.stub!(:find).and_return( @leg_site )
    LegacyArticle.stub!(:all).and_return( [ @leg_article ] )
    imp = LegacyImporter.new
    imp.do_site
    imp.do_section_headers
    #LegacyImporter.run
  end
end

