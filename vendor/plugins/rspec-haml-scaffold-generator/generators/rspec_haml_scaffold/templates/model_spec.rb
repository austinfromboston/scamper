require File.dirname(__FILE__) + '/../spec_helper'

describe <%= singular_name.capitalize %> do

  # Structure
  <% for attribute in attributes -%>
table_has_columns(<%= singular_name.capitalize %>,:<%= attribute.type %>,"<%= attribute.name %>")
  <% end -%>

end
