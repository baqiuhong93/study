//= require jquery
//= require jquery_ujs

function getCookie( name ) 
{ 
var start = document.cookie.indexOf( name + "=" ); 
var len = start + name.length + 1; 
if ( ( !start ) && ( name != document.cookie.substring( 0, name.length ) ) ) { 
return null; 
} 
if ( start == -1 ) return null; 
var end = document.cookie.indexOf( ';', len ); 
if ( end == -1 ) end = document.cookie.length; 
return unescape( document.cookie.substring( len, end ) ); 
} 

function setCookie( name, value, expires, path, domain, secure ) { 
var today = new Date(); 
today.setTime( today.getTime() ); 
if ( expires ) { 
expires = expires * 1000 * 60 * 60 * 24; 
} 
var expires_date = new Date( today.getTime() + (expires) ); 
document.cookie = name+'='+escape( value ) + 
( ( expires ) ? ';expires='+expires_date.toGMTString() : '' ) + //expires.toGMTString() 
( ( path ) ? ';path=' + path : '' ) + 
( ( domain ) ? ';domain=' + domain : '' ) + 
( ( secure ) ? ';secure' : '' ); 
} 

function deleteCookie( name, path, domain ) 
{ 
if ( getCookie( name ) ) document.cookie = name + '=' + ( ( path ) ? ';path=' + path : '') + ( ( domain ) ? ';domain=' + domain : '' ) + ';expires=Thu,01-Jan-1970 00:00:01 GMT'; 
}


Date.prototype.format = function(format) //author: meizz
{
  var o = {
    "M+" : this.getMonth()+1, //month
    "d+" : this.getDate(),    //day
    "h+" : this.getHours(),   //hour
    "m+" : this.getMinutes(), //minute
    "s+" : this.getSeconds(), //second
    "q+" : Math.floor((this.getMonth()+3)/3),  //quarter
    "S" : this.getMilliseconds() //millisecond
  }

  if(/(y+)/.test(format)) format=format.replace(RegExp.$1,
    (this.getFullYear()+"").substr(4 - RegExp.$1.length));
  for(var k in o)if(new RegExp("("+ k +")").test(format))
    format = format.replace(RegExp.$1,
      RegExp.$1.length==1 ? o[k] :
        ("00"+ o[k]).substr((""+ o[k]).length));
  return format;
}


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