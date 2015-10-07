function product_tree_form_submit() {
	if($('#product_tree_node_type').val() == '') {
		$('#product_tree_node_type').focus();
		alert('请选择类型！');
		return;
	}
	$('#product_teachers_json').val(JSON.stringify($("#product_teachers").select2("data")));
	$('#jy_global_assets_json').val(JSON.stringify($("#jy_global_assets").select2("data")));
	var product_tree_form = $('#product_tree_form');
	$.post(product_tree_form.attr('action')+'.json',product_tree_form.serialize(),function(data) {
		$('#productTreeModal').modal('hide');
		var zTree = $.fn.zTree.getZTreeObj("product_tree_ztree");
		if(data['pId'] == 0) {
			var selectedNodes = zTree.getSelectedNodes();
			if(selectedNodes.length > 0) {
				var selectedNode = zTree.getSelectedNodes()[0];
				if(selectedNode.id == data['id']) {
					selectedNode.name = data['name'];
					selectedNode.node_type = data['node_type'];
					zTree.updateNode(selectedNode);
				} else {
					zTree.addNodes(null, {id : data['id'], pId : data['pId'], name : data['name'], node_type : data['node_type']});
				}
			} else {
				zTree.addNodes(null, {id : data['id'], pId : data['pId'], name : data['name'], node_type : data['node_type']});
			}
		} else {
			var selectedNode = zTree.getSelectedNodes()[0];
			if(selectedNode.id == data['id']) {
				selectedNode.name = data['name'];
				selectedNode.node_type = data['node_type'];
				zTree.updateNode(selectedNode);
			} else {
				zTree.addNodes(selectedNode,{id : data['id'], pId : data['pId'], name : data['name'], node_type : data['node_type']});	
			}
		}
	});
}
