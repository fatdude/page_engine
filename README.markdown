Page engine is a (_reasonably_) simple way to extend your rails application with pages. This allows you to automatically generate navigation, breadcrumbs and create page snippets to use anywhere in your app views.

Installation
------------

For rails 3 and above simply add the following to your gemfile:

`gem 'page_engine'`

Then bundle install.

To make use of the assets in the gem add the following to your stylesheets manifest

`*= require page_engine`
  
and after jquery in your javascripts manifest 
  
`//= require page_engine`

Run the installation generator to install the config file in config/initializers (for versions of rails that don't support the asset pipeline the assets will be copied across at the same time).

`rails g page_engine:install`

To install the migrations run

`rake page_engine_engine:install:migrations`

Usage
-----

In application_controller add the line

`page_engine`

and you're good to go. 

You can supply options to page engine by editing the page_engine.rb initializer file.

For rails 3 the required stylesheet and javascript files can be included with:

`stylesheet_link_tag :page_engine`

and 

`javascript_include_tag :page_engine`

How it works
------------

PageEngine comes with an admin namespace where you can CRUD your pages. It uses [jquery.nestedSortable](http://mjsarfatti.com/sandbox/nestedSortable/ "jquery.nestedSortable") to allow reordering and nesting of pages using drag and drop. When you create the page you can set a url or a controller and action and PageEngine use these to find the correct page. So, for example, say you have a welcome page at welcome#index, if you set the url to '/welcome' or choose welcome#index from the dropdown that page record will be retrieved when the welcome index page is hit and be available to your views.

Using [MarkItUp](http://markitup.jaysalvat.com/home/ "MarkItUp") it's possible to write page content using textile, markdown or plain html. There's also the option to use erb but this is pretty dangerous and open to abuse so don't count on it being in there forever.

In the views
------------

PageEngine comes with a few helpers:

`navigation(root page permalink, options)`

This generates an unordered list (ul) containing the root page and it's descendants up to the depth specified in the options.

`page_content`

Renders the page content using the filter specified (textile, markdown etc). Defaults to using the automatically found page and it's body page part but this can be overriden in the options

`breadcrumbs`

Generates a set of links that represent the current page and it's ancestors

`page_title(default_text)`

Outputs the page title, or the default text if no page record has been found.
	
`page_js`

Outputs a javascript tag containing the page javascript, or just the straight css if :with_tags => false.
	
`page_css`

Outputs a stylesheet tag containing the page css, or just the straight css if :with_tags => false.
	
`page_meta_keywords`

Outputs a meta tag containing the pages keywords, or just the keywords if :with_tags => false

`page_meta_description`

Outputs a meta tag containing the pages description, or just the description if :with_tags => false
	
`page_snippet(snippet name)`

Renders the named snippet.

Rails engine
------------

Since this was built using the rails 3.1 plugin generator you can test the gem using the dummy application which can be found under spec/dummy.
