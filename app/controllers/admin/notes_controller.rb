# encoding: utf-8

class Admin::NotesController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource
  before_filter :init_breadcrumb_and_module_name
  layout "admin"
  
  # GET /notes
  # GET /notes.json
  def index
    @notes = Note.paginate(:page => params[:page], :per_page => GlobalSettings.per_page).order('id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @notes }
    end
  end

  # GET /notes/1
  # GET /notes/1.json
  def show
    @note = Note.find(params[:id])
    
    drop_breadcrumb(@note.id, admin_note_path(@note))
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @note }
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.json
  def destroy
    @note = Note.find(params[:id])
    @note.transaction do
      @note.account.update_attribute(:note, false) if Note.where("user_id = ? and account_id = ?", @note.user_id, @note.account_id).count == 0
      @note.destroy
    end

    respond_to do |format|
      format.html { redirect_to admin_notes_path }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def note_params
      params.require(:note).permit(:account, :content, :knowledge_tree, :product, :product_name, :product_tree)
    end
    
    def init_breadcrumb_and_module_name
      drop_breadcrumb("笔记", admin_notes_path)
      @_module_name = 'note'
      @__module_name = 'Note'
      @_module_new = false
      @_module_edit = false
    end
end
