require 'factory_girl'


FactoryGirl.define do

  sequence :email do |n|
    "person#{n}@#{Settings.organization_domain}"
  end

  sequence :name do |ln|
    "some_name#{ln}"
  end

  sequence :position do |p|
    p
  end

  factory :user do
    name 'Test User'
    email
    password 'please'
    subscriber
  end

  factory :list do
    name
    description 'Test description'
    category
    association :created_by, :factory => :user

    factory :list_with_one_subscriber do
      after(:create) do |list, evaluator|
        list.subscribers << create(:subscriber)
      end
    end
  end

  factory :subscriber do
    email
  end

  factory :category do
    name
    position 5
  end

  factory :subscription do
    list
    subscriber
  end
end
