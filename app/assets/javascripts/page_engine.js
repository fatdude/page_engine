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
  
  CKEDITOR.editorConfig = function( config )
  {
	  config.basePath = '/assets/ckeditor';
  };

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
  
  $('textarea[data-filter=textile]').each(function(){
    TextileEditor.initialize($(this).attr('id'));
  });
  
  $('textarea[data-filter=wysiwyg]').ckeditor();

  $('select.filter').live('change', function(){
    console.debug('Going to change the filter');
    textarea = $('#' + $(this).attr('rel'));
    filter = textarea.attr('data-filter');
    
    switch ($(this).val()){
      case 'wysiwyg':
        if (filter == 'textile') {
          remove_textile(textarea);
        }
        add_wysiswyg(textarea)
        textarea.attr('data-filter', 'wysiwyg');
        break;
      case 'textile':
        if (filter == 'wysiwyg') {
          remove_wysiwyg(textarea);
        }
        add_textile(textarea)
        textarea.attr('data-filter', 'textile');
        break;
      case 'erb':
        remove_editors(textarea);
        textarea.attr('data-filter', 'erb');
        break;
      case 'erb+textile':
        if (filter == 'wysiwyg') {
          remove_wysiwyg(textarea);
        }
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

add_wysiswyg = function(textarea){
  textarea.ckeditor();
}

add_textile = function(textarea){
  id = textarea.attr('id');
  if ($('#textile-toolbar-' + id).length == 0){
    TextileEditor.initialize(id);
  } 
}

remove_wysiwyg = function(textarea){
  textarea.ckeditor(function(){
    this.destroy();
  });
}

remove_textile = function(textarea){
  $('#textile-toolbar-' + textarea.attr('id')).remove();
}

remove_editors = function(textarea){
  filter = textarea.attr('data-filter');
  
  if (filter == 'wysiwyg') {
    remove_wysiwyg(textarea);
  }
  
  if (filter == 'textile' || filter == 'erb+textile') {
    remove_textile(textarea);
  }
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
