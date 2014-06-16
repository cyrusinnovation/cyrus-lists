class ListsController < ApplicationController
  before_filter :authenticate_user_and_save_current_url!
  before_filter :only => [:add_current_user, :add_subscribers, :remove_subscriber] do
    user_can_modify_list? current_user, params[:list_id]
  end

  def index
    @categories = Category.order('position')
    @user = current_user
  end

  def new
    @list = List.new
    render :layout => false
  end

  def edit
    @list = List.find(params[:id])
    @user = current_user
    render :layout => false
  end

  def create
    params[:list][:category] = Category.find_or_create_by(name: params[:list][:category])

    list = List.new(params[:list])
    list.subscribers << current_user.subscriber
    list.created_by = current_user
    puts list.inspect
    if list.save
      redirect_to List, get_flash_message(list)
    else
      puts 'hey that save totally failed'
      redirect_to List, get_flash_message(list)
    end
  end

  def destroy
    list = List.find(params[:id])
    category = list.category
    list.destroy
    category.destroy if category.lists.empty?

    redirect_to lists_url
  end

  def add_current_user
    list = List.find(params[:list_id])
    list.add_subscriber current_user.subscriber
    render :nothing => true if request.xhr?
    redirect_to List, notice: "You have been added to the #{list.name} list." unless request.xhr?
  end

  def remove_current_user
    list = List.find(params[:list_id])
    list.subscribers.delete current_user.subscriber
    render :nothing => true
  end

  def add_subscribers
    list = List.find(params[:list_id])

    list.append_emails(text_box_to_array(params[:subscribers]))
    redirect_to lists_url
  end

  def remove_subscriber
    redirect_to lists_url
    subscribers = Subscriber.where(id: params[:subscriber_id])
    return if subscribers.empty?
    list = List.find(params[:list_id])
    subscribers.each {|subscriber| list.unsubscribe(subscriber) }
  end

  def change_category
    list = List.find(params[:list_id])
    old_category = list.category
    new_category = Category.find_or_create_by(name: params[:category])
    list.category = new_category
    list.save
    old_category.destroy if old_category.lists.empty?
    redirect_to List, get_flash_message(list)
  end

  def change_description
    list = List.find(params[:list_id])
    list.description = params[:description]
    list.save
    redirect_to List, get_flash_message(list)
  end

  private

  def text_box_to_array text_box_string
    text_box_string.gsub("\r", '').split(/[;,\n]\n?/)
  end

  def get_flash_message list
    if list.errors.empty?
      {notice:  'List was successfully updated.'}
    else
      {alert: "There was a problem.  #{list.errors.full_messages.join ', '}."}
    end

  end

end
