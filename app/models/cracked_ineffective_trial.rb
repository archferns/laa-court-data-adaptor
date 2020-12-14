# frozen_string_literal: true

# example from Common platform hearing endpoint
#
# "crackedIneffectiveTrial": {
#   "code": "A",
#   "description": "On the date of trial the defendant, for the first time, enters a guilty plea which the prosecution accepts.",
#   "id": "c4ca4238-a0b9-3382-8dcc-509a6f75849b",
#   "type": "Cracked"
# }

class CrackedIneffectiveTrial
  include ActiveModel::Model

  attr_accessor :body

  def id
    body["id"]
  end

  def code
    body["code"]
  end

  def description
    body["description"]
  end

  def type
    body["type"]
  end
end
