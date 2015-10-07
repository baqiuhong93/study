class TeachersController < ApplicationController
  
  layout "teacher"
  
  def index
    @search = Teacher.search(params[:search])
    @teachers = @search.where("deleted = ?", false).paginate(:page => params[:page], :per_page => 8).order('sortrank ASC, recommend DESC, id DESC')
  end

  def show
    @teacher = Teacher.where("code = ?", params[:id]).first
  end
end
