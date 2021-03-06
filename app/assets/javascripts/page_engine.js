//= require jquery-ui-1.8.15.custom.min
//= require jquery.markitup
//= require markitup/sets/html/set
//= require markitup/sets/textile/set
//= require markitup/sets/markdown/set
//= require markitup/sets/css/set
//= require markitup/sets/javascript/set
//= require jquery.ui.nestedSortable
//= require codemirror/codemirror
//= require codemirror/modes/javascript
//= require codemirror/modes/css

$(document).ready(function(){
  
  $('ol#page_engine').nestedSortable({
    disableNesting: 'no-nest',
    forcePlaceholderSize: true,
    handle: 'div',
    helper: 'clone',
    items: 'li',
    opacity: .6,
    placeholder: 'placeholder',
    revert: 250,
    tabSize: 25,
    tolerance: 'pointer',
    toleranceElement: '> div'
  }); 
  
  $('#update_page_positions').click(function(){    
    page_array = $('ol#page_engine').nestedSortable('toArray', { startDepthCount: 0 });
    page_array.splice(0, 1);
    
    $.ajax({
      data: { pages: page_array },
      dataType:'script',
      url: $('ol#page_engine').attr('data-href'),
      type: 'put'
    });
    return false;
  });
  
  var page_parts = $('#page_engine_page_parts').tabs({
    tabTemplate: "<li><a href='#{href}'>#{label}</a> <span class='icon delete'>Remove page part</span></li>"
  });

  $('#page_engine_page_parts ul li span.delete').live('click', function(){
    hidden_delete = $($(this).prev().attr('href')).find('input[type=hidden]:first');
    hidden_delete.val(true);
    $('.page_parts').after(hidden_delete);
    
    var index = $("li", page_parts).index($(this).parent());
    page_parts.tabs('remove', index);     
    
    return false;
  });
  
  $('select.filter').live('change', function(){
    check_filter($(this));
  });
  
  $('select.filter').each(function(){
    check_filter($(this));
  });
  
  $('textarea[data-filter=css]').each(function(){
    add_css($(this));
  });  
  
  $('textarea[data-filter=javascript]').each(function(){
    add_javascript($(this));
  });  
  
  $('#page_no_publish_window').change(function(){
    $('.edit_page .field.publish_from').toggle('slide');
    $('.edit_page .field.publish_to').toggle('slide');
  });
  
  $('textarea.ignore_tab').keypress(function(e){
    if(e.keyCode == 9){
      var pos = $(this).caret().start + 2;
      text = $(this).val().substr(0, $(this).caret().start) + '  ' + $(this).val().substr($(this).caret().start);
      console.debug($(this).val().substr($(this).caret().start));
      $(this).val(text); 
      
		  if ($(this).get(0).setSelectionRange) 
		  { 	
			  $(this).get(0).setSelectionRange(pos, pos); 	
		  } 
		  else if ($(this).get(0).createTextRange) 
		  { 
			  var range = $(this).get(0).createTextRange(); 
			  range.collapse(true); range.moveEnd("character", pos); 
			  range.moveStart("character", pos); range.select(); 
		  } 
      return false;
    }
  });
  
  $('#add_page_part').click(function(){
    page_part_name = prompt('Enter the new page part name').replace(/[^a-z0-9\-_]+/ig, '-');
    
    if (page_part_name != ''){
      if ($('#page_part_' + page_part_name).length == 0){
        var new_id = new Date().getTime();
        var content = unescape($('#page_engine_page_parts').attr('data-fields'));
        
        content = content.replace(/name="page_parts/g, 'name="page[page_parts_attributes][' + new_id + ']');
        content = content.replace(/for="page_parts/g, 'for="page_page_parts_attributes_' + new_id);

        $('#page_engine_page_parts').tabs('add', '#' + new_id, page_part_name);
        $('#' + new_id).html(content);
        $('#' + new_id).addClass('page_part');
        $('#' + new_id + ' .input:first input').val(page_part_name);
      }
      else {
        alert('Name already exists');      
      }
    } else {
      alert('You need to specify a name');
    }
    
    return false;
  });
});

check_filter = function(filter){
  textarea = $('#' + filter.attr('rel'));
  
  switch (filter.val()){
    case 'html':
      add_html(textarea)
      textarea.attr('data-filter', 'html');
      break;
    case 'textile':
      add_textile(textarea);
      textarea.attr('data-filter', 'textile');
      break;
    case 'markdown':
      add_markdown(textarea);
      textarea.attr('data-filter', 'markdown');
      break;
    case 'erb':
      remove_editors(textarea);
      textarea.attr('data-filter', 'erb');
      break;
    case 'erb+textile':
      add_textile(textarea)
      textarea.attr('data-filter', 'erb+textile');
      break;
    case 'none':
      remove_editors(textarea);
      textarea.attr('data-filter', 'none');
      break;
  }
}

add_html = function(textarea){
  remove_editors(textarea);
  textarea.markItUp(markitup_html_settings);
  textarea.parents('.markItUp').addClass('html');
}

add_textile = function(textarea){
  remove_editors(textarea);
  textarea.markItUp(markitup_textile_settings);
  textarea.parents('.markItUp').addClass('textile');
}

add_markdown = function(textarea){
  remove_editors(textarea);
  textarea.markItUp(markitup_markdown_settings);
  textarea.parents('.markItUp').addClass('markdown');
}

add_css = function(textarea){
  CodeMirror.fromTextArea(document.getElementById(textarea.attr('id')), {
    lineNumbers: true,
    matchBrackets: true,
    mode: 'css'
  });
}

add_javascript = function(textarea){
  CodeMirror.fromTextArea(document.getElementById(textarea.attr('id')), {
    lineNumbers: true,
    matchBrackets: true,
    mode: 'javascript'
  });
}

remove_editors = function(textarea){
  textarea.markItUpRemove();
}

add_fields = function(link, association, content){
  var page_part_name = $('#new_page_part_name').val();
  
  if (page_part_name != ''){
    if ($('#' + page_part_name.replace(/[^a-z0-9\-_]+/ig, '-')).length == 0){
      var new_id = new Date().getTime();
      
      content = content.replace(/name="page_parts/g, 'name="page[page_parts_attributes][' + new_id + ']');
      content = content.replace(/for="page_parts/g, 'for="page_page_parts_attributes_' + new_id);

      $('.page_parts').tabs('add', '#' + new_id, page_part_name);
      $('#' + new_id).html(content);
      $('#' + new_id).addClass('page_part');
      $('#' + new_id + ' .input:first input').val(page_part_name);
      $('#new_page_part_name').val('');
    }
    else {
      alert('Name already exists');      
    }
  } else {
    alert('You need to specify a name');
  }
  return false;
}

