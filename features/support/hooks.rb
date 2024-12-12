Before('@JP') do
  puts "Stubbing @JP scenario"
  WebMock.stub_request(:get, /ip-api\.com\/json\/.*/)
         .to_return(
           status: 200,
           body: { countryCode: 'JP' }.to_json,
           headers: { 'Content-Type' => 'application/json' }
         )

  WebMock.stub_request(:get, /data\.fixer\.io\/api\/latest.*/)
         .to_return(
           status: 200,
           body: {
             success: true,
             rates: {
               'USD' => 1.0,
               'JPY' => 110.0
             }
           }.to_json,
           headers: { 'Content-Type' => 'application/json' }
         )
end

Before('@US') do
  puts "Stubbing @US scenario"
  WebMock.stub_request(:get, /ip-api\.com\/json\/.*/)
         .to_return(
           status: 200,
           body: { countryCode: 'US' }.to_json,
           headers: { 'Content-Type' => 'application/json' }
         )

  WebMock.stub_request(:get, /data\.fixer\.io\/api\/latest.*/)
         .to_return(
           status: 200,
           body: {
             success: true,
             rates: {
               'USD' => 1.0,
               'EUR' => 0.85
             }
           }.to_json,
           headers: { 'Content-Type' => 'application/json' }
         )
end

Before('@Unknown') do
  puts "Stubbing @Unknown scenario"
  WebMock.stub_request(:get, "http://ip-api.com/json/127.0.0.1")
         .to_return(
           status: 200,
           body: { countryCode: nil }.to_json,
           headers: { 'Content-Type' => 'application/json' }
         )

  WebMock.stub_request(:get, /data\.fixer\.io\/api\/latest.*/)
         .to_return(
           status: 200,
           body: {
             success: true,
             rates: {
               'USD' => 1.0
             }
           }.to_json,
           headers: { 'Content-Type' => 'application/json' }
         )
end
