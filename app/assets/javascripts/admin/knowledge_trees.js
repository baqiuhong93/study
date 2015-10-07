function knowledge_tree_form_submit() {
	if($('#knowledge_tree_node_type').val() == '') {
		$('#knowledge_tree_node_type').focus();
		alert('请选择类型！');
		return;
	}
	var knowledge_tree_form = $('#knowledge_tree_form');
	$.post(knowledge_tree_form.attr('action')+'.json',knowledge_tree_form.serialize(),function(data) {
		var zTree = $.fn.zTree.getZTreeObj("knowledge_tree_ztree");
		$('#knowledgeTreeModal').modal('hide');
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
