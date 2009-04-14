Background:
  Given an empty database at "tmp/xapiandatabase"

Scenario: Query Matching No Records
  Given indexed records named "John, Jane"
  When I query for "Sam"
  Then I should find 0 records

Scenario: Query Matching One Record
  Given indexed records named "John, Jane"
  When I query for "John"
  Then I should find record named "John"

Scenario: Query Matching Two Records
  Given indexed records named "John Smith, Jane Smith, John Smithsonian"
  When I query for "Smith"
  Then I should find records named "John Smith, Jane Smith"

Scenario: Query Field Matching
  Given the following indexed records
    | name | age |
    | John | 23  |
    | Jane | 17  |
    | Jack | 17  |
  When I query "age" matching "17"
  Then I should find records named "Jane, Jack"

Scenario: Query for Page 1
  Given 3 indexed records
  When I query page 1 at 2 per page
  Then I should find 2 records

Scenario: Query for Page 2
  Given 3 indexed records
  When I query page 2 at 2 per page
  Then I should find 1 record
  And I should have 3 records total

Scenario: Query for One Facet
  Given the following indexed records
    | name | age |
    | John | 23  |
    | Jane | 17  |
    | Jack | 17  |
  When I query facets "0c93ee1"
  Then I should find records named "Jane, Jack"


Scenario: Query for Two Facets
  Given the following indexed records
    | name | age |
    | John | 23  |
    | Jane | 17  |
    | Jack | 17  |
  When I query facets "0c93ee1-078661c"
  Then I should find records named "Jane"

Scenario: Query for All Records Class Agnostic
  Given indexed records named "John, Jane"
  When I query for "John" on Xapit
  Then I should find 1 record

Scenario: Query Matching Or Query
  Given indexed records named "John, Jane, Jacob"
  When I query for "Jane or John"
  Then I should find records named "John, Jane"

Scenario: Query Matching Not Query
  Given indexed records named "John Smith, John Johnson"
  When I query for "John not Smith"
  Then I should find records named "John Johnson"

Scenario: Query for Facets with Keywords
  Given the following indexed records
    | name | age |
    | John | 23  |
    | Jane | 17  |
    | Jack | 17  |
  When I query "Jane" with facets "0c93ee1"
  Then I should find record named "Jane"

Scenario: Query for Facets with Keywords
  Given indexed records named "Zebra, Apple, Banana"
  When I query "" sorted by "name"
  Then I should find records named "Apple, Banana, Zebra"
