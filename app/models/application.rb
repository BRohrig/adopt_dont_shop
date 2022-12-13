class Application < ApplicationRecord
  validates_presence_of :name, :street_address, :city, :state, :zip_code
  has_many :pet_applications
  has_many :pets, through: :pet_applications
  has_many :shelters, through: :pets
  
  def find_app_approved(pet_id)
    app = Application.joins(:pets).where(pets: {id: pet_id }).pluck(:status)
    app.include?("Approved")
  end

  def status_update(pa_params)
    # require 'pry'; binding.pry
    if approved
      self.update!(status: "Approved")
      adopt_pets
    elsif rejected
      self.update!(status: "Rejected")
    end
  end

  def check_approved
    pet_applications.pluck(:status)
  end

  def approved
    check_approved.all? { |status| status == 'true' }
  end

  def rejected
    check_approved.include?('false') && check_approved.include?(nil) == false
  end

  def adopt_pets
    self.pets.each do |pet|
      pet.update!(adoptable: false)
    end
  end
end
