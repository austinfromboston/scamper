require File.dirname(__FILE__) + '/../spec_helper'

describe LegacyImporter do
  it "calls import on each returned article" do
    @leg = stub( 'legacy_model' ).as_null_object
    @leg.should_receive( :import ).any_number_of_times
    LegacySite.stub!(:find).and_return( @leg )
    LegacyArticle.stub!(:all).and_return( [ @leg ] )
    LegacyImporter.run
  end
end

