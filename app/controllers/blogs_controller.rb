# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]
  before_action :correct_user, only: %i[edit update destroy]
  before_action :secret_blog, only: %i[show]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    attributes = %i[title content secret random_eyecatch]
    attributes.delete(:random_eyecatch) unless current_user.premium
    params.require(:blog).permit(*attributes)
  end

  def raise_error
    raise ActiveRecord::RecordNotFound
  end

  def correct_user
    user = Blog.find(params[:id]).user
    raise_error unless current_user == user
  end

  def secret_blog
    raise_error if @blog.secret && !(user_signed_in? && @blog.user == current_user)
  end
end
