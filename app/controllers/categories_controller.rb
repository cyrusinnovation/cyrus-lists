class CategoriesController < ApplicationController
  before_filter :authenticate_user!

  def reorder_categories
    direction = params[:direction]
    category = Category.find params[:category_id]
    if direction == 'down'
      category.move_down
    else
      category.move_up
    end

    redirect_to lists_path
  end

end
