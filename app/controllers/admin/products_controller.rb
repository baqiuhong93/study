# encoding: utf-8

class Admin::ProductsController < ApplicationController
  before_filter :login_required
  authorize_resource :class => false
  before_filter :init_breadcrumb_and_module_name
  layout "admin"
  
  # GET /products
  # GET /products.json
  def index
    @search = Product.search(params[:search])
    @products = @search.paginate(:page => params[:page], :per_page => GlobalSettings.per_page).where("deleted = ?", false).order('id DESC')
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: Product.select("id, name as text") }
    end
  end
  
  def test
    #课程树计算
    @product_tree_array = [];
    ids = []
    product_tree_data = eval(@product.tree_data.gsub(':','=>'))
    product_trees = ProductTree.all :conditions => ["id in (?)", product_tree_data.keys] unless product_tree_data.nil?
    
    product_trees.each do |product_tree|
      if product_tree.isNode?
        if !ids.include?(product_tree.id)
          ids.push(product_tree.id);
          @product_tree_array.push({:id => product_tree.id, :pId => product_tree.pId, :name => product_tree.name})
        end
        
        select_level = product_tree.select_level
        if select_level > 1
          ancestors = product_tree.ancestors
          if !ancestors.nil?
            len = ancestors.length
            
            for i in 1..select_level-1
              if len > i
                p1 = ancestors[len-i]
                if !ids.include?(p1.id)
                  ids.push(p1.id);
                  @product_tree_array.push({:id => p1.id, :pId => p1.pId, :name => p1.name})
                end
                
              end
            end
          end
        end
      else
       
          descendants = product_tree.descendants
          descendants.each do |descendant|
            if descendant.isNode?
              if !ids.include?(descendant.id)
                ids.push(descendant.id);
                @product_tree_array.push({:id => descendant.id, :pId => descendant.pId, :name => descendant.name})
              end
              select_level = descendant.select_level
              if select_level > 1
                ancestors = descendant.ancestors
                if !ancestors.nil?
                  len = ancestors.length
            
                  for i in 1..select_level-1
                    if len > i
                      p1 = ancestors[len-i]
                      if !ids.include?(p1.id)
                        ids.push(p1.id);
                        @product_tree_array.push({:id => p1.id, :pId => p1.pId, :name => p1.name})
                      end
                
                    end
                  end
                end
              end
            end
          end unless descendants.nil?
          
      end
    end unless product_trees.nil?
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @product = Product.find(params[:id])
    
    
    drop_breadcrumb(@product.name, admin_product_path(@product))
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product }
    end
  end

  # GET /products/new
  # GET /products/new.json
  def new
    @product = Product.new :onlined_at => DateTime.now
    
    @product_text = @product.build_product_text
    drop_breadcrumb('新增')
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product }
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
      
    drop_breadcrumb(@product.name, admin_product_path(@product))
    drop_breadcrumb('修改')
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new product_params
    upload_hash = FileUploadUtil.uploadImage(params[:product][:img_path],"product")
    
    if upload_hash[:status] == 'error'
      respond_to do |format|
        flash[:notice] = upload_hash[:msg]
        format.html { render action: "new" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
      return
    end
    @product.img_path = upload_hash[:file_name] if upload_hash.include?(:status) && upload_hash[:status] == 'success'
    #@product.build_product_text.content = params[:product][:product_text_attributes][:content]
    respond_to do |format|
      if @product.save!
        speaker_teachers = params[:product][:speaker_teachers]
        eval(speaker_teachers.gsub(":","=>")).each do |speaker_teacher|
          @product.speaker_teachers.create!(:teacher_id => speaker_teacher["id"], :teacher_name => speaker_teacher["text"])
        end unless speaker_teachers.empty?
        
        product_classworks = params[:product][:product_classworks]
        eval(product_classworks.gsub(":","=>")).each do |classwork|
          @product.product_classworks.create!(:classwork_id => classwork["id"], :classwork_name => classwork["text"])
        end unless product_classworks.empty?
        
        format.html { redirect_to admin_product_path(@product), notice: '产品新建成功.' }
        format.json { render json: @product, status: :created, location: @product }
      else
        format.html { render action: "new" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.json
  def update
    @product = Product.find(params[:id])
    upload_hash = FileUploadUtil.uploadImage(params[:product][:img_path], "product", @product.img_path)
    if upload_hash[:status] == 'error'
      respond_to do |format|
        flash[:notice] = upload_hash[:msg]
        format.html { render action: "new" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
      return
    end
    @product.update_attribute(:img_path, upload_hash[:file_name]) if upload_hash.include?(:status) && upload_hash[:status] == 'success'
    respond_to do |format|
      if @product.update_attributes params.require(:product).permit(:name, :code, :keywords, :description, :origin_price, :sale_price, :product_type, :effect_type, :effect_str, :onlined_at, :created_at, :expired_at, :tag_list, :tree_group_data, :exam_type_id, :type_id, :skxx_id, :sale, :mobile_description, :available, :exam_level_id, :sortrank, :product_text_attributes => [:id, :content])
        #@product.product_text.update_attribute(:content, params[:product][:product_text_attributes][:content])
        @product.speaker_teachers.destroy_all
        speaker_teachers = params[:product][:speaker_teachers]
        eval(speaker_teachers.gsub(":","=>")).each do |speaker_teacher|
          @product.speaker_teachers.create!(:teacher_id => speaker_teacher["id"], :teacher_name => speaker_teacher["text"])
        end unless speaker_teachers.empty?
        
        @product.product_classworks.destroy_all
        product_classworks = params[:product][:product_classworks]
        eval(product_classworks.gsub(":","=>")).each do |classwork|
          @product.product_classworks.create!(:classwork_id => classwork["id"], :classwork_name => classwork["text"])
        end unless product_classworks.empty?
        
        format.html { redirect_to admin_product_path(@product), notice: '产品修改成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product = Product.find(params[:id])
    @product.update_attribute(:deleted, true)

    respond_to do |format|
      format.html { redirect_to admin_products_path }
      format.json { head :no_content }
    end
  end
  
  private
  
  def product_params
    params.require(:product).permit(:name, :code, :keywords, :description, :origin_price, :sale_price, :product_type, :effect_type, :effect_str, :onlined_at, :created_at, :expired_at, :tag_list, :tree_group_data, :exam_type_id, :type_id, :skxx_id, :sale, :mobile_description, :available, :exam_level_id, :sortrank, :product_text_attributes => [:content])
  end
  
  def init_breadcrumb_and_module_name
    drop_breadcrumb("课程产品", admin_products_path)
    @_module_name = 'product'
    @__module_name = 'Product'
  end
end
