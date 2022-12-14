require 'rails_helper'

RSpec.describe Application, type: :model do
  describe 'relationships' do
    it { should have_many :pet_applications }
    it { should have_many(:pets).through(:pet_applications) }
    it { should have_many(:shelters).through(:pets) }
  end

  describe 'instance methods' do
    before :each do
      @shelter = Shelter.create!(name: 'Snoops Dogs', city: 'Compton', rank: 1, foster_program: true)

      @james = @shelter.pets.create!(adoptable: true, age: 4, breed: 'King George Spaniel', name: 'James')
      @buster = @shelter.pets.create!(adoptable: true, age: 2, breed: 'Shnauzer - Wheaton mix', name: 'Buster')
      @marlowe = @shelter.pets.create!(adoptable: true, age: 9, breed: 'Pembroke Welsh Corgi', name: 'Marlowe')

      @app1 = Application.create!(
        name: 'Frank Sinatra',
        street_address: '69 Sinatra Way',
        city: 'Nashville',
        state: 'Tennessee', zip_code: '69420', description: "I've always liked dogs",
        status: 'Pending'
      )
    end

    it 'has a method to find an approved application based on pet id' do
      PetApplication.create!(pet: @buster, application: @app1)
      @app1.update!(status: "Approved")

      expect(@app1.find_app_approved(@buster.id)).to eq(true)
    end

    it 'can determine if all pet_applications associated are approved' do
      PetApplication.create!(pet: @buster, application: @app1)
      PetApplication.create!(pet: @marlowe, application: @app1)
      PetApplication.where(pet: @buster).update(status: "true")

      expect(Application.find(@app1.id).approved).to eq(false)
      PetApplication.where(pet: @marlowe).update(status: "true")
   
      expect(Application.find(@app1.id).approved).to eq(true)
    end

    it 'can determine if all pet_applications associated have a decision, and one is rejected' do
      PetApplication.create!(pet: @buster, application: @app1)
      PetApplication.create!(pet: @marlowe, application: @app1)
      PetApplication.where(pet: @buster).update(status: "false")

      expect(Application.find(@app1.id).rejected).to eq(false)
      PetApplication.where(pet: @marlowe).update(status: "true")
   
      expect(Application.find(@app1.id).rejected).to eq(true)
    end

    it 'can update the status of the application once the pet_apps are decided' do
      PetApplication.create!(pet: @buster, application: @app1)
      PetApplication.create!(pet: @marlowe, application: @app1)
      PetApplication.where(pet: @buster).update(status: "true")

      expect(Application.find(@app1.id).approved).to eq(false)
      PetApplication.where(pet: @marlowe).update(status: "true")
      Application.find(@app1.id).status_update
      expect(Application.find(@app1.id).status).to eq("Approved")
    end

    it 'can update with rejected once pet_apps are decided' do
      PetApplication.create!(pet: @buster, application: @app1)
      PetApplication.create!(pet: @marlowe, application: @app1)
      PetApplication.where(pet: @buster).update(status: "false")

      expect(Application.find(@app1.id).rejected).to eq(false)
      PetApplication.where(pet: @marlowe).update(status: "true")

      Application.find(@app1.id).status_update
      expect(Application.find(@app1.id).status).to eq("Rejected")
    end
  end
end
