module FixtureReplacement
  attributes_for :article do |a|
    a.title = "Test item"
  end
  attributes_for :site do |a|
    a.name = "test"
    a.url = "http://example.org"
    a.landing_page = default_page
  end

  attributes_for :page do |a|
    a.name = "test"
  end

end

