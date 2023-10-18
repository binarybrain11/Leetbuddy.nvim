local curl = require("plenary.curl")
local sep = require("plenary.path").path.sep
local config = require("leetbuddy.config")
local headers = require("leetbuddy.headers")
local utils = require("leetbuddy.utils")
local split = require("leetbuddy.split")
local questions = require("leetbuddy.questions")

local M = {}

local function get_daily_question()
  local graphql_endpoint = config.graphql_endpoint

  local query = [[
    query questionOfToday {
       activeDailyCodingChallengeQuestion {
  ]] .. (config.domain == "cn" and [[
          question {
            paidOnly
            titleCn
            frontendQuestionId
  ]] or [[
          question {
            paidOnly: isPaidOnly
            titleCn: title
            frontendQuestionId: questionFrontendId
  ]]) .. [[
             difficulty
             isFavor
             status
             titleSlug
          }
       }}
  ]]

  local response =
    curl.post(graphql_endpoint, { headers = headers, body = vim.json.encode({ query = query, variables = {} }) })

  local data = vim.json.decode(response["body"])["data"]["activeDailyCodingChallengeQuestion"]
  return (data ~= vim.NIL and data["question"] or {})
end

function M.daily_question()
   local question = get_daily_question()
   local question_entry = questions.question_entry(question)
   questions.setup_problem(question_entry)
end

return M
