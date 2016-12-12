require 'rails_helper'

RSpec.describe CommunitiesController, type: :controller do
  before do 
    @user = User.make!

    stub_current_user(@user)
  end

  describe "GET #index" do
    it "should return all organizations" do
      communities = []
      3.times { Community.make! }
      2.times { communities << Community.make! }
      communities.each do  |community|
        CommunityUser.create user: @user, community: community, role: 1
      end
      get :index
      expect(response.body).to include(communities.to_json)
    end
  end

  describe 'POST #create' do
    context 'valid call' do
      before do
        @count = Community.count
        post :create, {
          format: :json, 
          community: {
            name: 'José Marculino Silva',
            city: 'Pindamonhangaba, SP'
          }
        }
      end

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end

      it 'should have one more register on disk' do
        expect(Community.count).to be (@count + 1)
      end

      it 'should return the data saved' do
        expect(response.body).to include(Community.last.to_json)
      end
    end

    context 'user not logged' do 
      before do
        stub_current_user(nil)
        @count = Community.count
        post :create, {
          format: :json, 
          community: {
            name: 'José Joselito',
            city: 'Taubaté, SP'
          }
        }
      end

      it 'should return a 401 status' do
        expect(response.status).to be 401
      end
    end


    context 'Fields missing' do 
      before do
        post :create, {
          format: :json, 
          community: {
            cidate: 'Taubaté, SP'
          }
        }
      end

      it 'should return a 400 status' do
        expect(response.status).to be 400
      end

      it 'should return error messaage' do
        expect(response.body).to be
      end
    end
  end





  describe 'PUT #update' do
    before do
      @community = Community.make!
    end

    it 'should return 404 if community not exists' do
      put :update, {
        format: :json, 
        id: 0,
        community: {
          city: 'Tremembé, SP'
        }
      }

      expect(response.status).to be 404
    end
    
    context 'user not logged' do 
      before do
        stub_current_user(nil)

        put :update, {
          format: :json, 
          id: @community.id,
          community: {
            name: 'José Joselito',
            city: 'Taubaté, SP'
          }
        }
      end

      it 'should return a 401 status' do
        expect(response.status).to be 401
      end
    end

    context 'valid call' do
      before do
        (CommunityUser.new user: @user, community: @community, role: 1).save!

        @count = Community.count
        put :update, {
          format: :json, 
          id: @community.id,
          community: {
            city: 'Tremembé, SP'
          }
        }
      end

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end

      it 'should return the data saved' do
        expect(response.body).to include((Community.find @community.id).to_json)
      end

      it 'should change the data' do
        saved = Community.find @community.id

        expect(saved.city).to eq 'Tremembé, SP'
      end
    end
  end



  describe 'GET #show' do
    let(:community) { Community.make! }

    context 'user with rights' do
      before do
        CommunityUser.create user: @user, community: community, role: 1
    
        get :show, {id: community.id}
      end

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end

      it 'should return the expected data' do
        expect(response.body).to include(community.to_json)
      end
    end

    context 'user with rights' do
      it 'should return a 401 status' do
        stub_current_user(User.make!)
        CommunityUser.create user: @user, community: community, role: 1
        get :show, {id: community.id}

        expect(response.status).to be 401
      end
    end

    context 'user with rights' do
      it 'should return a 404 status' do
        get :show, {id: 0}

        expect(response.status).to be 404
      end
    end
  end


  describe 'GET #list_mobilizations' do
    let(:community) {Community.make!}
    let(:user2) {User.make!}


    before do
      CommunityUser.create! user: @user, community: community, role: 3

      @mob1 = Mobilization.make! user: @user, custom_domain: "foobar", slug: "1.1-foo", community: community
      @mob2 = Mobilization.make! user: user2, community: community
      @mob3 = Mobilization.make! user: @user, custom_domain: "foobar2", slug: "1.2-foo", community: community
      @mob4 = Mobilization.make! user: @user, custom_domain: "foobar", slug: "2-foo"
      @mob5 = Mobilization.make! user: user2
    end

    context "inexistent community" do
      before do
        get :list_mobilizations, {community_id: 0}    
      end

      it 'should return a 404 status' do
        expect(response.status).to be 404
      end
    end

    context "valid call" do
      context 'no filters' do
        before do
          get :list_mobilizations, {community_id: community.id}
        end

        it 'should return a 200 status' do
          expect(response.status).to be 200
        end

        it "should return all mobilizations related to the community" do
          expect(response.body).to include(@mob1.name)
          expect(response.body).to include(@mob2.name)
          expect(response.body).to include(@mob3.name)
          expect(response.body).not_to include(@mob4.name)
          expect(response.body).not_to include(@mob5.name)
        end
      end

      context 'mobilizations by custom_domain' do
        before do
          get :list_mobilizations, {custom_domain: "foobar", community_id: community.id}
        end

        it 'should return a 200 status' do
          expect(response.status).to be 200
        end

        it "should return all mobilizations related to the community" do
          expect(response.body).to include(@mob1.name)
          expect(response.body).not_to include(@mob2.name)
          expect(response.body).not_to include(@mob3.name)
          expect(response.body).not_to include(@mob4.name)
          expect(response.body).not_to include(@mob5.name)
        end
      end

      context 'mobilizations by slug' do
        before do
          get :list_mobilizations, {slug: "1.1-foo", community_id: community.id}
        end

        it 'should return a 200 status' do
          expect(response.status).to be 200
        end

        it "should return all mobilizations related to the community" do
          expect(response.body).to include(@mob1.name)
          expect(response.body).not_to include(@mob2.name)
          expect(response.body).not_to include(@mob3.name)
          expect(response.body).not_to include(@mob4.name)
          expect(response.body).not_to include(@mob5.name)
        end
      end

      context 'mobilizations by id' do
        before do
          get :list_mobilizations, {ids: [@mob3.id], community_id: community.id}
        end

        it 'should return a 200 status' do
          expect(response.status).to be 200
        end

        it "should return all mobilizations related to the community" do
          expect(response.body).to include(@mob3.name)
          expect(response.body).not_to include(@mob1.name)
          expect(response.body).not_to include(@mob2.name)
          expect(response.body).not_to include(@mob4.name)
          expect(response.body).not_to include(@mob5.name)
        end
      end
    end
  end
end
