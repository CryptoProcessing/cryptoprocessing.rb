require 'cryptoprocessing/api/api_client'

RSpec.describe Cryptoprocessing::APIClient do
  # let(:host) {'http://13.80.23.30'}
  let(:api_uri) {'https://api.cryptoprocessing.io:443'}
  let(:email) {Faker::Internet.email}
  let(:password) {Faker::Internet.password}
  let(:blockchain_type) {Cryptoprocessing::DEFAULT_BLOCKCHAIN_TYPE}
  let(:account_id) {'da96b0e9-2b15-4147-b7fd-c3351ebb00b3'}
  let(:address) {'mzGjb7kn5ZHFHxe3HsZzpyutmQDngYj7J8'}
  let(:token) {'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE1MTcxOTE0MjEsInN1YiI6ImNiY2EyMTI2LTM4MjMtNDdhNi05NzNmLWUyZDI2NjdlMzhiMSJ9.lBQ3mIKRDJqonsJvPebfSUw-FcluqFI1Hm9aVqYenTM'}
  let(:client) {Cryptoprocessing::APIClient.new({api_url: api_uri, access_token: token})}

  it 'should be able to register' do
    stub_request(:post, "#{api_uri}/auth/register")
        .with(body: {
            "email": email,
            "password": password
        }.to_json)
        .to_return(:status => 200, body: {
            "auth_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE1MTcxOTE0MjEsInN1YiI6ImNiY2EyMTI2LTM4MjMtNDdhNi05NzNmLWUyZDI2NjdlMzhiMSJ9.lBQ3mIKRDJqonsJvPebfSUw-FcluqFI1Hm9aVqYenTM",
            "message": "Successfully logged in.",
            "status": "success",
            "user_id": "cbca2126-3823-47a6-973f-e2d2667e38b1"
        }.to_json)
    expect {client.register({email: email, password: password})}.to_not raise_error
  end

  it 'should be able to login' do
    stub_request(:post, "#{api_uri}/auth/login")
        .with(body: {
            "email": email,
            "password": password
        }.to_json)
        .to_return(:status => 200, body: {
            "auth_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE1MTcxOTE0MjEsInN1YiI6ImNiY2EyMTI2LTM4MjMtNDdhNi05NzNmLWUyZDI2NjdlMzhiMSJ9.lBQ3mIKRDJqonsJvPebfSUw-FcluqFI1Hm9aVqYenTM",
            "message": "Successfully logged in.",
            "status": "success",
            "user_id": "cbca2126-3823-47a6-973f-e2d2667e38b1"
        }.to_json)
    expect {client.login({email: email, password: password})}.to_not raise_error
  end

  it 'should be able to create account' do
    stub_request(:post, "#{api_uri}/v1/accounts")
        .with(body: {currency: blockchain_type, name: 'My Test Wallet'})
        .to_return(body: {
            "account_id": "da96b0e9-2b15-4147-b7fd-c3351ebb00b3",
            "name": "My Test Wallet",
            "status": "success"
        }.to_json)
    expect {client.create_account({currency: blockchain_type, name: 'My Test Wallet'})}.to_not raise_error
  end

  it 'should be able to get account info' do
    stub_request(:get, "#{api_uri}/v1/#{blockchain_type}/accounts/#{account_id}")
        .to_return(body: {
            "data": {
                "balance": {
                    "amount": 0,
                    "total_received": 0,
                    "total_sent": 0
                },
                "id": account_id,
                "type": "btc",
                "usd_balance": {
                    "amount": 0,
                    "total_received": 0,
                    "total_sent": 0
                }
            },
            "status": "success"
        }.to_json)
    expect {client.account(account_id)}.to_not raise_error
  end

  it 'should be able to create address' do
    stub_request(:post, "#{api_uri}/v1/#{blockchain_type}/accounts/#{account_id}")
        .with(body: {
            "name": "Good Address"
        }.to_json)
        .to_return(body: {
            "address": "mzGjb7kn5ZHFHxe3HsZzpyutmQDngYj7J8",
            "id": "68aefc07-b40f-4203-8a69-a3e471773f8e",
            "name": "good address",
            "status": "success"
        }.to_json)
    expect {client.create_address(account_id, {name: 'good address'})}.to_not raise_error
  end

  it 'should be able to get list of addresses' do
    stub_request(:get, "#{api_uri}/v1/#{blockchain_type}/accounts/#{account_id}").to_return(body: {
        "addresses": [
            {
                "address": "mzGjb7kn5ZHFHxe3HsZzpyutmQDngYj7J8",
                "final_balance": 0,
                "id": "68aefc07-b40f-4203-8a69-a3e471773f8e",
                "n_tx": 0,
                "name": "good address",
                "total_received": 0,
                "total_sent": 0,
                "txs": []
            }
        ],
        "status": "success"
    }.to_json)
    expect {client.addresses('cbca2126-3823-47a6-973f-e2d2667e38b1')}.to_not raise_error
  end

  it 'should be able to get address info' do
    stub_request(:get, "#{api_uri}/v1/#{blockchain_type}/accounts/#{account_id}").to_return(body: {
        "address": "mzGjb7kn5ZHFHxe3HsZzpyutmQDngYj7J8",
        "final_balance": 0,
        "id": "68aefc07-b40f-4203-8a69-a3e471773f8e",
        "n_tx": 0,
        "name": "good address",
        "status": "success",
        "total_received": 0,
        "total_sent": 0,
        "txs": []
    }.to_json)
    expect {client.address(account_id, address)}.to_not raise_error
  end

  it 'should be able to get list of transactions' do
    stub_request(:get, "#{api_uri}/v1/#{blockchain_type}/accounts/#{account_id}").to_return(body: {
        "status": "success",
        "transactions": []
    }.to_json)
    expect {client.transactions('cbca2126-3823-47a6-973f-e2d2667e38b1')}.to_not raise_error
  end

  it 'should be able to get list of transactions by address' do
    stub_request(:get, "#{api_uri}/v1/#{blockchain_type}/accounts/#{account_id}/transactions/address/#{address}").to_return(body: [].to_json)
    expect {client.address_transactions(account_id, address)}.to_not raise_error
  end

  it 'should be able to send raw transaction' do
    stub_request(:post, "#{api_uri}/v1/#{blockchain_type}/accounts/#{account_id}")
        .with(body: {
            "type": "sendraw",
            "raw_transaction_id": "01000000011da9283b4ddf8d89eb996988b89ead56cecdc44041ab38bf787f1206cd90b51e000000006a47304402200ebea9f630f3ee35fa467ffc234592c79538ecd6eb1c9199eb23c4a16a0485a20220172ecaf6975902584987d295b8dddf8f46ec32ca19122510e22405ba52d1f13201210256d16d76a49e6c8e2edc1c265d600ec1a64a45153d45c29a2fd0228c24c3a524ffffffff01405dc600000000001976a9140dfc8bafc8419853b34d5e072ad37d1a5159f58488ac00000000",
            "description": "подписанная транзакция"
        })
        .to_return(body: {
            "message": "RetryError[<Future at 0x7f3b476a8400 state=finished raised Exception>]",
            "status": "fail"
        }.to_json)
    expect {client.create_transaction('cbca2126-3823-47a6-973f-e2d2667e38b1')}.to_not raise_error
  end

  it 'should be able to create transaction' do
    stub_request(:post, "#{api_uri}/v1/#{blockchain_type}/accounts/#{account_id}")
        .with(body: {
            "from_": [
                address
            ],
            "fee": "fastestFee",
            "description": "First",
            "type": "send",
            "to_": [
                {
                    "amount": "100",
                    "address": "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB"
                }
            ],
            "idem": "12df1s2d12q121ge5rg4e4g81v"
        })
        .to_return(body: {
            "message": "The requested amount exceeds the balance",
            "status": "fail"
        }.to_json)
    expect {client.create_transaction('cbca2126-3823-47a6-973f-e2d2667e38b1')}.to_not raise_error
  end
end

RSpec.describe Cryptoprocessing::Api::Client do
  it 'has a version number' do
    expect(Cryptoprocessing::Api::Client::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
