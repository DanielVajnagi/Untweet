class UserIndex < Chewy::Index
  index_scope User

  field :email, analyzer: "standard"
  field :username, analyzer: "standard"
  field :created_at, type: "date"
  field :updated_at, type: "date"
  field :role
  field :banned, type: "boolean"
  field :remember_created_at, type: "date"

  settings analysis: {
    analyzer: {
      standard: {
        type: "standard",
        tokenizer: "standard",
        filter: [ "lowercase", "asciifolding" ]
      }
    }
  }
end
