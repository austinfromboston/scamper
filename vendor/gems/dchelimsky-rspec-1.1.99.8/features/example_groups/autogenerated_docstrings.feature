Feature: autogenerated docstrings

  As an RSpec user
  I want examples to generate their own names
  So that I can reduce duplication between example names and example code

  Scenario: run passing examples with ruby
    Given the file ../../examples/passing/autogenerated_docstrings_example.rb

    When I run it with the ruby interpreter -fs

    Then the stdout should match /should equal 5/
    And the stdout should match /should be < 5/
    And the stdout should match /should include "a"/
    And the stdout should match /should respond to #size/

  Scenario: run failing examples with ruby
    Given the file ../../examples/failing/failing_autogenerated_docstrings_example.rb

    When I run it with the ruby interpreter -fs

    Then the stdout should match /should equal 2/
    And the stdout should match /should be > 5/
    And the stdout should match /should include "b"/
    And the stdout should match /should not respond to #size/

  Scenario: run passing examples with spec
    Given the file ../../examples/passing/autogenerated_docstrings_example.rb

    When I run it with the spec command -fs

    Then the stdout should match /should equal 5/
    And the stdout should match /should be < 5/
    And the stdout should match /should include "a"/
    And the stdout should match /should respond to #size/

  Scenario: run failing examples with spec
    Given the file ../../examples/failing/failing_autogenerated_docstrings_example.rb

    When I run it with the spec command -fs

    Then the stdout should match /should equal 2/
    And the stdout should match /should be > 5/
    And the stdout should match /should include "b"/
    And the stdout should match /should not respond to #size/
