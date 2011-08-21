//= require jquery-ui-1.8.15.custom.min
//= require jquery.markitup
//= require markitup/sets/html/set
//= require markitup/sets/textile/set
//= require markitup/sets/markdown/set
//= require markitup/sets/css/set
//= require jquery.ui.nestedSortable

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
  
  var selected_tab = 0;
  var page_parts = $('.page_parts').tabs({
    select: function(event, ui){
      selected_tab = ui.index;
    }
  });

  $('.page_part a.delete').live('click', function(){
    $(this).prev().val(true);
    $('.page_parts').after($(this).prev());
    page_parts.tabs('remove', selected_tab);     
    return false;
  });
  
  $('textarea[data-filter=css]').markItUp(markitup_css_settings).parents('.markItUp').addClass('css');  

  $('textarea[data-filter=textile]').markItUp(markitup_textile_settings);
  
  $('textarea[data-filter=markdown]').markItUp(markitup_markdown_settings);
  
  $('textarea[data-filter=html]').markItUp(markitup_html_settings);

  $('select.filter').live('change', function(){
    textarea = $('#' + $(this).attr('rel'));
    filter = textarea.attr('data-filter');
    
    switch ($(this).val()){
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
});

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

remove_editors = function(textarea){
  textarea.markItUpRemove();
}

add_fields = function(link, association, content){
  var page_part_name = $('#new_page_part_name').val();
  
  if (page_part_name != ''){
    if ($('#' + page_part_name.replace(/[^a-z0-9\-_]+/ig, '-')).length == 0){
      var new_id = new Date().getTime();
      var regexp = new RegExp("new_" + association, "g");

      $('.page_parts').tabs('add', '#' + new_id, page_part_name);
      $('#' + new_id).html(content.replace(regexp, new_id));
      $('#' + new_id).addClass('page_part');
      $('#' + new_id + ' .field:first input').val(page_part_name);
      $('#new_page_part_name').val('');
    }
    else {
      flash_message('Name already exists', 'alert');      
    }
  } else {
    flash_message('You need to specify a name', 'alert');
  }
}

