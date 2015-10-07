# encoding: utf-8

class Admin::ProductTreeGroupsController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource
  before_filter :init_breadcrumb_and_module_name
  layout "admin"
  
  # GET /product_tree_groups
  # GET /product_tree_groups.json
  def index

    respond_to do |format|
      format.html {
        @search = ProductTreeGroup.search(params[:search])
        @product_tree_groups = @search.paginate(:page => params[:page], :per_page => GlobalSettings.per_page).order('id DESC')
      }
      format.json { 
        render json: ProductTreeGroup.select("id, name as text").to_json
      }
    end
  end

  # GET /product_tree_groups/1
  # GET /product_tree_groups/1.json
  def show
    @product_tree_group = ProductTreeGroup.find(params[:id])
    
    node_knowledge_tree_data = eval(@product_tree_group.node_knowledge_tree_data.gsub(":","=>"))
    
    knowledge_tree_ids = []
    node_knowledge_tree_data.each do |key,value|
    	knowledge_tree_ids = knowledge_tree_ids | value
    end
    @knowledge_trees = KnowledgeTree.select("id, name, pId").where("id in (?)",knowledge_tree_ids)
    
    drop_breadcrumb(@product_tree_group.name, admin_product_tree_group_path(@product_tree_group))
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product_tree_group }
    end
  end

  # GET /product_tree_groups/new
  # GET /product_tree_groups/new.json
  def new
    @product_tree_group = ProductTreeGroup.new
    
    drop_breadcrumb('新增')
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product_tree_group }
    end
  end

  # GET /product_tree_groups/1/edit
  def edit
    @product_tree_group = ProductTreeGroup.find(params[:id])
    
    drop_breadcrumb(@product_tree_group.name, admin_product_tree_group_path(@product_tree_group))
    drop_breadcrumb('修改')
  end

  # POST /product_tree_groups
  # POST /product_tree_groups.json
  def create
    @product_tree_group = ProductTreeGroup.new product_tree_group_params

    respond_to do |format|
      if @product_tree_group.save
        format.html { redirect_to admin_product_tree_group_path(@product_tree_group), notice: '产品新建成功.' }
        format.json { render json: @product_tree_group, status: :created, location: @product_tree_group }
      else
        format.html { render action: "new" }
        format.json { render json: @product_tree_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /product_tree_groups/1
  # PUT /product_tree_groups/1.json
  def update
    @product_tree_group = ProductTreeGroup.find(params[:id])

    respond_to do |format|
      if @product_tree_group.update_attributes product_tree_group_params
        format.html { redirect_to admin_product_tree_group_path(@product_tree_group), notice: '产品修改成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product_tree_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_tree_groups/1
  # DELETE /product_tree_groups/1.json
  def destroy
    @product_tree_group = ProductTreeGroup.find(params[:id])
    @product_tree_group.destroy

    respond_to do |format|
      format.html { redirect_to admin_product_tree_groups_path }
      format.json { head :no_content }
    end
  end
  
  def drag_drop
    @product_tree_group = ProductTreeGroup.find(params[:id])
    
    update_flag = @product_tree_group.update_attributes :product_tree_data => params[:product_tree_data] unless params[:product_tree_data].nil?
    update_flag1 = @product_tree_group.update_attributes :node_knowledge_tree_data => params[:node_knowledge_tree_data] unless params[:node_knowledge_tree_data].nil?
    respond_to do |format|
      if update_flag || update_flag1
        format.html { redirect_to admin_product_tree_group_path(@product_tree_group), notice: '产品修改成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product_tree_group.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
  def product_tree_group_params
    params.require(:product_tree_group).permit(:name, :product_tree_data, :node_knowledge_tree_data)
  end
  
  def init_breadcrumb_and_module_name
    drop_breadcrumb("课程包", admin_product_tree_groups_path)
    @_module_name = 'product_tree_group'
    @__module_name = 'ProductTreeGroup'
  end
end
