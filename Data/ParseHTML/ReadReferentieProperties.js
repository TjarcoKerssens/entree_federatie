var properties = {};
jQuery("table:first tbody tr").each(function(val, i){
          var data = jQuery(this).find("td");
          var key = data.first().text();
          var value = data.last().text();
          properties[key] = value;
});
properties; // This exposes the properties to the calback in Swift
