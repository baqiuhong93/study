// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require select2
//= require json2
//= require admin/knowledge_trees
//= require admin/product_trees

Array.prototype.indexOf = function(val) {
    for (var i = 0,len = this.length; i < len; i++) {
        if (this[i] == val) return i;
    }
    return -1;
}
Array.prototype.remove = function(val) {
    var index = this.indexOf(val);
    if (index > -1) {
        this.splice(index, 1);
    }
}

Array.prototype.insertAt = function( index, value ) {
    this.splice(index, 0, value);
}
 
Array.prototype.removeAt = function( index ){
	var i;
  if(index < this.length)
  {
   for(i = index; i < this.length - 1; i++)
   {
    this[i] = this[i + 1];
   }
   this.length = this.length - 1;
  }
}

$.extend({
	deleteAjax : function(url, params, fun) {
		$.ajax({
			url : url,
			data : params,
			success : function(data) {
				fun(data);
			},
			type : 'DELETE'
		});
	} 
});


function remove_fields(link) {
  $(link).previous("input[type=hidden]").value = "1";
  $(link).up(".fields").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  
  $(link).up().insert({
    before: content.replace(regexp, new_id)
  });
  alert($(link).up().html());
}


