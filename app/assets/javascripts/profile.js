//= require bootstrap-datepicker
$(document).ready(function (e) {
  $('.datepicker').datepicker();
  $('.tabsbtns').click(function(){
    if (!$(this).hasClass( "disabled" )) {
      $( ".tabsbtns" ).removeClass( "active" );
      $(this).addClass( "active" );
    }
  });
  $("#user_avatar").change(function(){
    $('#profile-picture').submit();
  });
})
