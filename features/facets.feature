Background:
  Given an empty database at "tmp/xapiandatabase"

Scenario: List All Facets
  Given the following indexed records
    | name | age |
    | John | 23  |
    | John | 17  |
    | Jack | 17  |
  When I query for ""
  Then I should have the following facets
    | facet | option | count |
    | Name  | Jack   | 1     |
    | Name  | John   | 2     |
    | Age   | 17     | 2     |
    | Age   | 23     | 1     |

Scenario: List Matching Facets
  Given the following indexed records
    | name | age |
    | John | 23  |
    | John | 17  |
    | Jack | 17  |
  When I query for "John"
  Then I should have the following facets
    | facet | option | count |
    | Age   | 17     | 1     |
    | Age   | 23     | 1     |


Scenario: List Applied Facets
  Given the following indexed records
    | name | age |
    | John | 23  |
    | Jane | 17  |
    | Jack | 17  |
  When I query facets "0c93ee1-078661c"
  Then I should have the following applied facets
    | facet | option |
    | Age   | 17     |
    | Name  | Jane   |
