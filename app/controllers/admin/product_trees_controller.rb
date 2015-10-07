# encoding: utf-8

class Admin::ProductTreesController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource
  before_filter :init_breadcrumb_and_module_name
  layout "admin"
  
  # GET /admin/product_trees
  # GET /admin/product_trees.json
  def index
    #@product_trees = ProductTree.paginate(:page => params[:page], :per_page => 10).order('id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: ProductTree.select([:id, :name, :pId, :node_type]) }
    end
  end

  # GET /admin/product_trees/1
  # GET /admin/product_trees/1.json
  def show
    @product_tree = ProductTree.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product_tree }
    end
  end

  # GET /admin/product_trees/new
  # GET /admin/product_trees/new.json
  def new
    @parent_product_tree = ProductTree.find(params[:pId]) if params[:pId].to_i > 0
    @product_tree = ProductTree.new :pId => params[:pId]
    
    respond_to do |format|
      format.html { render :layout => false } # new.html.erb
      format.json { render json: @product_tree }
    end
  end

  # GET /admin/product_trees/1/edit
  def edit
    @product_tree = ProductTree.find(params[:id])
    render :layout => false
  end

  # POST /admin/product_trees
  # POST /admin/product_trees.json
  def create
    if params[:product_tree][:pId] == "0"
      @product_tree = ProductTree.new product_tree_params
      @product_tree.save
    else
      parent_product_tree = ProductTree.find(params[:product_tree][:pId])
      product_tree_params = params[:product_tree]
      @product_tree = parent_product_tree.children.create product_tree_params
    end

    respond_to do |format|
      if !@product_tree.nil?
        
        speaker_teachers = params[:product_teachers_json]
        eval(speaker_teachers.gsub(":","=>")).each do |speaker_teacher|
          @product_tree.speaker_teachers.create!(:teacher_id => speaker_teacher["id"], :teacher_name => speaker_teacher["text"])
        end
        
        jy_global_assets = params[:jy_global_assets_json]
        eval(jy_global_assets.gsub(":","=>")).each do |global_asset|
          ga = GlobalAsset.find(global_asset["id"])
          if !ga.nil? && ga.assetable_id.nil?
            ga.update_attributes({:assetable_id => @product_tree.id, :assetable_type => "ProductTree"})
          end
        end
        
        format.html { redirect_to admin_product_tree_path(@product_tree), notice: '课程树创建成功.' }
        format.json { render json: @product_tree, status: :created, location: admin_product_tree_path(@product_tree) }
      else
        format.html { render action: "new" }
        format.json { render json: @product_tree.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/product_trees/1
  # PATCH/PUT /admin/product_trees/1.json
  def update
    @product_tree = ProductTree.find(params[:id])
      if @product_tree.update_attributes(product_tree_params)
        
        @product_tree.speaker_teachers.destroy_all
        speaker_teachers = params[:product_teachers_json]
        eval(speaker_teachers.gsub(":","=>")).each do |speaker_teacher|
          @product_tree.speaker_teachers.create!(:teacher_id => speaker_teacher["id"], :teacher_name => speaker_teacher["text"])
        end
        
        jy_global_assets = params[:jy_global_assets_json]
        eval(jy_global_assets.gsub(":","=>")).each do |global_asset|
          ga = GlobalAsset.find(global_asset["id"])
          if !ga.nil? && ga.assetable_id.nil?
            ga.update_attributes({:assetable_id => @product_tree.id, :assetable_type => "ProductTree"})
          end
        end
        
        render json: @product_tree
      else
        format.html { render action: "edit" }
        format.json { render json: @product_tree.errors, status: :unprocessable_entity }
      end
  end

  # DELETE /admin/product_trees/1
  # DELETE /admin/product_trees/1.json
  def destroy
    @product_tree = ProductTree.find(params[:id])
    @product_tree.destroy if @product_tree.is_childless?

    respond_to do |format|
      format.html { redirect_to product_trees_url }
      format.json { head :no_content }
    end
  end
  
  
  def destroy_global_asset
    @global_asset = GlobalAsset.find(params[:global_asset_id])
    @global_asset.update_attributes({:assetable_id => nil, :assetable_type => nil})
    render :json => {"status" => "success"}
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def product_tree_params
      params.require(:product_tree).permit(:audition_path, :description, :name, :order_num, :pId, :node_type, :select_level, :record)
    end
    
    def init_breadcrumb_and_module_name
      drop_breadcrumb("课程树", admin_product_trees_path)
      @_module_name = 'product_tree'
      @__module_name = 'ProductTree'
    end
end