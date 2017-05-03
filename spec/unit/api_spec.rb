RecordResult = Struct.new(:success?, :expense_id, :error_message)

RSpec.describe ExpenseTracker::API do
  let(:ledger) { instance_double('ExpenseTracker::Ledger')}
  let(:app) { ExpenseTracker::API.new(ledger: ledger) }

  describe 'POST /expenses' do
    context 'when the expense is successfully recorded' do
      let(:expense) { { 'some' => 'data' } }
      before do
        allow(ledger).to receive(:record)
          .with(expense)
          .and_return(RecordResult.new(true, 417, nil))
      end

      it 'returns the expense id' do
        post '/expenses', JSON.generate(expense)
        parsed = JSON.parse(last_response.body)
        expect(parsed).to include('expense_id' => 417)
      end

      it 'responds with a 200 (OK)' do
        post '/expenses', JSON.generate(expense)
        expect(last_response.status).to eq(200)
      end
    end

    context 'when the expense fails validation' do
      let(:expense) { { 'some' => 'data' } }

      before do
        allow(ledger).to receive(:record)
          .with(expense)
          .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
      end

      it 'returns an error message' do
        post '/expenses', JSON.generate(expense)

        parsed = JSON.parse(last_response.body)
        expect(parsed).to include('error' => 'Expense incomplete')
      end

      it 'responds with a 422 (Unprocessable entity)' do
        post '/expenses', JSON.generate(expense)
        expect(last_response.status).to eq(422)
      end
    end
  end

  describe 'GET /expenses/:date' do
    context 'when expenses exist on the given date' do
      before do
        allow(ledger).to receive(:expenses_on)
          .with('2017-06-10')
          .and_return(['expense1', 'expense2'])
      end

      it 'returns the expense data as JSON' do
        get '/expenses/2017-06-10'

        parsed = JSON.parse(last_response.body)
        expect(parsed).to eq(['expense1', 'expense2'])
      end

      it 'responds with a 200 (OK)' do
        get '/expenses/2017-06-10'

        expect(last_response.status).to eq(200)
      end
    end

    context 'when there are no expenses on the given date' do
      before do
        allow(ledger).to receive(:expenses_on)
          .with('2017-05-10')
          .and_return([])
      end

      it 'returns an empty array JSON' do
        get '/expenses/2017-05-10'

        parsed = JSON.parse(last_response.body)
        expect(parsed).to eq([])
      end

      it 'responds with a 200 (OK)' do
        get '/expenses/2017-05-10'

        expect(last_response.status).to eq(200)
      end
    end
  end
end
