# encoding: utf-8

class Admin::KnowledgeTreesController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource
  before_filter :init_breadcrumb_and_module_name
  layout "admin"
  
  # GET /admin/knowledge_trees
  # GET /admin/knowledge_trees.json
  def index
    #@knowledge_trees = KnowledgeTree.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: KnowledgeTree.select([:id, :name, :pId, :node_type]) }
    end
  end

  # GET /admin/knowledge_trees/1
  # GET /admin/knowledge_trees/1.json
  def show
    @knowledge_tree = KnowledgeTree.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @knowledge_tree }
    end
  end

  # GET /admin/knowledge_trees/new
  # GET /admin/knowledge_trees/new.json
  def new
    @knowledge_tree = KnowledgeTree.new :pId => params[:pId]

    respond_to do |format|
      format.html {render :layout => false}# new.html.erb
      format.json { render json: @knowledge_tree }
    end
  end

  # GET /admin/knowledge_trees/1/edit
  def edit
    @knowledge_tree = KnowledgeTree.find(params[:id])
    render :layout => false
  end

  # POST /admin/knowledge_trees
  # POST /admin/knowledge_trees.json
  def create
    if params[:knowledge_tree][:pId] == "0"
      @knowledge_tree = KnowledgeTree.new knowledge_tree_params
      @knowledge_tree.save
    else
      parent_knowledge_tree = KnowledgeTree.find(params[:knowledge_tree][:pId])
      @knowledge_tree = parent_knowledge_tree.children.create knowledge_tree_params
    end
    

    respond_to do |format|
      if !@knowledge_tree.nil?
        format.html { redirect_to admin_knowledge_tree_path(@knowledge_tree), notice: 'Knowledge tree was successfully created.' }
        format.json { render json: @knowledge_tree, status: :created, location: admin_knowledge_tree_path(@knowledge_tree) }
      else
        format.html { render action: "new" }
        format.json { render json: @knowledge_tree.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/knowledge_trees/1
  # PATCH/PUT /admin/knowledge_trees/1.json
  def update
    @knowledge_tree = KnowledgeTree.find(params[:id])

    respond_to do |format|
      if @knowledge_tree.update_attributes(knowledge_tree_params)
        format.html { redirect_to @knowledge_tree, notice: 'Knowledge tree was successfully updated.' }
        format.json { render json: @product_tree }
      else
        format.html { render action: "edit" }
        format.json { render json: @knowledge_tree.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/knowledge_trees/1
  # DELETE /admin/knowledge_trees/1.json
  def destroy
    @knowledge_tree = KnowledgeTree.find(params[:id])
    @knowledge_tree.destroy

    respond_to do |format|
      format.html { redirect_to admin_knowledge_trees_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def knowledge_tree_params
      params.require(:knowledge_tree).permit(:audition_path, :course_num, :description, :listen_path, :name, :order_num, :pId, :node_type, :select_level, :record)
    end
    
    def init_breadcrumb_and_module_name
      drop_breadcrumb("知识点树", admin_knowledge_trees_path)
      @_module_name = 'knowledge_tree'
      @__module_name = 'KnowledgeTree'
    end
end
