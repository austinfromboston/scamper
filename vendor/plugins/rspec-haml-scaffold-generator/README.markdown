RSpec Haml Scaffold Generator
=============================

This is an uber version of the RSpec Scaffold Generator, the following things have been added:

Support for Haml instead of erb
Nested routes (nested tests/migrations)

Examples:

- `./script generate rspec_haml_scaffold post` # no attributes, view will be anemic
- `./script generate rspec_haml_scaffold post attribute:string attribute:boolean` 

Diabolists Additions & Removals
===============================

Made README markdown and added this section
Removed view specs - IMO views should be tested by features

Unobtrusive Destroy Method
--------------------------

Instead of using rails standard destroy, I have a confirmation form that the user will drop into. To get this to work you need to add a section to your `routes.rb`

[See this blog article](http://www.david-mcnally.co.uk/2008/11/04/the-missing-named-route/)

Here is the code in question

    class ActionController::Resources::Resource
      protected
        def add_default_actions
          add_default_action(member_methods, :get, :edit)
          add_default_action(member_methods, :get, :destroy)
          add_default_action(new_methods, :get, :new)
        end
    end

The generator does not add this code and expects you will implement a one step javascript destroy at a later date.

JC Additions
===============================
The controllers now use the make_resourceful plugin
The model specs include tests to test the table structure.  In order to get these specs to work, add the following to spec/spec_helper.rb
    def table_has_columns(clazz, type, *column_names)
      column_names.each do |column_name|
        column = clazz.columns.select {|c| c.name == column_name.to_s}.first
        it "has a #{type} named #{column_name}" do
          column.should_not be_nil
          column.type.should == type.to_sym
        end
      end
    end
    
The controller specs require the following in /spec/spec_helper.rb
    def route_matches(path, method, params)
      it "maps #{params.inspect} to #{path.inspect}" do
        route_for(params).should == {:path => path, :method => method}
      end
    
      it "generates params #{params.inspect} from #{method.to_s.upcase} to #{path.inspect}" do
        params_from(method.to_sym, path).should == params
      end
    end