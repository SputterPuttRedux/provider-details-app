require 'rails_helper'

RSpec.describe ProviderDetailsSearch do
  let(:session_id) { '35f02a449971d04e2c9c803d5ad86936' }
  let(:npid) { 1234567890 }
  
  let!(:user) { User.create(session_id: session_id) }
  let!(:provider) do 
    user.providers.create(
      npid:  npid,
      first_name: "JULIUS",
      last_name: "ERVING",
      address_1: "3601 BROAD ST",
      city: "PHILADELPHIA",
      state:  "PA",
      postal_code: "19148",
      taxonomy: "Emergency Medicine",
      enumeration_type: "NPI-1",	
    )
  end

  before do
    allow(subject).to receive(:response).and_return(response)
  end

  let(:response) do
    {
      'basic' => { 'first_name' => 'JULIUS', 'last_name' => 'IRVING' },
      'taxonomies' => [{ 'desc' => 'Emergency Medicine' }],
      'addresses' => [{ 'address_1' => '3601 BROAD ST', 'city' => 'PHILADELPHIA', 'state' => 'PA', 'postal_code' => '19148' }],
      'enumeration_type' => 'NPI-1',
    }
  end

  subject { described_class.new(npid: npid, session_id: session_id) }

  context 'when a valid npid is supplied' do
    it 'is valid' do
      expect(subject.valid?).to eq(true)
    end

    context 'and the provider has previously been persisted to the database' do   
      context 'and the user has previoiusly searched for the provider' do
        it 'updates the UserProvider model to reflect the new search' do
          expect { subject.search! }.to change { user.providers_users.first.updated_at }
        end
      end

      context 'and the user has not previously searched for the provider' do
        let!(:provider) do 
          Provider.create(
            npid:  1234567891,
            first_name: "KEITH",
            last_name: "THORNTON",
            address_1: "1001 BRONX BLVD",
            city: "NEW YORK",
            state:  "NY",
            postal_code: "10457",
            taxonomy: "Emergency Medicine",
            enumeration_type: "NPI-1",	
          )
        end

        it 'creates a search record for the user and the provider' do
          expect { subject.search! }.to change { ProviderUser.count }.by(1)
          expect(ProviderUser.where(provider_id: npid, user_id: session_id)).to exist
        end
      end
    end
      
    context 'and the provider has not been previously persisted to the database' do
        subject { described_class.new(npid: 1111111111, session_id: session_id) }

        let(:response) do
            {
                'basic' => { 'first_name' => 'JONATHAN', 'last_name' => 'STRANGE' },
                'taxonomies' => [{ 'desc' => 'Emergency Medicine' }],
                'addresses' => [{ 'address_1' => '177A BLEECKER ST', 'city' => 'NEW YORK', 'state' => 'NY', 'postal_code' => '19148' }],
                'enumeration_type' => 'NPI-1',
            }
        end

        it 'creates a new provider' do
            expect { subject.search! }.to change { Provider.count }.by(1)
        end
    end
  end

  context 'when an invalid npid is supplied' do
      subject { described_class.new(npid: 1234, session_id: session_id) }

      let(:response) { {} } 

      it 'is invalid' do
        expect(subject.valid?).to eq(false)
      end

      it 'does not update or create any record and it returns error messaging' do
          expect { subject.search! }.not_to change { Provider.count }
          expect { subject.search! }.not_to change { ProviderUser.count }

          expect(subject.errors).to be_present
      end
  end
end