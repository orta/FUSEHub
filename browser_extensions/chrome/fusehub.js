// 
//  fusehub.js
//  chrome
//  
//  Created by orta on 2010-12-12.
//  Copyright 2010 ortatherox. All rights reserved.
//  All code is BSD or whatever


jQuery(document).ready(function() {
  if( $("body.page-profile").length ){
    // in a profile page, show a "browser users repos" button
    var owner = $(".pagehead h1").text().replace(/^\s*|\s*$/g,'').toLowerCase()    
    $(".actions").append('<li><a href="fusehub:user=' + owner + '&action=browse" class="minibutton btn-msg"><span>Mount User in FUSEHub</span></a></li>')
  }
  
  if( $("#download_button").length ){
    // in a repo page, show add a Mount Repo Button
    var owner = $(".title-actions-bar h1 a")[0].text
    var repo_name = $(".title-actions-bar h1 a")[1].text
    
    $('<a href="fusehub:user=' + owner + '&repo=' + repo_name + '" class="download-source" id="mount_button" title="Download source, tagged packages and binaries."><span class="icon"></span>Mount</a>').insertAfter("#download_button")
  }
  
})