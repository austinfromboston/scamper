require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  # Structure
  table_has_columns(User,:string,"login")
  table_has_columns(User,:string,"crypted_password")
  table_has_columns(User,:string,"password_salt")
  table_has_columns(User,:string,"persistence_token")
  table_has_columns(User,:string,"perishable_token")
  table_has_columns(User,:integer,"login_count")
  table_has_columns(User,:integer,"failed_login_count")
  
end
