module ExpenseTracker
  class API < Sinatra::Base
    def initialize(ledger: Letger.new)
      @ledger = ledger
      super()
    end

    post '/expenses' do
      expense = JSON.parse(request.body.read)
      result = @ledger.record(expense)

      if result.success?
        JSON.generate('expense_id' => result.expense_id)
      else
        status 422
        JSON.generate('error' => result.error_message)
      end
    end

    get '/expenses/:date' do
      result = @ledger.expenses_on(params[:date])
      JSON.generate(result)
    end
  end
end
